import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'player_card.dart';
import 'section.dart';

enum TeamId { a, b }

extension TeamIdExtension on TeamId {
  String get label => this == TeamId.a ? 'Team A' : 'Team B';
  Color get color => this == TeamId.a ? AppColors.teamA : AppColors.teamB;
  Color get accent =>
      this == TeamId.a ? AppColors.teamAAccent : AppColors.teamBAccent;
}

/// A team section containing a colored header and player list.
/// Used in the team variant of Cribbage Setup.
class TeamSection extends StatelessWidget {
  final TeamId team;
  final List<PlayerCard> players;
  final VoidCallback? onAddBots;

  const TeamSection({
    super.key,
    required this.team,
    required this.players,
    this.onAddBots,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Team header
        Container(
          decoration: BoxDecoration(
            color: team.color,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Icon(Icons.group, size: 16, color: team.accent),
              const SizedBox(width: 8),
              Text(
                team.label,
                style: AppTextStyles.sectionHeader.copyWith(color: team.accent),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        ...players.map(
          (p) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: p,
          ),
        ),
        AddBotsButton(onTap: onAddBots),
      ],
    );
  }
}
