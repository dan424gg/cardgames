import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'package:app/widgets/icon_box.dart';
import 'package:flutter_sficon/flutter_sficon.dart';

class BaseCard extends StatefulWidget {
  final IconData? icon;
  final Widget trailingIcon;
  final bool showTrailingIcon;
  final Color? iconBackgroundColor;
  final String? title;
  final String? subTitle;
  final TextStyle? style;
  final Color backgroundColor;
  final List<BoxShadow>? boxShadow;
  final double borderRadius;
  final VoidCallback? onTap;
  final Widget? content;

  const BaseCard({
    super.key,
    this.icon,
    this.trailingIcon = const Icon(
      Icons.arrow_forward_ios_sharp,
      size: 16,
      color: Colors.black,
      fontWeight: FontWeight.bold,
    ),
    this.showTrailingIcon = true,
    this.title,
    this.subTitle,
    this.style,
    this.backgroundColor = AppColors.secondary,
    this.iconBackgroundColor,
    this.boxShadow,
    this.borderRadius = 12,
    this.onTap,
    this.content,
  });

  @override
  State<BaseCard> createState() => _BaseCardState();
}

class _BaseCardState extends State<BaseCard> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.content != null ? null : 70,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: widget.boxShadow,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child:
              widget.content ??
              Row(
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
                          widget.title ?? "",
                          style: widget.style ?? AppTextStyles.label,
                        ),
                        if (widget.subTitle != null)
                          Text(
                            widget.subTitle!,
                            style: AppTextStyles.bodySmall,
                          ),
                      ],
                    ),
                  ),
                  if (widget.showTrailingIcon) widget.trailingIcon,
                ],
              ),
        ),
      ),
    );
  }
}

class CardList extends StatelessWidget {
  final BaseCard? header;
  final List<BaseCard> children;
  final BorderRadius borderRadius;
  final Color? dividerColor;

  const CardList({
    super.key,
    this.header,
    this.children = const [],
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.dividerColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: AppShadows.boxLayered,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            header != null ? header! : SizedBox.shrink(),
            ...children.expand(
              (child) => [
                Divider(color: dividerColor ?? AppColors.divider, height: 0),
                child,
              ],
            ),
          ],
        ),
      ),
    );
  }
}
