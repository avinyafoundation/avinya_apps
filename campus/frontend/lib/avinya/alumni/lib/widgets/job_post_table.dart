import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gallery/avinya/alumni/lib/data/job_post.dart';
import 'package:gallery/avinya/alumni/lib/screens/admin_edit_alumni_profile.dart';
import 'package:gallery/avinya/alumni/lib/screens/update_job_screen.dart';
import 'package:gallery/avinya/alumni/lib/widgets/update_job_widget.dart';
import 'package:sizer/sizer.dart';
import 'package:gallery/constants.dart';

class JobPostTableWidget extends StatefulWidget {
  const JobPostTableWidget({super.key});

  @override
  State<JobPostTableWidget> createState() => _JobPostTableWidgetState();
}

class _JobPostTableWidgetState extends State<JobPostTableWidget> {
  List<JobPost> _jobPosts = [];
  final int _resultLimit = 4;
  bool _isLoading = false;
  int _offset = 0;
  bool _isDeletingJobPost = false;

  Future<void> loadData() async {
    setState(() {
      _isLoading = true;
    });
    _jobPosts = await fetchJobPosts(_resultLimit, _offset);
    setState(() {
      _isLoading = false;
    });
  }

  void nextPage() {
    _offset += _resultLimit;
    loadData();
  }

  void previousPage() {
    if (_offset >= _resultLimit) {
      _offset -= _resultLimit;
      loadData();
    }
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void _deleteJobPost(JobPost jobPost) async {
    String jobPostTypeValue = jobPost.job_type.toString();
    int jobPostId = jobPost.id ?? 0;
    if (jobPostId == 0) return;

    if (_isDeletingJobPost) return;

    _isDeletingJobPost = true;

    try {
      JobPost jobPostDetails = JobPost();
      int jobPostDeleteResponse;

      if (jobPostTypeValue == 'text' || jobPostTypeValue == 'text_with_link') {
        jobPostDetails = JobPost(
          id: jobPostId,
          job_type: jobPostTypeValue,
        );
      } else if (jobPostTypeValue == 'image') {
        jobPostDetails = JobPost(
          id: jobPostId,
          job_type: jobPostTypeValue,
          job_image_drive_id: jobPost.job_image_drive_id,
        );
      }
      jobPostDeleteResponse = await deleteJobPost(jobPostDetails);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Job Post data deleted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete job post data: $e')),
      );
    } finally {
      _isDeletingJobPost = false;
      loadData();
      setState(() {});
    }
  }

