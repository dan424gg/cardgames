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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<CardItemModel> gameMenuItems = [
    CardItemModel(title: 'Cribbage', icon: SFIcons.sf_circle_grid_3x3_fill),
    CardItemModel(title: 'Rummy', icon: SFIcons.sf_suit_spade_fill),
    CardItemModel(title: 'Go Fish', icon: SFIcons.sf_fish_fill),
  ];

  final List<CardItemModel> gameplayOptions = [
    CardItemModel(title: 'Single Player', icon: SFIcons.sf_person_fill),
    CardItemModel(title: 'Pass and Play', icon: SFIcons.sf_person_3_fill),
    CardItemModel(
      title: 'Online',
      icon: SFIcons.sf_person_line_dotted_person_fill,
    ),
  ];

  final List<CardItemModel> onlineOptions = [
    CardItemModel(title: 'Start Game', icon: SFIcons.sf_play_fill),
    CardItemModel(title: 'Join Game', icon: SFIcons.sf_plus),
  ];

  final List<Map<String, bool>> _expanded = [
    {"type": false, "online": false},
    {"type": false, "online": false},
    {"type": false, "online": false},
  ];

  // --- Reusable helpers ---

  Widget _buildChevron(bool expanded) {
    return AnimatedRotation(
      turns: expanded ? 0.25 : 0,
      duration: AppAnimations.duration,
      curve: AppAnimations.curve,
      child: const Icon(
        Icons.arrow_forward_ios_sharp,
        size: 16,
        color: Colors.black,
      ),
    );
  }

  Widget _buildExpandableRow({
    required CardItemModel item,
    required bool expanded,
    required VoidCallback onTap,
    Color backgroundColor = AppColors.secondary,
    double borderRadius = 0,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: BaseCard(
        title: item.title,
        style: AppTextStyles.body,
        icon: item.icon,
        trailingIcon: _buildChevron(expanded),
        backgroundColor: backgroundColor,
        boxShadow: AppShadows.boxLayered,
        borderRadius: borderRadius,
      ),
    );
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
                itemCount: gameMenuItems.length,
                separatorBuilder: (_, index) => AnimatedContainer(
                  duration: AppAnimations.duration,
                  curve: AppAnimations.curve,
                  height: _expanded[index]["type"]! ? 0 : AppSpacing.spacing,
                ),
                itemBuilder: (_, index) => _buildGameCard(index),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Card builders ---

  Widget _buildGameCard(int gameIndex) {
    final game = gameMenuItems[gameIndex];
    final isExpanded = _expanded[gameIndex]["type"]!;

    final gameCard = GestureDetector(
      onTap: () => setState(() {
        final opening = !isExpanded;
        _expanded[gameIndex]["type"] = opening;
        if (!opening) _expanded[gameIndex]["online"] = false;
      }),
      child: BaseCard(
        icon: game.icon,
        trailingIcon: _buildChevron(isExpanded),
        title: game.title,
        backgroundColor: AppColors.primary,
        iconBackgroundColor: AppColors.secondary.withAlpha(153),
        boxShadow: AppShadows.boxLayered,
      ),
    );

    return AnimatedExpandable(
      header: gameCard,
      isExpanded: isExpanded,
      child: _buildGameTypeOptions(gameIndex),
    );
  }

  Widget _buildGameTypeOptions(int gameIndex) {
    final isOnlineExpanded = _expanded[gameIndex]["online"]!;

    final rows = gameplayOptions.map((option) {
      final isOnline = option.title == 'Online';
      return _buildExpandableRow(
        item: option,
        expanded: isOnline && isOnlineExpanded,
        onTap: isOnline
            ? () => setState(
                () => _expanded[gameIndex]["online"] = !isOnlineExpanded,
              )
            : () {}, // TODO: handle Single Player / Pass and Play navigation
      );
    }).toList();

    final gameTypeMenu = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.boxLayered,
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
        child: FractionallySizedBox(
          widthFactor: 0.90,
          child: Column(
            children: [
              Container(height: 2, color: Colors.white),
              ...rows,
            ],
          ),
        ),
      ),
    );

    return Stack(
      children: [
        if (isOnlineExpanded) _buildOnlineOptions(gameTypeMenu),
        gameTypeMenu,
      ],
    );
  }

  Widget _buildOnlineOptions(Widget placeholder) {
    return Column(
      children: [
        // Reserves the height of the gameTypeMenu above the online options
        Visibility(
          visible: false,
          maintainSize: true,
          maintainState: true,
          maintainAnimation: true,
          child: placeholder,
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: AppShadows.boxLayered,
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(12),
            ),
            child: FractionallySizedBox(
              widthFactor: 0.80,
              child: Column(
                children: [
                  Container(height: 2, color: Colors.white),
                  ...onlineOptions.map(
                    (option) => BaseCard(
                      title: option.title,
                      icon: option.icon,
                      trailingIcon: Icons.keyboard_arrow_right,
                      backgroundColor: AppColors.secondary,
                      boxShadow: AppShadows.boxLayered,
                      borderRadius: 0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CardItemModel {
  final String title;
  final IconData icon;

  CardItemModel({required this.title, required this.icon});
}
