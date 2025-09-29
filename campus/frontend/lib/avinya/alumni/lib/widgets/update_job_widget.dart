import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gallery/avinya/alumni/lib/data/job_category.dart';
import 'package:gallery/avinya/alumni/lib/data/job_post.dart';
import 'package:gallery/avinya/alumni/lib/data/person.dart';
import 'package:gallery/constants.dart';
import 'package:gallery/data/campus_apps_portal.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

class UpdateJobWidget extends StatefulWidget {
  final int? jobPostId;
  const UpdateJobWidget({super.key, this.jobPostId});

  @override
  State<UpdateJobWidget> createState() => _UpdateJobWidgetState();
}

class _UpdateJobWidgetState extends State<UpdateJobWidget> {
  JobPost _jobPost = JobPost();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final List<String> _jobPostTypesOptions = ['text', 'image', 'text_with_link'];
  late Future<List<JobCategory>> _jobCategoryOptions;

  final TextEditingController _jobDescriptionController =
      TextEditingController();
  final TextEditingController _jobPostLinkController = TextEditingController();
  final TextEditingController _jobDeadlineDateController =
      TextEditingController();

  String? _selectedJobPostTypeValue;
  JobCategory? _selectedJobCategory;
  int? _selectedJobCategoryId;
  bool _isSubmitting = false;

  final ImagePicker _picker = ImagePicker();
  Uint8List? _selectedJobPostImage;
  DateTime? _selectedDate;

  String? _imageError;

  @override
  void initState() {
    super.initState();
    _jobCategoryOptions = _loadJobCategoryData();
    getJobPost();
  }

  void getJobPost() async {
    // Retrieve job post data from local instance
    _jobPost = await fetchJobPost(widget.jobPostId!);

    _selectedJobPostTypeValue = _jobPost.job_type;
    _jobDescriptionController.text = _jobPost.job_text ?? "";
    _jobPostLinkController.text = _jobPost.job_link ?? "";

    if (_jobPost.job_post_image != null) {
      _selectedJobPostImage = base64Decode(_jobPost.job_post_image.toString());
    }
    _selectedJobCategory = (await _jobCategoryOptions).firstWhere(
        (jobCategory) => jobCategory.id == _jobPost.job_category_id,
        orElse: () => JobCategory());
    _jobDeadlineDateController.text = _jobPost.application_deadline ?? "";

    setState(() {
      _selectedJobPostTypeValue;
      _jobDescriptionController;
      _jobPostLinkController;
      _selectedJobPostImage;
      _selectedJobCategory;
      _jobDeadlineDateController;
    });
  }

  Future<List<JobCategory>> _loadJobCategoryData() async {
    return await fetchJobCategories();
  }