  Widget tableCell(String content) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(content,
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontSize: SizerUtil.deviceType == DeviceType.mobile
                    ? 08.sp
                    : SizerUtil.deviceType == DeviceType.tablet
                        ? 11.sp
                        : SizerUtil.deviceType == DeviceType.web
                            ? 03.sp
                            : 08.sp,
              ),
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center),
    );
  }

  @override
  Widget buildTable() {
    return Table(
      border: TableBorder.all(),
      children: [
        TableRow(children: [
          Text('Job Type',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: SizerUtil.deviceType == DeviceType.mobile
                        ? 09.sp
                        : SizerUtil.deviceType == DeviceType.tablet
                            ? 12.sp
                            : SizerUtil.deviceType == DeviceType.web
                                ? 04.sp
                                : 09.sp,
                  ),
              textAlign: TextAlign.center),
          Text('Job Text',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: SizerUtil.deviceType == DeviceType.mobile
                        ? 09.sp
                        : SizerUtil.deviceType == DeviceType.tablet
                            ? 12.sp
                            : SizerUtil.deviceType == DeviceType.web
                                ? 04.sp
                                : 09.sp,
                  ),
              textAlign: TextAlign.center),
          Text('Job Link',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: SizerUtil.deviceType == DeviceType.mobile
                        ? 09.sp
                        : SizerUtil.deviceType == DeviceType.tablet
                            ? 12.sp
                            : SizerUtil.deviceType == DeviceType.web
                                ? 04.sp
                                : 09.sp,
                  ),
              textAlign: TextAlign.center),
          Text('Job Post Image',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: SizerUtil.deviceType == DeviceType.mobile
                        ? 09.sp
                        : SizerUtil.deviceType == DeviceType.tablet
                            ? 12.sp
                            : SizerUtil.deviceType == DeviceType.web
                                ? 04.sp
                                : 09.sp,
                  ),
              textAlign: TextAlign.center),
          Text('Application Deadline',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: SizerUtil.deviceType == DeviceType.mobile
                        ? 09.sp
                        : SizerUtil.deviceType == DeviceType.tablet
                            ? 12.sp
                            : SizerUtil.deviceType == DeviceType.web
                                ? 04.sp
                                : 09.sp,
                  ),
              textAlign: TextAlign.center),
          Text('Actions',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: SizerUtil.deviceType == DeviceType.mobile
                        ? 09.sp
                        : SizerUtil.deviceType == DeviceType.tablet
                            ? 12.sp
                            : SizerUtil.deviceType == DeviceType.web
                                ? 04.sp
                                : 09.sp,
                  ),
              textAlign: TextAlign.center),
        ]),
        ..._jobPosts.map((jobPost) => TableRow(children: [
              tableCell(jobPost.job_type.toString() ?? "N/A"),
              tableCell(jobPost.job_text.toString() ?? "N/A"),
              tableCell(jobPost.job_link.toString() ?? "N/A"),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 3.w),
                child: Row(
                  children: [
                    jobPost.job_post_image != null
                        ? Image.memory(
                            base64Decode(jobPost.job_post_image.toString()),
                            height: 80.0,
                            width: 80.0,
                            fit: BoxFit.cover,
                          )
                        : Spacer()
                  ],
                ),
              ),
              //tableCell(jobPost.job_category_id.toString() ?? "N/A"),
              tableCell(jobPost.application_deadline.toString() ?? "N/A"),
              Center(
                child: Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(right: 20.0),
                        width: 10.w,
                        height: 10.h,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UpdateJobScreen(
                                  id: jobPost.id, // Pass the ID
                                ),
                              ),
                            );
                          },
                          child: Text(
                            'Edit',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                      SizerUtil.deviceType == DeviceType.mobile
                                          ? 08.sp
                                          : SizerUtil.deviceType ==
                                                  DeviceType.tablet
                                              ? 11.sp
                                              : SizerUtil.deviceType ==
                                                      DeviceType.web
                                                  ? 03.sp
                                                  : 08.sp,
                                ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.yellow[400],
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 5.0),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(right: 20.0),
                        width: 10.w,
                        height: 10.h,
                        child: ElevatedButton(
                          onPressed: () => _deleteJobPost(jobPost),
                          child: Text(
                            'Delete',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                      SizerUtil.deviceType == DeviceType.mobile
                                          ? 08.sp
                                          : SizerUtil.deviceType ==
                                                  DeviceType.tablet
                                              ? 11.sp
                                              : SizerUtil.deviceType ==
                                                      DeviceType.web
                                                  ? 03.sp
                                                  : 08.sp,
                                ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[400],
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 5.0),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ]))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _isLoading
              ? Center(
                  child: SpinKitCircle(
                    color: (Colors
                        .blueGrey[400]), // Customize the color of the indicator
                    size: 50, // Customize the size of the indicator
                  ),
                )
              : buildTable(),
          SizedBox(
            height: 2.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                  onPressed: _offset > 0 ? previousPage : null,
                  child: Text(
                    'Previous',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: Colors.blue,
                          fontSize: SizerUtil.deviceType == DeviceType.mobile
                              ? 08.sp
                              : SizerUtil.deviceType == DeviceType.tablet
                                  ? 11.sp
                                  : SizerUtil.deviceType == DeviceType.web
                                      ? 03.sp
                                      : 08.sp,
                        ),
                  )),
              SizedBox(
                width: 2.w,
              ),
              OutlinedButton(
                  onPressed: _jobPosts.length == _resultLimit ? nextPage : null,
                  child: Text(
                    'Next',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: Colors.blue,
                          fontSize: SizerUtil.deviceType == DeviceType.mobile
                              ? 08.sp
                              : SizerUtil.deviceType == DeviceType.tablet
                                  ? 11.sp
                                  : SizerUtil.deviceType == DeviceType.web
                                      ? 03.sp
                                      : 08.sp,
                        ),
                  ))
            ],
          )
        ],
      ),
    );
  }
}
