import 'package:auto_size_text/auto_size_text.dart';
import 'package:divine_soul_yoga/src/presentation/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeDrawerTileWidget extends StatelessWidget {
  final String iconPath;
  final String text;
  final GestureTapCallback? onTap;
  final bool isSelected;

  const HomeDrawerTileWidget({
    required this.iconPath,
    required this.text,
    required this.onTap,
    required this.isSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor.withOpacity(0.2) : null,
          border: isSelected
              ? Border.all(
                  color: AppColors.primaryColor.withOpacity(0.5),
                )
              : null,
          borderRadius: BorderRadius.circular(2.r),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: 14.h,
            horizontal: 8.w,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: 6.w,
              ),
              SizedBox(
                height: 22.h,
                width: 22.w,
                child: Image.asset(
                  iconPath,
                  color: AppColors.primaryColor,
                ),
              ),
              SizedBox(width: 32.w),
              AutoSizeText(
                textScaleFactor: 1,
                minFontSize: 14,
                maxFontSize: 16,
                stepGranularity: 1,
                text,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
