import 'package:flutter/material.dart';
import '../cards_components.dart';

// ─────────────────────────────────────────
// MAIN SCREEN (Home)
// ─────────────────────────────────────────
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Cards',
      isRoot: true,
      trailing: IconButton(
        icon: const Icon(Icons.settings_outlined, size: 20),
        onPressed: () => Navigator.pushNamed(context, '/settings'),
      ),
      body: Column(
        children: [
          // Cribbage (expanded dropdown)
          ActionCard(
            icon: Icons.grid_4x4,
            title: 'Cribbage',
            variant: ActionCardVariant.dropdown,
            children: [
              SubButton(
                  title: 'Single Player', icon: Icons.person, onTap: () {}),
              SubButton(title: 'Pass & Play', icon: Icons.people, onTap: () {}),
              SubButton(title: 'Online', onTap: () {}),
              SubButton(title: 'Start Game', onTap: () {}),
              SubButton(title: 'Join Game', onTap: () {}),
            ],
          ),
          const SizedBox(height: 8),

          // Go Fish (collapsed)
          ActionCard(
            icon: Icons.waves,
            title: 'Go Fish',
            variant: ActionCardVariant.dropdown,
          ),
          const SizedBox(height: 8),

          // Rummy (expanded with sub-items)
          ActionCard(
            icon: Icons.style,
            title: 'Rummy',
            variant: ActionCardVariant.dropdown,
            children: [
              SubButton(
                  title: 'Single Player', icon: Icons.person, onTap: () {}),
              SubButton(title: 'Pass & Play', icon: Icons.people, onTap: () {}),
              SubButton(title: 'Online', onTap: () {}),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// SETTINGS SCREEN
// ─────────────────────────────────────────
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _music = true;
  bool _soundEffects = true;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Settings',
      body: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          // Sounds section
          Section(
            icon: Icons.volume_up_outlined,
            title: 'Sounds',
            children: [
              ActionCard(
                title: 'Music',
                subtitle: 'Toggle background music',
                variant: ActionCardVariant.toggle,
                toggleValue: _music,
                onToggle: (v) => setState(() => _music = v),
              ),
              ActionCard(
                title: 'Sound Effects',
                variant: ActionCardVariant.toggle,
                toggleValue: _soundEffects,
                onToggle: (v) => setState(() => _soundEffects = v),
              ),
            ],
          ),

          // Account section
          Section(
            icon: Icons.person_outline,
            title: 'Account',
            children: [
              ActionCard(
                title: 'Sign In',
                icon: Icons.login,
                variant: ActionCardVariant.dropdown,
                children: [
                  SubButton(
                    title: 'With Google',
                    icon: Icons.g_mobiledata,
                    onTap: () {},
                  ),
                  SubButton(
                    title: 'With Instagram',
                    icon: Icons.camera_alt_outlined,
                    onTap: () {},
                  ),
                  SubButton(
                    title: 'With Facebook',
                    icon: Icons.facebook,
                    onTap: () {},
                  ),
                ],
              ),
              ActionCard.bad(
                icon: Icons.logout,
                title: 'Sign Out',
                onTap: () {},
              ),
            ],
          ),

          // Buy me a coffee
          ActionCard(
            icon: Icons.coffee_outlined,
            title: 'Buy me a coffee',
            variant: ActionCardVariant.navigate,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// JOIN GAME SCREEN
// ─────────────────────────────────────────
class JoinGameScreen extends StatefulWidget {
  const JoinGameScreen({super.key});

  @override
  State<JoinGameScreen> createState() => _JoinGameScreenState();
}

class _JoinGameScreenState extends State<JoinGameScreen> {
  String _code = '';

  void _onKey(String k) {
    if (_code.length < 5) setState(() => _code += k);
  }

  void _onDelete() {
    if (_code.isNotEmpty)
      setState(() => _code = _code.substring(0, _code.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Join Game',
      body: Column(
        children: [
          Section(
            icon: Icons.grid_view,
            title: 'Game Code',
            children: [CodeInputBoxes(value: _code)],
          ),
          const SizedBox(height: 20),
          Numpad(onKeyTap: _onKey, onDelete: _onDelete),
          const SizedBox(height: 20),
          MainButton(
            title: 'Join Game',
            onTap: _code.length == 5 ? () {} : null,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// CRIBBAGE SETUP SCREEN (Teams mode)
// ─────────────────────────────────────────
class CribbageSetupScreen extends StatefulWidget {
  const CribbageSetupScreen({super.key});

  @override
  State<CribbageSetupScreen> createState() => _CribbageSetupScreenState();
}

class _CribbageSetupScreenState extends State<CribbageSetupScreen> {
  bool _useJokers = true;
  bool _allowMulligans = true;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Cribbage Setup',
      body: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Game Code
              Expanded(
                child: Section(
                  icon: Icons.grid_view,
                  title: 'Game Code',
                  children: [
                    GameCodeDisplay(code: 'XJ82K'),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Game Rules
              Expanded(
                child: Section(
                  icon: Icons.rule,
                  title: 'Game Rules',
                  children: [
                    ActionCard(
                      title: 'Use Jokers',
                      subtitle: 'Adds joker cards',
                      variant: ActionCardVariant.toggle,
                      toggleValue: _useJokers,
                      onToggle: (v) => setState(() => _useJokers = v),
                    ),
                    ActionCard(
                      title: 'Allow Mulligans',
                      variant: ActionCardVariant.toggle,
                      toggleValue: _allowMulligans,
                      onToggle: (v) => setState(() => _allowMulligans = v),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Team A
          TeamSection(
            team: TeamId.a,
            players: const [
              PlayerCard(index: 1, name: 'Player One'),
              PlayerCard(
                  index: 2,
                  name: 'Player Two',
                  isBot: true,
                  robotLabel: 'Robot 1'),
            ],
            onAddBots: () {},
          ),
          const SizedBox(height: 8),

          // Team B
          TeamSection(
            team: TeamId.b,
            players: const [
              PlayerCard(index: 1, name: 'Player One'),
              PlayerCard(
                  index: 2,
                  name: 'Player Two',
                  isBot: true,
                  robotLabel: 'Robot 1'),
            ],
            onAddBots: () {},
          ),
          const SizedBox(height: 20),

          MainButton(title: 'Ready', onTap: () {}),
        ],
      ),
    );
  }
}
