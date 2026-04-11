import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'package:app/widgets/icon_box.dart';
import 'package:flutter_sficon/flutter_sficon.dart';

class BaseCard extends StatefulWidget {
  final IconData? icon;
  final dynamic trailingIcon;
  final Color? iconBackgroundColor;
  final String title;
  final String? subTitle;
  final TextStyle? style;
  final Color backgroundColor;
  final List<BoxShadow>? boxShadow;
  final double borderRadius;

  const BaseCard({
    super.key,
    this.icon,
    this.trailingIcon = const Icon(
      Icons.arrow_forward_ios_sharp,
      size: 16,
      color: Colors.black,
      fontWeight: FontWeight.bold,
    ),
    required this.title,
    this.subTitle,
    this.style,
    this.backgroundColor = AppColors.secondary,
    this.iconBackgroundColor,
    this.boxShadow,
    this.borderRadius = 12,
  });

  @override
  State<BaseCard> createState() => _BaseCardState();
}

class _BaseCardState extends State<BaseCard> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: Container(
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: widget.boxShadow,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          children: [
            if (widget.icon != null) ...[
              IconBox(
                icon: widget.icon!,
                backgroundColor: widget.iconBackgroundColor,
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.title,
                    style: widget.style ?? AppTextStyles.label,
                  ),
                  if (widget.subTitle != null)
                    Text(widget.subTitle!, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            if (widget.trailingIcon is Widget)
              widget.trailingIcon
            else
              SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}

class HeaderCard {
  final String title;
  final IconData icon;
  final Color backgroundColor;
  final Color iconBackgroundColor;
  final Widget? trailingIcon;

  const HeaderCard({
    required this.title,
    required this.icon,
    this.backgroundColor = AppColors.primary,
    this.iconBackgroundColor = AppColors.iconBackgroundColor,
    this.trailingIcon,
  });
}

class ChildCard {
  final String title;
  final String? subTitle;
  final IconData? icon;
  final Widget? trailingIcon;
  final VoidCallback? onTap;

  const ChildCard({
    required this.title,
    this.subTitle,
    this.icon,
    this.trailingIcon,
    this.onTap,
  });
}

class GroupedCard extends StatelessWidget {
  final HeaderCard header;
  final List<ChildCard> children;
  final double borderRadius;
  final Color? dividerColor;

  const GroupedCard({
    super.key,
    required this.header,
    this.children = const [],
    this.borderRadius = 12,
    this.dividerColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: AppShadows.boxLayered,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BaseCard(
              borderRadius: 0,
              title: header.title,
              icon: header.icon,
              backgroundColor: header.backgroundColor,
              iconBackgroundColor: header.iconBackgroundColor,
              trailingIcon: header.trailingIcon,
            ),
            ...children.expand(
              (child) => [
                Divider(color: dividerColor ?? AppColors.divider, height: 0),
                GestureDetector(
                  onTap: child.onTap,
                  child: BaseCard(
                    borderRadius: 0,
                    title: child.title,
                    subTitle: child.subTitle,
                    icon: child.icon,
                    trailingIcon: child.trailingIcon,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
