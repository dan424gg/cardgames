import 'package:flutter/material.dart';
import 'widgets/floating_suits_background.dart';
import 'theme/app_theme.dart';
import 'widgets/card.dart';
import 'dart:io';
import 'widgets/app_title.dart';
import 'package:flutter_sficon/flutter_sficon.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter/foundation.dart';
import 'widgets/animated_expandable.dart';
import 'widgets/animated_chevron.dart';
import 'widgets/size_holder.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      size: Size(800, 600),
      minimumSize: Size(800, 600),
      center: true,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.theme,
      home: SuitsBackgroundWrapper(child: const HomeScreen()),
    );
  }
}

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
              child: ListView.separated(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.padding,
                  vertical: AppSpacing.padding,
                ),
                itemCount: _games.length,
                separatorBuilder: (_, _) =>
                    SizedBox(height: AppSpacing.spacing),
                itemBuilder: (_, index) => _buildGameCard(index),
              ),
            ),
          ],
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
      header: _TappableCard(
        title: game.title,
        icon: game.icon,
        expanded: state.gameTypeExpanded,
        backgroundColor: AppColors.primary,
        iconBackgroundColor: AppColors.secondary.withAlpha(153),
        onTap: () => _toggleGameType(index),
      ),
      child: _buildGameTypeOptions(index),
    );
  }

  Widget _buildGameTypeOptions(int index) {
    final state = _expansionStates[index];

    final onlineCard = _TappableCard(
      title: 'Online',
      icon: SFIcons.sf_person_line_dotted_person_fill,
      style: AppTextStyles.body,
      expanded: state.onlineExpanded,
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
              child: _SubMenu(
                widthFactor: 0.80,
                children: [
                  _TappableCard(
                    title: 'Start Game',
                    icon: SFIcons.sf_play_fill,
                    style: AppTextStyles.body,
                    trailingIcon: Icons.keyboard_arrow_right,
                    onTap: () {}, // TODO: handle navigation
                    borderRadius: 0,
                  ),
                  _TappableCard(
                    title: 'Join Game',
                    icon: SFIcons.sf_plus,
                    style: AppTextStyles.body,
                    trailingIcon: Icons.keyboard_arrow_right,
                    onTap: () {}, // TODO: handle navigation
                    borderRadius: 0,
                  ),
                ],
              ),
            ),
          ],
        ),

        _SubMenu(
          widthFactor: 0.90,
          children: [
            _TappableCard(
              title: 'Single Player',
              icon: SFIcons.sf_person_fill,
              style: AppTextStyles.body,
              onTap: () {}, // TODO: handle navigation
              borderRadius: 0,
            ),
            _TappableCard(
              title: 'Pass and Play',
              icon: SFIcons.sf_person_3_fill,
              style: AppTextStyles.body,
              onTap: () {}, // TODO: handle navigation
              borderRadius: 0,
            ),
            onlineCard,
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Private reusable widgets
// ---------------------------------------------------------------------------

/// A [BaseCard] wrapped in a [GestureDetector], with sensible defaults that
/// match the app's visual style.
class _TappableCard extends StatelessWidget {
  const _TappableCard({
    required this.title,
    required this.icon,
    required this.onTap,
    this.style,
    this.expanded = false,
    this.backgroundColor = AppColors.secondary,
    this.borderRadius = AppContainerConstraints.borderRadius,
    this.iconBackgroundColor,
    this.trailingIcon,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final TextStyle? style;
  final bool expanded;
  final Color backgroundColor;
  final double borderRadius;
  final Color? iconBackgroundColor;

  /// Provide a custom trailing icon; defaults to [AnimatedChevron].
  final dynamic trailingIcon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: BaseCard(
        title: title,
        icon: icon,
        style: style,
        trailingIcon: trailingIcon ?? AnimatedChevron(expanded: expanded),
        backgroundColor: backgroundColor,
        iconBackgroundColor: iconBackgroundColor,
        boxShadow: AppShadows.boxLayered,
        borderRadius: borderRadius,
      ),
    );
  }
}

/// A visually grouped column of sub-menu cards clipped with rounded bottom
/// corners and a white separator at the top.
class _SubMenu extends StatelessWidget {
  const _SubMenu({required this.children, required this.widthFactor});

  final List<Widget> children;
  final double widthFactor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.boxLayered,
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
        child: FractionallySizedBox(
          widthFactor: widthFactor,
          child: Column(
            children: [
              Container(height: 2, color: Colors.white),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}
