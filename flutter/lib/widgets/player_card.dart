import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Badge shown on bot/robot players (e.g. "Robot 1").
class RobotBadge extends StatelessWidget {
  final String label;

  const RobotBadge({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.tertiary.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
      ),
    );
  }
}

/// A single player row inside a player list section.
///
/// Shows a numbered avatar, player name/badge, and a drag handle.
/// [isBot] shows the [RobotBadge] next to the name.
/// [teamColor] tints the avatar background for team modes.
class PlayerCard extends StatelessWidget {
  final int index;
  final String name;
  final bool isBot;
  final String? robotLabel;
  final Color? teamColor;
  final VoidCallback? onOptions;

  const PlayerCard({
    super.key,
    required this.index,
    required this.name,
    this.isBot = false,
    this.robotLabel,
    this.teamColor,
    this.onOptions,
  });

  @override
  Widget build(BuildContext context) {
    final avatarColor = teamColor ?? AppColors.primary;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      child: Row(
        children: [
          // Number avatar
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: avatarColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$index',
              style: AppTextStyles.label.copyWith(fontSize: 12),
            ),
          ),
          const SizedBox(width: 10),
          // Name + optional badge
          Expanded(
            child: Row(
              children: [
                Text(name, style: AppTextStyles.label),
                if (isBot && robotLabel != null) ...[
                  const SizedBox(width: 6),
                  RobotBadge(label: robotLabel!),
                ],
              ],
            ),
          ),
          // Options / drag handle
          GestureDetector(
            onTap: onOptions,
            child: const Icon(Icons.drag_handle,
                size: 18, color: AppColors.tertiary),
          ),
        ],
      ),
    );
  }
}
