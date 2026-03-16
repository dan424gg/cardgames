import 'package:flutter/material.dart';
import 'widgets/floating_suits_background.dart';
import 'theme/app_theme.dart';
import 'widgets/action_card.dart';
import 'card.dart';
import 'widgets/app_title.dart';
import 'package:flutter_sficon/flutter_sficon.dart';

void main() {
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
    CardItemModel(title: 'Cribbage', icon: Icons.crib),
    CardItemModel(title: 'Rummy', icon: Icons.shuffle),
    CardItemModel(title: 'Go Fish', icon: Icons.water),
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

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 500;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Sidebar
        Container(
          width: 250,
          padding: EdgeInsets.only(
            left: AppSpacing.padding,
            top: AppSpacing.padding,
            bottom: AppSpacing.padding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.padding,
                  vertical: AppSpacing.padding,
                ),
                child: AppTitle(text: 'CARDS', style: AppTextStyles.title),
              ),
              SizedBox(height: AppSpacing.spacing),
              Expanded(
                child: ListView.separated(
                  itemCount: gameMenuItems.length,
                  separatorBuilder: (context, index) =>
                      SizedBox(height: AppSpacing.spacing),
                  itemBuilder: (context, index) {
                    return _buildGameCard(index);
                  },
                ),
              ),
            ],
          ),
        ),
        // Main content
        Expanded(
          child: Container(
            padding: EdgeInsets.all(AppSpacing.padding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AppTitle(text: 'Welcome to Cards', style: AppTextStyles.title),
                const SizedBox(height: AppSpacing.spacing),
                Text(
                  'Select a game to get started',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        // Header
        Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.padding,
            top: AppSpacing.padding + 20,
            right: AppSpacing.padding,
          ),
          child: AppTitle(text: 'CARDS', style: AppTextStyles.title),
        ),
        // Menu
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.padding,
              vertical: AppSpacing.padding,
            ),
            itemCount: gameMenuItems.length,
            separatorBuilder: (context, index) =>
                SizedBox(height: AppSpacing.spacing),
            itemBuilder: (context, index) {
              return _buildGameCard(index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGameCard(int gameIndex) {
    final game = gameMenuItems[gameIndex];

    Widget gameCard = BaseCard(
      icon: game.icon,
      trailingIcon: AnimatedRotation(
        turns: _expanded[gameIndex]["type"]! ? 0.25 : 0,
        duration: const Duration(milliseconds: 200),
        child: const Icon(
          Icons.keyboard_arrow_right,
          size: 18,
          color: AppColors.textSecondary,
        ),
      ),
      title: game.title,
      backgroundColor: AppColors.primary,
      iconBackgroundColor: AppColors.secondary.withAlpha(153),
      boxShadow: AppShadows.boxLayered,
    );

    return Stack(
      children: [
        if (_expanded[gameIndex]["type"]!)
          _buildGameTypeOptions(gameCard, gameIndex),
        GestureDetector(
          onTap: () => setState(
            () => _expanded[gameIndex]["type"] = !_expanded[gameIndex]["type"]!,
          ),
          child: gameCard,
        ),
      ],
    );
  }

  Widget _buildGameTypeOptions(Widget gameCard, int gameIndex) {
    Widget gameTypeOptions = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.boxLayered,
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
        child: FractionallySizedBox(
          widthFactor: 0.85,
          child: Column(
            children: [
              Container(height: 2, color: Colors.white),
              ...List.generate(gameplayOptions.length, (index) {
                final option = gameplayOptions[index];
                Widget onlineCard = Container(
                  decoration: BoxDecoration(
                    // borderRadius: BorderRadius.circular(12),
                    boxShadow: AppShadows.boxLayered,
                  ),
                  child: BaseCard(
                    title: option.title,
                    icon: option.icon,
                    trailingIcon: AnimatedRotation(
                      turns: _expanded[gameIndex]["online"]! ? 0.25 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(
                        Icons.keyboard_arrow_right,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    backgroundColor: AppColors.secondary,
                    boxShadow: AppShadows.boxLayered,
                    borderRadius: 0,
                  ),
                );

                if (option.title == "Online") {
                  return GestureDetector(
                    onTap: () => setState(
                      () => _expanded[gameIndex]["online"] =
                          !_expanded[gameIndex]["online"]!,
                    ),
                    child: onlineCard,
                  );
                } else {
                  return BaseCard(
                    title: option.title,
                    icon: option.icon,
                    trailingIcon: Icons.keyboard_arrow_right,
                    backgroundColor: AppColors.secondary,
                    boxShadow: AppShadows.boxLayered,
                    borderRadius: 0,
                  );
                }
              }),
            ],
          ),
        ),
      ),
    );
    return Column(
      children: [
        Visibility(
          visible: false,
          maintainSize: true,
          maintainState: true,
          maintainAnimation: true,
          child: gameCard,
        ),
        Stack(
          children: [
            if (_expanded[gameIndex]["online"]!)
              _buildOnlineOptions(gameTypeOptions, gameIndex),
            gameTypeOptions,
          ],
        ),
      ],
    );
  }

  Widget _buildOnlineOptions(Widget parent, int gameIndex) {
    return Column(
      children: [
        Visibility(
          visible: false,
          maintainSize: true,
          maintainState: true,
          maintainAnimation: true,
          child: parent,
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
              widthFactor: 0.65,
              child: Column(
                children: [
                  Container(height: 2, color: Colors.white),
                  ...List.generate(onlineOptions.length, (index) {
                    return BaseCard(
                      title: onlineOptions[index].title,
                      icon: onlineOptions[index].icon,
                      trailingIcon: Icons.keyboard_arrow_right,
                      backgroundColor: AppColors.secondary,
                      boxShadow: AppShadows.boxLayered,
                      borderRadius: 0,
                    );
                  }),
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
