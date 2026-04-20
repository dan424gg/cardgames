import 'package:app/widgets/animated_chevron.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../widgets/app_title.dart';
import '../widgets/card.dart';
import 'package:flutter_sficon/flutter_sficon.dart';
import 'package:auto_route/auto_route.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/animated_expandable.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../widgets/error_snackbar.dart';
import 'package:unique_names_generator/unique_names_generator.dart';
import 'package:pinput/pinput.dart';

//

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

@RoutePage(name: 'JoinGame')
class JoinGameScreen extends StatefulWidget {
  const JoinGameScreen({super.key});

  @override
  State<JoinGameScreen> createState() => _JoinGameScreenState();
}

class _JoinGameScreenState extends State<JoinGameScreen> {
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Padding(
          padding: .only(top: 15),
          child: AppTitle(
            text: 'Join Game',
            style: AppTextStyles.pageTitle,
            strokeWidth: 1.5,
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Container(
          alignment: .topCenter,
          child: SizedBox(
            width: 400,
            child: SmartTextField(
              mode: SmartTextFieldMode.pin,
              pinLength: 6,
              pinBoxSize: 48,
              autoFocus: false,
              animationCurve: Curves.fastEaseInToSlowEaseOut,
              animationDuration: Duration(milliseconds: 400),
              onPinCompleted: (pin) => print('PIN: $pin'),
            ),
            // child: CardList(
            //   header: BaseCard(
            //     backgroundColor: AppColors.primary,
            //     iconBackgroundColor: AppColors.iconBackgroundColor,
            //     title: "Game Code",
            //     icon: SFIcons.sf_list_clipboard_fill,
            //     showTrailingIcon: false,
            //     borderRadius: 0,
            //   ),
            //   children: [
            //     BaseCard(
            //       borderRadius: 0,
            //       content:
            //       showTrailingIcon: false,
            //     ),
            //   ],
            // ),
          ),
        ),
      ),
    );
  }
}


// ---------------------------------------------------------------------------
// SmartTextField
// ---------------------------------------------------------------------------
// A versatile text field that works in two modes:
//   • [SmartTextFieldMode.text]  – standard string input (email, password, …)
//   • [SmartTextFieldMode.pin]   – Pinput-style segmented numeric input
//
// Animation behaviour (focus gain/loss) is fully configurable via
// [animationCurve] and [animationDuration].
// ---------------------------------------------------------------------------

enum SmartTextFieldMode { text, pin }

class SmartTextField extends StatefulWidget {
  const SmartTextField({
    super.key,

    // ── shared ──────────────────────────────────────────────────────────────
    this.mode = SmartTextFieldMode.text,
    this.autoFocus = false,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.animationCurve = Curves.easeOutCubic,
    this.animationDuration = const Duration(milliseconds: 200),

    // ── text mode ───────────────────────────────────────────────────────────
    this.controller,
    this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.prefixIcon,
    this.suffixIcon,

    // ── pin mode ─────────────────────────────────────────────────────────────
    this.pinLength = 4,
    this.onPinCompleted,
    this.pinBoxSize = 52.0,
    this.pinBoxSpacing = 8.0,
  });

  // ── shared ────────────────────────────────────────────────────────────────
  final SmartTextFieldMode mode;
  final bool autoFocus;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Curve animationCurve;
  final Duration animationDuration;

  // ── text mode ─────────────────────────────────────────────────────────────
  final TextEditingController? controller;
  final String? hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int maxLines;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  // ── pin mode ──────────────────────────────────────────────────────────────
  final int pinLength;
  final ValueChanged<String>? onPinCompleted;
  final double pinBoxSize;
  final double pinBoxSpacing;

  @override
  State<SmartTextField> createState() => _SmartTextFieldState();
}

