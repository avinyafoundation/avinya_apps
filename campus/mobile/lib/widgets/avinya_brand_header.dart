import 'package:flutter/material.dart';
import 'package:mobile/constants.dart';
import 'package:mobile/widgets/avinya_logo_widget.dart';
import 'package:sizer/sizer.dart';

class AvinyaBrandHeaderWidget extends StatelessWidget {
  const AvinyaBrandHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white, // You can change this to any color
                width: 2,
              ),
            ),
            child: avinyaLogoImage()),
        SizedBox(
          width: 1.w,
        ),
        Column(
          children: [
            Text('AVINYA FOUNDATION',
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.normal,
                    color: kTextBlackColor,
                    letterSpacing: 0.8,
                    fontSize: SizerUtil.deviceType == DeviceType.mobile
                        ? 16.sp
                        : SizerUtil.deviceType == DeviceType.tablet
                            ? 18.sp
                            : SizerUtil.deviceType == DeviceType.web
                                ? 12.sp
                                : 14.sp),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            Text('Giving Hope.Creating Vision.Changing Lives.',
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.normal,
                    color: kTextBlackColor,
                    //letterSpacing: 1.2,
                    fontSize: SizerUtil.deviceType == DeviceType.mobile
                        ? 08.sp
                        : SizerUtil.deviceType == DeviceType.tablet
                            ? 10.sp
                            : SizerUtil.deviceType == DeviceType.web
                                ? 04.sp
                                : 06.sp),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ],
        )
      ],
    );
  }
}
