import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Large game code display (e.g. "XJ82K").
class GameCodeDisplay extends StatelessWidget {
  final String code;

  const GameCodeDisplay({super.key, required this.code});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(
          code.isEmpty ? '_ _ _ _ _' : code,
          style: AppTextStyles.title.copyWith(
            fontSize: 32,
            letterSpacing: 6,
            color: code.isEmpty ? AppColors.tertiary : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

/// Segmented code entry boxes (shown before the numpad on Join Game screen).
class CodeInputBoxes extends StatelessWidget {
  final String value;
  final int length;

  const CodeInputBoxes({
    super.key,
    required this.value,
    this.length = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (i) {
        final char = i < value.length ? value[i] : '';
        final isActive = i == value.length;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: 44,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isActive ? AppColors.toggleActive : AppColors.divider,
              width: isActive ? 2 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            char,
            style: AppTextStyles.title.copyWith(fontSize: 22),
          ),
        );
      }),
    );
  }
}

/// Numeric keypad used on the Join Game screen.
class Numpad extends StatelessWidget {
  final ValueChanged<String> onKeyTap;
  final VoidCallback onDelete;

  const Numpad({super.key, required this.onKeyTap, required this.onDelete});

  static const _keys = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['', '0', '⌫'],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _keys.map((row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((key) {
              if (key.isEmpty) return const SizedBox(width: 72, height: 44);
              return _NumpadKey(
                label: key,
                onTap: () => key == '⌫' ? onDelete() : onKeyTap(key),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}

class _NumpadKey extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _NumpadKey({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        width: 60,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: label == '⌫'
            ? const Icon(Icons.backspace_outlined,
                size: 18, color: AppColors.textSecondary)
            : Text(label, style: AppTextStyles.label.copyWith(fontSize: 18)),
      ),
    );
  }
}
