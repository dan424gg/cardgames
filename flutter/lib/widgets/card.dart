import 'package:app/widgets/animated_expandable.dart';
import 'package:app/widgets/size_holder.dart';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'package:app/widgets/icon_box.dart';
import 'package:flutter_sficon/flutter_sficon.dart';

class InteractiveCard extends StatefulWidget {
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

  const InteractiveCard({
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
  State<InteractiveCard> createState() => _InteractiveCardState();
}

class _InteractiveCardState extends State<InteractiveCard> {
  @override
  Widget build(BuildContext context) {
    return BaseCard(
      backgroundColor: widget.backgroundColor,
      boxShadow: widget.boxShadow,
      borderRadius: widget.borderRadius,
      height: widget.content != null ? null : AppContainerConstraints.height,
      onTap: widget.onTap,
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
                      Text(widget.subTitle!, style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              if (widget.showTrailingIcon) widget.trailingIcon,
            ],
          ),
    );
  }
}

class CardList extends StatelessWidget {
  final Widget? header;
  final List<Widget> children;
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

/// A [CardList] where the last item can expand downward to reveal
/// additional content, while the card list itself overlays a placeholder
/// stack that reserves space for the expansion.
class ExpandableCardList extends StatelessWidget {
  const ExpandableCardList({
    super.key,
    required this.items,
    required this.expandableItem,
    required this.expandedChild,
    required this.isExpanded,
    this.header,
    this.widthFactor = 0.9,
    this.expandedChildWidthFactor = 0.8,
    this.borderRadius,
  });

  /// Header for the [CardList]
  final Widget? header;

  /// The non-expandable items shown above the expandable last item.
  final List<Widget> items;

  /// The widget used as the last (expandable) item in the card list.
  /// Also used as the header inside [AnimatedExpandable].
  final Widget expandableItem;

  /// The content revealed when expanded.
  final Widget expandedChild;

  final bool isExpanded;

  /// Width of the overlay [CardList] relative to available width.
  final double widthFactor;

  /// Width of the [expandedChild] relative to available width.
  final double expandedChildWidthFactor;

  /// Border radius applied to the overlay [CardList].
  final BorderRadius? borderRadius;

  BorderRadius get _defaultBorderRadius => BorderRadius.vertical(
    bottom: Radius.circular(AppContainerConstraints.borderRadius),
  );

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = borderRadius ?? _defaultBorderRadius;

    // The expandable item is reused in three places:
    //   1. As a transparent size-holder in the placeholder column (for spacing)
    //   2. As a transparent size-holder in the placeholder column (aligns with overlay)
    //   3. As the visible header inside AnimatedExpandable (drives the expansion)
    final placeholder = SizeHolder(child: expandableItem);

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        // Layer 1 — placeholder column that grows with the expansion,
        // pushing the Stack's intrinsic height downward.
        Column(
          children: [
            if (header != null) SizeHolder(child: header!),
            for (final item in items) SizeHolder(child: item),
            AnimatedExpandable(
              isExpanded: isExpanded,
              header: placeholder,
              child: FractionallySizedBox(
                widthFactor: expandedChildWidthFactor,
                child: expandedChild,
              ),
            ),
          ],
        ),

        // Layer 2 — the visible card list, floating on top of the placeholders.
        FractionallySizedBox(
          widthFactor: widthFactor,
          child: CardList(
            header: header,
            borderRadius: effectiveBorderRadius,
            children: [...items, expandableItem],
          ),
        ),
      ],
    );
  }
}

class BaseCard extends StatelessWidget {
  final Color backgroundColor;
  final Widget child;
  final double borderRadius;
  final List<BoxShadow>? boxShadow;
  final double? height;
  final VoidCallback? onTap;
  final Color? borderColor;

  const BaseCard({
    super.key,
    required this.backgroundColor,
    required this.child,
    this.borderRadius = AppContainerConstraints.borderRadius,
    this.boxShadow = AppShadows.boxLayered,
    this.height = AppContainerConstraints.height,
    this.onTap,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: height,
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            border: borderColor != null
                ? BoxBorder.all(color: borderColor!)
                : null,
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: boxShadow,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: child,
        ),
      ),
    );
  }
}
