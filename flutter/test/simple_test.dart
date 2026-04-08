// Simple Flutter widget tests for the cards app
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/main.dart';
import 'package:app/theme/app_theme.dart';
import 'package:app/widgets/floating_suits_background.dart';
import 'package:app/widgets/card.dart';

void main() {
  testWidgets('MyApp renders correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app title is displayed
    expect(find.text('CARDS'), findsWidgets);

    // Verify that game cards are displayed
    expect(find.text('Cribbage'), findsWidgets);
    expect(find.text('Rummy'), findsWidgets);
    expect(find.text('Go Fish'), findsWidgets);
  });

  testWidgets('HomeScreen displays game cards', (WidgetTester tester) async {
    // Build the HomeScreen widget
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: SuitsBackgroundWrapper(child: const HomeScreen()),
      ),
    );

    // Verify the title is displayed
    expect(find.text('CARDS'), findsWidgets);

    // Verify all three game cards are present
    expect(find.text('Cribbage'), findsWidgets);
    expect(find.text('Rummy'), findsWidgets);
    expect(find.text('Go Fish'), findsWidgets);
  });

  testWidgets('GameExpansionState model works correctly', (
    WidgetTester tester,
  ) async {
    const initialState = GameExpansionState();
    expect(initialState.gameTypeExpanded, false);
    expect(initialState.onlineExpanded, false);

    final expandedState = initialState.copyWith(gameTypeExpanded: true);
    expect(expandedState.gameTypeExpanded, true);
    expect(expandedState.onlineExpanded, false);

    final fullyExpandedState = expandedState.copyWith(onlineExpanded: true);
    expect(fullyExpandedState.gameTypeExpanded, true);
    expect(fullyExpandedState.onlineExpanded, true);
  });

  testWidgets('GameEntry model works correctly', (WidgetTester tester) async {
    const cribbage = GameEntry(title: 'Cribbage', icon: Icons.circle);
    expect(cribbage.title, 'Cribbage');
    expect(cribbage.icon, Icons.circle);
  });

  test('GameExpansionState state transitions work correctly', () {
    // Test all state combinations
    const collapsed = GameExpansionState(
      gameTypeExpanded: false,
      onlineExpanded: false,
    );
    expect(collapsed.gameTypeExpanded, false);
    expect(collapsed.onlineExpanded, false);

    // Expand game type only
    final gameTypeOnly = collapsed.copyWith(gameTypeExpanded: true);
    expect(gameTypeOnly.gameTypeExpanded, true);
    expect(gameTypeOnly.onlineExpanded, false);

    // Can't have online expanded without gameType expanded (user constraint)
    // but the model allows it - testing the model's actual behavior
    final onlineOnly = collapsed.copyWith(onlineExpanded: true);
    expect(onlineOnly.gameTypeExpanded, false);
    expect(onlineOnly.onlineExpanded, true);

    // Both expanded
    final bothExpanded = collapsed.copyWith(
      gameTypeExpanded: true,
      onlineExpanded: true,
    );
    expect(bothExpanded.gameTypeExpanded, true);
    expect(bothExpanded.onlineExpanded, true);

    // Collapse from both
    final collapseBoth = bothExpanded.copyWith(
      gameTypeExpanded: false,
      onlineExpanded: false,
    );
    expect(collapseBoth.gameTypeExpanded, false);
    expect(collapseBoth.onlineExpanded, false);
  });

  testWidgets('AppTheme colors are defined', (WidgetTester tester) async {
    // Verify theme colors exist and are not null
    expect(AppColors.primary, isNotNull);
    expect(AppColors.secondary, isNotNull);
    expect(AppColors.background, isNotNull);
    expect(AppColors.textPrimary, isNotNull);

    // Verify theme text styles exist
    expect(AppTextStyles.title, isNotNull);
    expect(AppTextStyles.body, isNotNull);
    expect(AppTextStyles.label, isNotNull);
  });

  testWidgets('HomeScreen scaffold is rendered', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: SuitsBackgroundWrapper(child: const HomeScreen()),
      ),
    );

    // Verify the scaffold is present
    expect(find.byType(Scaffold), findsOneWidget);

    // Verify ListView is used for game cards
    expect(find.byType(ListView), findsOneWidget);

    // Verify SafeArea is used
    expect(find.byType(SafeArea), findsOneWidget);
  });

  testWidgets('Game cards have correct layout structure', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: SuitsBackgroundWrapper(child: const HomeScreen()),
      ),
    );

    // Verify BaseCard widgets are rendered for each game
    expect(find.byType(BaseCard), findsWidgets);

    // Verify Center widget is used for layout (there are multiple)
    expect(find.byType(Center), findsWidgets);

    // Verify SizedBox constraints are applied
    expect(find.byType(SizedBox), findsWidgets);

    // Verify Column is used for layout
    expect(find.byType(Column), findsWidgets);
  });
  testWidgets('Each game mode can be expanded and online options can be expanded', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: SuitsBackgroundWrapper(child: const HomeScreen()),
      ),
    );

    // Test each game (Cribbage, Rummy, Go Fish)
    final gameNames = ['Cribbage', 'Rummy', 'Go Fish'];

    for (final gameName in gameNames) {
      // Find and tap the game card
      // Use find.byType to get the GestureDetector that wraps the card
      final gameCardFinder = find
          .ancestor(
            of: find.text(gameName),
            matching: find.byType(GestureDetector),
          )
          .first;

      await tester.tap(gameCardFinder);
      // Use pump with longer duration instead of pumpAndSettle to avoid timeout
      await tester.pump(AppAnimations.duration);

      // Verify that game options are now visible
      expect(find.text('Single Player'), findsWidgets);
      expect(find.text('Pass and Play'), findsWidgets);
      expect(find.text('Online'), findsWidgets);

      // Verify we can interact with the visible option by tapping the Online card
      final onlineFinder = find.ancestor(
        of: find.text('Online'),
        matching: find.byType(GestureDetector),
      );

      if (onlineFinder.evaluate().isNotEmpty) {
        await tester.tap(onlineFinder.first);
        await tester.pump(AppAnimations.duration);

        // Verify online submenu options appear
        expect(find.text('Start Game'), findsWidgets);
        expect(find.text('Join Game'), findsWidgets);
      }

      // Collapse the game card
      await tester.tap(gameCardFinder);
      await tester.pump(AppAnimations.duration);
    }
  });
}
