import 'package:flutter/material.dart';
import 'package:app/floating_suits_background.dart';
import 'package:app/card_components/cards_components.dart';

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
  final List<GameMenuItemModel> gameMenuItems = [
    GameMenuItemModel(title: 'Cribbage', icon: Icons.crib),
    GameMenuItemModel(title: 'Rummy', icon: Icons.shuffle),
    GameMenuItemModel(title: 'Go Fish', icon: Icons.water),
  ];

  final List<String> gameplayOptions = [
    'Single Player',
    'Pass and Play',
    'Online',
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
                child: AppTitle(text: 'CARDS'),
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
                const Text(
                  'Welcome to Cards',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 45,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontFamily: 'LuckiestGuy',
                    height: 0.9,
                  ),
                ),
                const SizedBox(height: AppSpacing.spacing),
                Text(
                  'Select a game to get started',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 18,
                    color: AppColors.textSecondary,
                    height: 0.9,
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
          padding: EdgeInsets.all(AppSpacing.padding),
          child: AppTitle(text: 'CARDS'),
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

    return ActionCard(
      icon: game.icon,
      title: game.title,
      backgroundColor: AppColors.primary,
      iconBackgroundColor: AppColors.secondary.withAlpha(153),
      variant: ActionCardVariant.dropdown,
      children: gameplayOptions
          .map((option) => _buildGameplayOption(game.title, option))
          .toList(),
    );
  }

  Widget _buildGameplayOption(String gameName, String option) {
    final isOnline = option == 'Online';

    if (isOnline) {
      return ActionCard(
        icon: Icons.cloud,
        title: option,
        backgroundColor: AppColors.secondary,
        variant: ActionCardVariant.dropdown,
        children: [
          _buildOnlineOption(gameName, 'Start Game', Icons.play_arrow),
          _buildOnlineOption(gameName, 'Join Game', Icons.login),
        ],
      );
    } else {
      return ActionCard(
        icon: option == 'Single Player' ? Icons.person : Icons.groups,
        title: option,
        backgroundColor: AppColors.primary,
        variant: ActionCardVariant.action,
        onTap: () {
          _handleGameplayTap(gameName, option);
        },
      );
    }
  }

  Widget _buildOnlineOption(String gameName, String option, IconData icon) {
    return ActionCard(
      icon: icon,
      title: option,
      backgroundColor: AppColors.secondary,
      variant: ActionCardVariant.action,
      onTap: () {
        _handleGameplayTap(gameName, 'Online - $option');
      },
    );
  }

  void _handleGameplayTap(String gameName, String option) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$gameName - $option')));
  }
}

class GameMenuItemModel {
  final String title;
  final IconData icon;

  GameMenuItemModel({required this.title, required this.icon});
}
