import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:mobile/avinya/alumni/lib/data/job_post.dart';
import 'package:mobile/avinya/alumni/lib/screens/bottom_navigation/bottom_navigation/controllers/bottom_navigation_controller.dart';
import 'package:mobile/constants.dart';
import 'package:mobile/widgets/job_card_widget.dart';
import 'package:sizer/sizer.dart';

class JobPostListWidget extends StatefulWidget {
  const JobPostListWidget({super.key});

  @override
  State<JobPostListWidget> createState() => _JobPostListWidgetState();
}

class _JobPostListWidgetState extends State<JobPostListWidget> {
  final BottomNavigationController controller = BottomNavigationController.find;
  late final PagingController<int, JobPost> _pagingController;

  @override
  void initState() {
    super.initState();
    _pagingController = controller.pagingController;
    _pagingController.addPageRequestListener(_fetchJobPostList);
    _pagingController.addStatusListener(_showError);
  }

  Future<void> _fetchJobPostList(int offset) async {
    try {
      final newJobPosts = await fetchJobPosts(4, offset);

      final isLastPage = newJobPosts.length < 4;
      if (isLastPage) {
        _pagingController.appendLastPage(newJobPosts);
      } else {
        final nextOffset = offset + newJobPosts.length;
        _pagingController.appendPage(newJobPosts, nextOffset);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  Future<void> _showError(PagingStatus status) async {
    if (status == PagingStatus.subsequentPageError) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Something went wrong while fetching a new page'),
        action: SnackBarAction(
            label: 'Retry',
            onPressed: () => _pagingController.retryLastFailedRequest()),
      ));
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Available Jobs"),
        backgroundColor: Colors.blueGrey[900],
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async => _pagingController.refresh(),
        child: PagedListView<int, JobPost>(
          pagingController: _pagingController,
          builderDelegate: PagedChildBuilderDelegate<JobPost>(
            animateTransitions: true,
            itemBuilder: (context, item, index) {
              return Builder(builder: (scaffoldContext) {
                return JobCardWidget(
                    jobType: item.job_type.toString(),
                    jobPostText: item.job_text.toString(),
                    jobPostLink: item.job_link.toString(),
                    jobPostImage: item.job_post_image.toString(),
                    applicationDeadline: item.application_deadline);
              });
            },
            firstPageProgressIndicatorBuilder: (context) => Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10),
                child: SpinKitCircle(
                  color: (Colors.blueGrey[400]),
                  size: 70,
                ),
              ),
            ),
            newPageProgressIndicatorBuilder: (context) => Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10),
                child: SpinKitCircle(
                  color: (Colors.blueGrey[400]),
                  size: 70,
                ),
              ),
            ),
            noMoreItemsIndicatorBuilder: (context) => Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Center(
                child: Text(
                  'No more job post data',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: kSecondaryButtonColor,
                        fontWeight: FontWeight.bold,
                        fontSize: SizerUtil.deviceType == DeviceType.mobile
                            ? 10.sp
                            : SizerUtil.deviceType == DeviceType.tablet
                                ? 13.sp
                                : SizerUtil.deviceType == DeviceType.web
                                    ? 5.sp
                                    : 10.sp,
                      ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