class _SmartTextFieldState extends State<SmartTextField>
    with SingleTickerProviderStateMixin {
  late final FocusNode _focusNode;
  late final TextEditingController _controller;
  bool _hasFocus = false;

  // Owns controller/focusNode only when the caller did not provide them.
  bool _ownsController = false;
  bool _ownsFocusNode = false;

  @override
  void initState() {
    super.initState();

    _focusNode = widget.focusNode ?? FocusNode();
    _ownsFocusNode = widget.focusNode == null;

    _controller = widget.controller ?? TextEditingController();
    _ownsController = widget.controller == null;

    _focusNode.addListener(_onFocusChange);

    if (widget.autoFocus) {
      // Defer so the widget tree is fully built first.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (_ownsFocusNode) _focusNode.dispose();
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() => _hasFocus = _focusNode.hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    return switch (widget.mode) {
      SmartTextFieldMode.text => _TextInput(
          focusNode: _focusNode,
          controller: _controller,
          hasFocus: _hasFocus,
          hintText: widget.hintText,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          maxLines: widget.maxLines,
          prefixIcon: widget.prefixIcon,
          suffixIcon: widget.suffixIcon,
          animationCurve: widget.animationCurve,
          animationDuration: widget.animationDuration,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
        ),
      SmartTextFieldMode.pin => _PinInput(
          focusNode: _focusNode,
          controller: _controller,
          hasFocus: _hasFocus,
          pinLength: widget.pinLength,
          boxSize: widget.pinBoxSize,
          boxSpacing: widget.pinBoxSpacing,
          animationCurve: widget.animationCurve,
          animationDuration: widget.animationDuration,
          onChanged: widget.onChanged,
          onCompleted: widget.onPinCompleted,
        ),
    };
  }
}

// ---------------------------------------------------------------------------
// _TextInput  (text / email / password mode)
// ---------------------------------------------------------------------------

class _TextInput extends StatelessWidget {
  const _TextInput({
    required this.focusNode,
    required this.controller,
    required this.hasFocus,
    required this.animationCurve,
    required this.animationDuration,
    this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
  });

  final FocusNode focusNode;
  final TextEditingController controller;
  final bool hasFocus;
  final Curve animationCurve;
  final Duration animationDuration;
  final String? hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int maxLines;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: hasFocus ? 1.0 : 0.0),
      duration: animationDuration,
      curve: animationCurve,
      builder: (context, t, child) {
        // Clamp to [0,1] so overshoot curves never produce negative blur/width.
        final ct = t.clamp(0.0, 1.0);
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Color.lerp(colorScheme.outline, colorScheme.primary, ct)!,
              width: 1 + ct, // 1 → 2
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withOpacity(0.15 * ct),
                blurRadius: (8 * ct).clamp(0.0, double.infinity),
                spreadRadius: ct,
              ),
            ],
          ),
          child: child,
        );
      },
      child: TextField(
        focusNode: focusNode,
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        maxLines: maxLines,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _PinInput  (Pinput-style segmented numeric input)
// ---------------------------------------------------------------------------

class _PinInput extends StatefulWidget {
  const _PinInput({
    required this.focusNode,
    required this.controller,
    required this.hasFocus,
    required this.pinLength,
    required this.boxSize,
    required this.boxSpacing,
    required this.animationCurve,
    required this.animationDuration,
    this.onChanged,
    this.onCompleted,
  });

  final FocusNode focusNode;
  final TextEditingController controller;
  final bool hasFocus;
  final int pinLength;
  final double boxSize;
  final double boxSpacing;
  final Curve animationCurve;
  final Duration animationDuration;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;

  @override
  State<_PinInput> createState() => _PinInputState();
}

class _PinInputState extends State<_PinInput> {
  String get _pin => widget.controller.text;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);

    widget.focusNode.onKeyEvent = (node, event) {
      if (event is KeyDownEvent &&
          event.logicalKey == LogicalKeyboardKey.keyV &&
          (HardwareKeyboard.instance.isControlPressed ||
              HardwareKeyboard.instance.isMetaPressed)) {
        _paste();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    };
  }

  @override
  void dispose() {
    widget.focusNode.onKeyEvent = null;
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() => setState(() {});

  void _onTap() => widget.focusNode.requestFocus();

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (text == null || text.isEmpty) return;

    // Strip non-digits and truncate to pinLength.
    final digits = text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return;

    final filled = digits.substring(
      0,
      digits.length.clamp(0, widget.pinLength),
    );
    widget.controller.text = filled;
    widget.controller.selection =
        TextSelection.collapsed(offset: filled.length);

    widget.onChanged?.call(filled);
    if (filled.length == widget.pinLength) {
      widget.onCompleted?.call(filled);
    }
  }

  void _showPasteMenu(BuildContext context, Offset globalPosition) {
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        globalPosition & Size.zero,
        Offset.zero & overlay.size,
      ),
      items: const [
        PopupMenuItem(value: 'paste', child: Text('Paste')),
      ],
    ).then((value) {
      if (value == 'paste') _paste();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      onLongPress: _paste,
      onSecondaryTapDown: (d) => _showPasteMenu(context, d.globalPosition),
      behavior: HitTestBehavior.opaque,
      child: Stack(
        children: [
          // Invisible TextField that owns keyboard input.
          _HiddenTextField(
            focusNode: widget.focusNode,
            controller: widget.controller,
            pinLength: widget.pinLength,
            onChanged: (value) {
              widget.onChanged?.call(value);
              if (value.length == widget.pinLength) {
                widget.onCompleted?.call(value);
              }
            },
          ),

          // Visible segmented boxes.
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(widget.pinLength, (index) {
              return Padding(
                padding: EdgeInsets.only(
                  right: index < widget.pinLength - 1 ? widget.boxSpacing : 0,
                ),
                child: _PinBox(
                  digit: index < _pin.length ? _pin[index] : null,
                  isActive: widget.hasFocus && index == _pin.length,
                  isFilled: index < _pin.length,
                  size: widget.boxSize,
                  animationCurve: widget.animationCurve,
                  animationDuration: widget.animationDuration,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _HiddenTextField  – captures keyboard input without being visible
// ---------------------------------------------------------------------------

class _HiddenTextField extends StatelessWidget {
  const _HiddenTextField({
    required this.focusNode,
    required this.controller,
    required this.pinLength,
    this.onChanged,
  });

  final FocusNode focusNode;
  final TextEditingController controller;
  final int pinLength;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 0,
      height: 0,
      child: TextField(
        focusNode: focusNode,
        controller: controller,
        keyboardType: TextInputType.number,
        maxLength: pinLength,
        obscureText: false,
        enableInteractiveSelection: false,
        showCursor: false,
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
        ),
        style: const TextStyle(color: Colors.transparent),
        cursorColor: Colors.transparent,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: onChanged,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _PinBox  – a single animated digit cell
// ---------------------------------------------------------------------------

class _PinBox extends StatelessWidget {
  const _PinBox({
    required this.size,
    required this.animationCurve,
    required this.animationDuration,
    this.digit,
    this.isActive = false,
    this.isFilled = false,
  });

  final String? digit;
  final bool isActive;
  final bool isFilled;
  final double size;
  final Curve animationCurve;
  final Duration animationDuration;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final borderColor = switch ((isActive, isFilled)) {
      (true, _) => colorScheme.primary,
      (_, true) => colorScheme.primary.withOpacity(0.6),
      _ => colorScheme.outline,
    };

    final borderWidth = (isActive || isFilled) ? 2.0 : 1.0;

    final bgColor = isFilled
        ? colorScheme.primary.withOpacity(0.07)
        : colorScheme.surface;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: isActive ? 1.0 : 0.0),
      duration: animationDuration,
      curve: animationCurve,
      builder: (context, t, child) {
        // Clamp so overshoot curves (elastic, bounce) never yield negative blur.
        final ct = t.clamp(0.0, 1.0);
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor, width: borderWidth),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withOpacity(0.2 * ct),
                blurRadius: 8 * ct,
                spreadRadius: ct,
              ),
            ],
          ),
          child: child,
        );
      },
      child: Center(
        child: AnimatedSwitcher(
          duration: animationDuration,
          switchInCurve: animationCurve,
          switchOutCurve: animationCurve,
          transitionBuilder: (child, animation) => ScaleTransition(
            scale: animation,
            child: FadeTransition(opacity: animation, child: child),
          ),
          child: digit != null
              ? Text(
                  digit!,
                  key: ValueKey(digit),
                  style: TextStyle(
                    fontSize: size * 0.42,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                )
              : isActive
                  ? _Cursor(
                      color: colorScheme.primary,
                      animationDuration: animationDuration,
                    )
                  : const SizedBox.shrink(),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _Cursor  – blinking caret shown in the active empty cell
// ---------------------------------------------------------------------------

class _Cursor extends StatefulWidget {
  const _Cursor({required this.color, required this.animationDuration});

  final Color color;
  final Duration animationDuration;

  @override
  State<_Cursor> createState() => _CursorState();
}

class _CursorState extends State<_Cursor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _blink;

  @override
  void initState() {
    super.initState();
    _blink = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _blink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _blink,
      child: Container(
        width: 2,
        height: 20,
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}