import 'package:flutter/material.dart';
import '../widgets/animated_expandable.dart';
import '../widgets/animated_chevron.dart';
import '../widgets/card.dart';
import '../theme/app_theme.dart';
import '../widgets/error_snackbar.dart';
import '../widgets/icon_box.dart';
import '../widgets/size_holder.dart';
import '../widgets/app_title.dart';
import 'package:flutter_sficon/flutter_sficon.dart';
import 'package:auto_route/auto_route.dart';

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------

class GameEntry {
  final String title;
  final IconData icon;

  const GameEntry({required this.title, required this.icon});
}

/// Tracks the two independent expand/collapse states for a single game card.
class GameExpansionState {
  final bool gameTypeExpanded;
  final bool onlineExpanded;

  const GameExpansionState({
    this.gameTypeExpanded = false,
    this.onlineExpanded = false,
  });

  GameExpansionState copyWith({bool? gameTypeExpanded, bool? onlineExpanded}) {
    return GameExpansionState(
      gameTypeExpanded: gameTypeExpanded ?? this.gameTypeExpanded,
      onlineExpanded: onlineExpanded ?? this.onlineExpanded,
    );
  }
}

// ---------------------------------------------------------------------------
// Home screen
// ---------------------------------------------------------------------------

@RoutePage(name: 'Home')
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const List<GameEntry> _games = [
    GameEntry(title: 'Cribbage', icon: SFIcons.sf_circle_grid_3x3_fill),
    GameEntry(title: 'Rummy', icon: SFIcons.sf_suit_spade_fill),
    GameEntry(title: 'Go Fish', icon: SFIcons.sf_fish_fill),
  ];

  late List<GameExpansionState> _expansionStates;

  @override
  void initState() {
    super.initState();
    _expansionStates = List.generate(
      _games.length,
      (_) => const GameExpansionState(),
    );
  }

  // --- Mutators ---

  void _toggleGameType(int index) {
    final current = _expansionStates[index];
    final opening = !current.gameTypeExpanded;
    setState(() {
      // Close all other games
      for (int i = 0; i < _expansionStates.length; i++) {
        if (i != index) {
          _expansionStates[i] = _expansionStates[i].copyWith(
            gameTypeExpanded: false,
            onlineExpanded: false,
          );
        }
      }
      // Toggle the current game
      _expansionStates[index] = current.copyWith(
        gameTypeExpanded: opening,
        // Collapse the online sub-menu whenever the parent collapses.
        onlineExpanded: opening ? current.onlineExpanded : false,
      );
    });
  }

  void _toggleOnline(int index) {
    final current = _expansionStates[index];
    setState(() {
      _expansionStates[index] = current.copyWith(
        onlineExpanded: !current.onlineExpanded,
      );
    });
  }

  // --- Layout ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(child: _buildLayout()),
    );
  }

  Widget _buildLayout() {
    return Center(
      child: SizedBox(
        width: 400,
        child: Padding(
          padding: .only(
            left: AppSpacing.padding,
            right: AppSpacing.padding,
            bottom: AppSpacing.padding,
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: AppSpacing.padding,
                  top: AppSpacing.padding + 20,
                  right: AppSpacing.padding,
                ),
                child: AppTitle(text: 'CARDS', style: AppTextStyles.title),
              ),
              Expanded(
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(
                    context,
                  ).copyWith(scrollbars: false),
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.padding),
                    physics: const ClampingScrollPhysics(),
                    itemCount: _games.length,
                    separatorBuilder: (_, _) =>
                        SizedBox(height: AppSpacing.spacing),
                    itemBuilder: (_, index) => _buildGameCard(index),
                  ),
                ),
              ),
              InteractiveCard(
                title: "Settings",
                backgroundColor: Colors.grey.shade300,
                iconBackgroundColor: AppColors.iconBackgroundColor,
                icon: SFIcons.sf_gearshape_fill,
                showTrailingIcon: false,
                boxShadow: AppShadows.boxLayered,
                onTap: () {
                  context.router.pushNamed('/settings');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Card builders ---

  Widget _buildGameCard(int index) {
    final game = _games[index];
    final state = _expansionStates[index];

    return AnimatedExpandable(
      isExpanded: state.gameTypeExpanded,
      header: InteractiveCard(
        title: game.title,
        icon: game.icon,
        trailingIcon: AnimatedChevron(expanded: state.gameTypeExpanded),
        backgroundColor: AppColors.primary,
        iconBackgroundColor: AppColors.iconBackgroundColor,
        onTap: () => _toggleGameType(index),
        boxShadow: AppShadows.boxLayered,
      ),
      child: _buildGameTypeOptions(index),
    );
  }

  Widget _buildGameTypeOptions(int index) {
    final state = _expansionStates[index];

    final onlineCard = InteractiveCard(
      title: 'Online',
      icon: SFIcons.sf_person_line_dotted_person_fill,
      style: AppTextStyles.body,
      trailingIcon: AnimatedChevron(expanded: state.onlineExpanded),
      onTap: () => _toggleOnline(index),
      borderRadius: 0,
    );

    return Stack(
      alignment: .topCenter,
      children: [
        Column(
          children: [
            SizeHolder(child: onlineCard),
            SizeHolder(child: onlineCard),
            AnimatedExpandable(
              isExpanded: state.onlineExpanded,
              header: SizeHolder(child: onlineCard),
              child: FractionallySizedBox(
                widthFactor: 0.8,
                child: CardList(
                  borderRadius: .vertical(
                    bottom: Radius.circular(
                      AppContainerConstraints.borderRadius,
                    ),
                  ),
                  children: [
                    InteractiveCard(
                      title: 'Start Game',
                      icon: SFIcons.sf_play_fill,
                      style: AppTextStyles.body,
                      onTap: () {}, // TODO: handle navigation
                      borderRadius: 0,
                    ),
                    InteractiveCard(
                      title: 'Join Game',
                      icon: SFIcons.sf_plus,
                      style: AppTextStyles.body,
                      onTap: () {
                        context.router.pushNamed('/joingame');
                      },
                      borderRadius: 0,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        FractionallySizedBox(
          widthFactor: 0.9,
          child: CardList(
            borderRadius: .vertical(
              bottom: Radius.circular(AppContainerConstraints.borderRadius),
            ),
            children: [
              InteractiveCard(
                title: 'Single Player',
                icon: SFIcons.sf_person_fill,
                style: AppTextStyles.body,
                onTap: () {}, // TODO: handle navigation
                borderRadius: 0,
              ),
              InteractiveCard(
                title: 'Pass and Play',
                icon: SFIcons.sf_person_3_fill,
                style: AppTextStyles.body,
                onTap: () {}, // TODO: handle navigation
                borderRadius: 0,
              ),
              onlineCard,
            ],
          ),
        ),
      ],
    );
  }
}
