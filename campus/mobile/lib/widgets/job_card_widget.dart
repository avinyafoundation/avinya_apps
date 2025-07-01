import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:mobile/constants.dart';
import 'package:photo_view/photo_view.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gallery_saver/gallery_saver.dart';

class JobCardWidget extends StatefulWidget {
  final String jobType;
  final String? jobPostText;
  final String? jobPostLink;
  final String? jobPostImage;
  final String? applicationDeadline;

  JobCardWidget({
    super.key,
    required this.jobType,
    this.jobPostText,
    this.jobPostLink,
    this.jobPostImage,
    this.applicationDeadline,
  });

  @override
  State<JobCardWidget> createState() => _JobCardWidgetState();
}

class _JobCardWidgetState extends State<JobCardWidget> {
  Future<bool?> saveDecodedImage(Uint8List decodedImageBytes) async {
    //Determine MIME type
    final mimeType = lookupMimeType('', headerBytes: decodedImageBytes);
    final extension = getExtensionFromMime(mimeType ?? 'image/jpeg');

    //Create file path with correct extension
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final filePath = '${tempDir.path}/jobPost_$timestamp.$extension';

    //Save the file
    final file = await File(filePath).create();
    await file.writeAsBytes(decodedImageBytes);

    //save to the gallery
    bool? isSaved = await GallerySaver.saveImage(file.path);

    return isSaved;
  }

  String getExtensionFromMime(String mime) {
    switch (mime) {
      case 'image/png':
        return 'png';
      case 'image/jpeg':
        return 'jpg';
      case 'image/jpg':
        return 'jpg';
      case 'image/gif':
        return 'gif';
      default:
        return 'img';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Visibility(
              visible: (widget.jobType == "text" ||
                  widget.jobType == "text_with_link"),
              child: Text(
                widget.jobPostText.toString(),
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: kTextBlackColor,
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
            SizedBox(
              height: 1.h,
            ),
            Visibility(
              visible: (widget.jobType == "text_with_link"),
              child: GestureDetector(
                onTap: () async {
                  final url = Uri.parse(widget.jobPostLink!);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
                child: Text(
                  widget.jobPostLink.toString()!,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: Colors.blueAccent,
                        decoration: TextDecoration.underline,
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
            SizedBox(
              height: 1.h,
            ),
            Visibility(
                visible: (widget.jobType == "image"),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          height: 40.h,
                          width: 80.w,
                          child: PhotoView(
                            imageProvider:
                                MemoryImage(base64Decode(widget.jobPostImage!)),
                            backgroundDecoration:
                                BoxDecoration(color: Colors.white),
                            minScale: PhotoViewComputedScale.contained,
                            maxScale: PhotoViewComputedScale.covered * 3.0,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 1.h,
                      ),
                      OutlinedButton.icon(
                        label: Text(
                          "Download Job Post",
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(
                                color: kTextBlackColor,
                                fontSize: SizerUtil.deviceType ==
                                        DeviceType.mobile
                                    ? 10.sp
                                    : SizerUtil.deviceType == DeviceType.tablet
                                        ? 13.sp
                                        : SizerUtil.deviceType == DeviceType.web
                                            ? 5.sp
                                            : 10.sp,
                              ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.blueAccent),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        icon: const Icon(Icons.download,
                            color: Colors.blueAccent),
                        onPressed: () async {
                          try {
                            bool? isSaved = await saveDecodedImage(
                                base64Decode(widget.jobPostImage!));

                            if (isSaved != null &&
                                isSaved == true &&
                                context.mounted) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text(
                                      "Success",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .copyWith(
                                            color: kTextBlackColor,
                                            fontSize: SizerUtil.deviceType ==
                                                    DeviceType.mobile
                                                ? 10.sp
                                                : SizerUtil.deviceType ==
                                                        DeviceType.tablet
                                                    ? 13.sp
                                                    : SizerUtil.deviceType ==
                                                            DeviceType.web
                                                        ? 5.sp
                                                        : 10.sp,
                                          ),
                                    ),
                                    content: Text(
                                      "Image Downloaded",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .copyWith(
                                            color: kTextBlackColor,
                                            fontSize: SizerUtil.deviceType ==
                                                    DeviceType.mobile
                                                ? 10.sp
                                                : SizerUtil.deviceType ==
                                                        DeviceType.tablet
                                                    ? 13.sp
                                                    : SizerUtil.deviceType ==
                                                            DeviceType.web
                                                        ? 5.sp
                                                        : 10.sp,
                                          ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: Text(
                                          "OK",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium!
                                              .copyWith(
                                                color: kTextBlackColor,
                                                fontSize: SizerUtil
                                                            .deviceType ==
                                                        DeviceType.mobile
                                                    ? 10.sp
                                                    : SizerUtil.deviceType ==
                                                            DeviceType.tablet
                                                        ? 13.sp
                                                        : SizerUtil.deviceType ==
                                                                DeviceType.web
                                                            ? 5.sp
                                                            : 10.sp,
                                              ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                        title: Text(
                                          'Error',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium!
                                              .copyWith(
                                                color: kTextBlackColor,
                                                fontSize: SizerUtil
                                                            .deviceType ==
                                                        DeviceType.mobile
                                                    ? 10.sp
                                                    : SizerUtil.deviceType ==
                                                            DeviceType.tablet
                                                        ? 13.sp
                                                        : SizerUtil.deviceType ==
                                                                DeviceType.web
                                                            ? 5.sp
                                                            : 10.sp,
                                              ),
                                        ),
                                        content: Text(
                                          "Failed to download image.\n\nDetails:$e",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium!
                                              .copyWith(
                                                color: kTextBlackColor,
                                                fontSize: SizerUtil
                                                            .deviceType ==
                                                        DeviceType.mobile
                                                    ? 10.sp
                                                    : SizerUtil.deviceType ==
                                                            DeviceType.tablet
                                                        ? 13.sp
                                                        : SizerUtil.deviceType ==
                                                                DeviceType.web
                                                            ? 5.sp
                                                            : 10.sp,
                                              ),
                                        ),
                                        actions: [
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              child: Text(
                                                'Close',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium!
                                                    .copyWith(
                                                      color: kTextBlackColor,
                                                      fontSize: SizerUtil
                                                                  .deviceType ==
                                                              DeviceType.mobile
                                                          ? 10.sp
                                                          : SizerUtil.deviceType ==
                                                                  DeviceType
                                                                      .tablet
                                                              ? 13.sp
                                                              : SizerUtil.deviceType ==
                                                                      DeviceType
                                                                          .web
                                                                  ? 5.sp
                                                                  : 10.sp,
                                                    ),
                                              ))
                                        ],
                                      ));
                            }
                          }
                        },
                      )
                    ],
                  ),
                )),
            const Divider(),
            Row(
              children: [
                Icon(
                  Icons.calendar_month,
                  size: 5.w,
                  color: Colors.grey,
                ),
                SizedBox(
                  width: 2.h,
                ),
                Text(
                  'Deadline:${widget.applicationDeadline ?? "-"}',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: kTextBlackColor,
                        fontWeight: FontWeight.bold,
                        fontSize: SizerUtil.deviceType == DeviceType.mobile
                            ? 10.sp
                            : SizerUtil.deviceType == DeviceType.tablet
                                ? 13.sp
                                : SizerUtil.deviceType == DeviceType.web
                                    ? 5.sp
                                    : 10.sp,
                      ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