  //Image picker function to get image from gallery
  Future<void> _pickJobPostImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _selectedJobPostImage = bytes;
        });
      }
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime(2100));

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _jobDeadlineDateController.text =
            DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _updateJobPost() async {
    JobPost jobPostDetails = JobPost();
    JobPost jobPostUpdateResponse;

    if (_isSubmitting) return;

    _isSubmitting = true;

    if (_selectedJobPostTypeValue == 'image') {
      setState(() {
        _imageError =
            _selectedJobPostImage == null ? 'Please upload an image.' : null;
      });

      if (_imageError != null) {
        _isSubmitting = false;
        return;
      }
    }
    try {
      if (_selectedJobPostTypeValue == 'text') {
        jobPostDetails = JobPost(
            id: _jobPost.id,
            job_type: _selectedJobPostTypeValue.toString(),
            job_text: _jobDescriptionController.text,
            job_category_id: _selectedJobCategoryId,
            application_deadline: _jobDeadlineDateController.text.isNotEmpty
                ? _jobDeadlineDateController.text
                : null,
            uploaded_by: campusAppsPortalInstance.getDigitalId());
      } else if (_selectedJobPostTypeValue == 'text_with_link') {
        jobPostDetails = JobPost(
            id: _jobPost.id,
            job_type: _selectedJobPostTypeValue.toString(),
            job_text: _jobDescriptionController.text,
            job_link: _jobPostLinkController.text,
            job_category_id: _selectedJobCategoryId,
            application_deadline: _jobDeadlineDateController.text.isNotEmpty
                ? _jobDeadlineDateController.text
                : null,
            uploaded_by: campusAppsPortalInstance.getDigitalId());
      } else if (_selectedJobPostTypeValue == 'image' && _imageError == null) {
        jobPostDetails = JobPost(
            id: _jobPost.id,
            job_type: _selectedJobPostTypeValue.toString(),
            job_image_drive_id: _jobPost.job_image_drive_id,
            current_date_time:
                DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
            job_category: _selectedJobCategory!.name.toString(),
            job_category_id: _selectedJobCategoryId,
            application_deadline: _jobDeadlineDateController.text.isNotEmpty
                ? _jobDeadlineDateController.text
                : null,
            uploaded_by: campusAppsPortalInstance.getDigitalId());
      }
      jobPostUpdateResponse =
          await updateJobPost(_selectedJobPostImage ?? null, jobPostDetails);
      _jobPost = jobPostUpdateResponse;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Job Post data updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update job post data: $e')),
      );
    } finally {
      _isSubmitting = false;
      // _selectedJobPostTypeValue = null;
      // _jobDescriptionController.text = "";
      // _jobPostLinkController.text = "";
      // _jobDeadlineDateController.text = "";
      // _selectedJobPostImage = null;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _jobDescriptionController.dispose();
    _jobPostLinkController.dispose();
    _jobDeadlineDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.all(20.0),
        child: Form(
            key: _formKey,
            child: Column(
              children: [
                Table(
                  columnWidths: {
                    0: FixedColumnWidth(10.w),
                    1: FlexColumnWidth(),
                  },
                  children: [
                    TableRow(
                      children: [
                        Text(
                          'Job Post Type:',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(
                                color: kTextBlackColor,
                                fontSize: SizerUtil.deviceType ==
                                        DeviceType.mobile
                                    ? 09.sp
                                    : SizerUtil.deviceType == DeviceType.tablet
                                        ? 12.sp
                                        : SizerUtil.deviceType == DeviceType.web
                                            ? 04.sp
                                            : 09.sp,
                              ),
                        ),
                        DropdownButtonFormField<String>(
                          value: _selectedJobPostTypeValue,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(
                                  color: Colors.grey.shade800, width: 1.5),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 14.0),
                          ),
                          items: _jobPostTypesOptions.map((String status) {
                            return DropdownMenuItem<String>(
                              value: status,
                              child: Text(
                                status,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: null,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(
                                color: kTextBlackColor,
                                fontSize: SizerUtil.deviceType ==
                                        DeviceType.mobile
                                    ? 09.sp
                                    : SizerUtil.deviceType == DeviceType.tablet
                                        ? 12.sp
                                        : SizerUtil.deviceType == DeviceType.web
                                            ? 04.sp
                                            : 09.sp,
                              ),
                        ),
                      ],
                    ),
                    TableRow(children: [
                      SizedBox(
                        height: 5.h,
                      ),
                      SizedBox(height: 5.h)
                    ]),
                    if (_selectedJobPostTypeValue == 'text' ||
                        _selectedJobPostTypeValue == 'text_with_link')
                      TableRow(
                        children: [
                          Text(
                            'Job Description:',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                  color: kTextBlackColor,
                                  fontSize:
                                      SizerUtil.deviceType == DeviceType.mobile
                                          ? 09.sp
                                          : SizerUtil.deviceType ==
                                                  DeviceType.tablet
                                              ? 12.sp
                                              : SizerUtil.deviceType ==
                                                      DeviceType.web
                                                  ? 04.sp
                                                  : 09.sp,
                                ),
                          ),
                          TextFormField(
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                  color: kTextBlackColor,
                                  fontSize:
                                      SizerUtil.deviceType == DeviceType.mobile
                                          ? 09.sp
                                          : SizerUtil.deviceType ==
                                                  DeviceType.tablet
                                              ? 12.sp
                                              : SizerUtil.deviceType ==
                                                      DeviceType.web
                                                  ? 04.sp
                                                  : 09.sp,
                                ),
                            controller: _jobDescriptionController,
                            maxLines: 10,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a job description';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              //labelText: "Company Name",
                              hintText: 'Enter your job description here...',
                              hintStyle: TextStyle(color: Colors.grey.shade500),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 14.0, horizontal: 12.0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade400),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide(
                                    color: Colors.grey.shade800,
                                    width: 1.5), // Highlight on focus
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (_selectedJobPostTypeValue == 'text_with_link')
                      TableRow(children: [
                        SizedBox(
                          height: 5.h,
                        ),
                        SizedBox(height: 5.h)
                      ]),
                    if (_selectedJobPostTypeValue == 'text_with_link')
                      TableRow(
                        children: [
                          Text(
                            'Link:',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                  color: kTextBlackColor,
                                  fontSize:
                                      SizerUtil.deviceType == DeviceType.mobile
                                          ? 09.sp
                                          : SizerUtil.deviceType ==
                                                  DeviceType.tablet
                                              ? 12.sp
                                              : SizerUtil.deviceType ==
                                                      DeviceType.web
                                                  ? 04.sp
                                                  : 09.sp,
                                ),
                          ),
                          TextFormField(
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                  color: kTextBlackColor,
                                  fontSize:
                                      SizerUtil.deviceType == DeviceType.mobile
                                          ? 09.sp
                                          : SizerUtil.deviceType ==
                                                  DeviceType.tablet
                                              ? 12.sp
                                              : SizerUtil.deviceType ==
                                                      DeviceType.web
                                                  ? 04.sp
                                                  : 09.sp,
                                ),
                            controller: _jobPostLinkController,
                            maxLines: 4,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter the job post link';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.url,
                            decoration: InputDecoration(
                              //labelText: "Company Name",
                              hintText: 'https://example.com',
                              hintStyle: TextStyle(color: Colors.grey.shade500),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 14.0, horizontal: 12.0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade400),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide(
                                    color: Colors.grey.shade800,
                                    width: 1.5), // Highlight on focus
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (_selectedJobPostTypeValue == 'image')
                      TableRow(children: [
                        SizedBox(
                          height: 5.h,
                        ),
                        SizedBox(height: 5.h)
                      ]),
                    if (_selectedJobPostTypeValue == 'image')
                      TableRow(
                        children: [
                          Text(
                            'Upload:',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                  color: kTextBlackColor,
                                  fontSize:
                                      SizerUtil.deviceType == DeviceType.mobile
                                          ? 09.sp
                                          : SizerUtil.deviceType ==
                                                  DeviceType.tablet
                                              ? 12.sp
                                              : SizerUtil.deviceType ==
                                                      DeviceType.web
                                                  ? 04.sp
                                                  : 09.sp,
                                ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  ElevatedButton.icon(
                                      onPressed: _pickJobPostImage,
                                      icon: Icon(Icons.image),
                                      label: Text(
                                        'Upload Image',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium!
                                            .copyWith(
                                              color: kTextBlackColor,
                                              fontSize: SizerUtil.deviceType ==
                                                      DeviceType.mobile
                                                  ? 09.sp
                                                  : SizerUtil.deviceType ==
                                                          DeviceType.tablet
                                                      ? 12.sp
                                                      : SizerUtil.deviceType ==
                                                              DeviceType.web
                                                          ? 04.sp
                                                          : 09.sp,
                                            ),
                                      )),
                                  SizedBox(
                                    width: 1.w,
                                  ),
                                  _selectedJobPostImage != null
                                      ? Image.memory(_selectedJobPostImage!,
                                          width: 5.w)
                                      : Spacer()
                                ],
                              ),
                              if (_imageError != null)
                                Padding(
                                  padding: EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    _imageError!,
                                    style: TextStyle(
                                        color: Colors.red, fontSize: 12),
                                  ),
                                )
                            ],
                          ),
                        ],
                      ),
                    TableRow(children: [
                      SizedBox(
                        height: 5.h,
                      ),
                      SizedBox(height: 5.h)
                    ]),
                    TableRow(
                      children: [
                        Text(
                          'Job Category:',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(
                                color: kTextBlackColor,
                                fontSize: SizerUtil.deviceType ==
                                        DeviceType.mobile
                                    ? 09.sp
                                    : SizerUtil.deviceType == DeviceType.tablet
                                        ? 12.sp
                                        : SizerUtil.deviceType == DeviceType.web
                                            ? 04.sp
                                            : 09.sp,
                              ),
                        ),
                        FutureBuilder<List<JobCategory>>(
                            future: _jobCategoryOptions,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Container(
                                  margin: EdgeInsets.only(top: 10),
                                  child: SpinKitCircle(
                                    color: (Colors.blueGrey[400]),
                                    size: 70,
                                  ),
                                );
                              } else if (snapshot.hasError) {
                                return const Center(
                                  child: Text('Something went wrong...'),
                                );
                              } else if (!snapshot.hasData) {
                                return const Center(
                                  child: Text('No job category found'),
                                );
                              }
                              final jobCategoryData = snapshot.data!;
                              return DropdownButtonFormField<JobCategory>(
                                value: _selectedJobCategory,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0)),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade800,
                                        width: 1.5),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12.0, vertical: 14.0),
                                ),
                                items: jobCategoryData
                                    .map((JobCategory jobCategory) {
                                  return DropdownMenuItem<JobCategory>(
                                    value: jobCategory,
                                    child: Text(
                                      jobCategory.name!,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (JobCategory? newValue) {
                                  setState(() {
                                    if (newValue != null) {
                                      _selectedJobCategory = newValue;
                                      _selectedJobCategoryId = newValue!.id;
                                    }
                                  });
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return 'Please select a job category';
                                  }
                                  return null;
                                },
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(
                                      color: kTextBlackColor,
                                      fontSize: SizerUtil.deviceType ==
                                              DeviceType.mobile
                                          ? 09.sp
                                          : SizerUtil.deviceType ==
                                                  DeviceType.tablet
                                              ? 12.sp
                                              : SizerUtil.deviceType ==
                                                      DeviceType.web
                                                  ? 04.sp
                                                  : 09.sp,
                                    ),
                              );
                            }),
                      ],
                    ),
                    TableRow(children: [
                      SizedBox(
                        height: 5.h,
                      ),
                      SizedBox(height: 5.h)
                    ]),
                    TableRow(
                      children: [
                        Text(
                          'Deadline:',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(
                                color: kTextBlackColor,
                                fontSize: SizerUtil.deviceType ==
                                        DeviceType.mobile
                                    ? 09.sp
                                    : SizerUtil.deviceType == DeviceType.tablet
                                        ? 12.sp
                                        : SizerUtil.deviceType == DeviceType.web
                                            ? 04.sp
                                            : 09.sp,
                              ),
                        ),
                        TextFormField(
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(
                                color: kTextBlackColor,
                                fontSize: SizerUtil.deviceType ==
                                        DeviceType.mobile
                                    ? 09.sp
                                    : SizerUtil.deviceType == DeviceType.tablet
                                        ? 12.sp
                                        : SizerUtil.deviceType == DeviceType.web
                                            ? 04.sp
                                            : 09.sp,
                              ),
                          controller: _jobDeadlineDateController,
                          readOnly: true,
                          onTap: () => _pickDate(context),
                          decoration: InputDecoration(
                            labelText: "Select Deadline (YYYY-MM-DD)",
                            hintStyle: TextStyle(color: Colors.grey.shade500),
                            suffixIcon: Icon(Icons.calendar_today),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 14.0, horizontal: 12.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade400),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(
                                  color: Colors.grey.shade800,
                                  width: 1.5), // Highlight on focus
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: 5.h,
                ),
                Center(
                  child: SizedBox(
                    width: 15.w,
                    height: 5.h,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _imageError = _selectedJobPostImage == null
                              ? 'Please upload an image.'
                              : null;
                        });
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          _updateJobPost();
                        }
                      },
                      child: Text(
                        "Update Job",
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(
                              color: kTextBlackColor,
                              fontSize: SizerUtil.deviceType ==
                                      DeviceType.mobile
                                  ? 09.sp
                                  : SizerUtil.deviceType == DeviceType.tablet
                                      ? 12.sp
                                      : SizerUtil.deviceType == DeviceType.web
                                          ? 04.sp
                                          : 09.sp,
                            ),
                      ),
                      style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              vertical: 14.0, horizontal: 24.0),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(10.0), // Curved edges
                          ),
                          backgroundColor: kSecondaryColor,
                          foregroundColor: kPrimaryColor,
                          elevation: 3),
                    ),
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
