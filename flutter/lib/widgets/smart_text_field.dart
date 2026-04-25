import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class InputField extends StatelessWidget {
  const InputField({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.autofocus = false,
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool autofocus;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        autofocus: autofocus,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(hintText: hintText),
      );
}

class PinField extends StatefulWidget {
  const PinField({
    super.key,
    this.focusNode,
    this.pinLength = 4,
    this.boxSize = 52.0,
    this.boxSpacing = 8.0,
    this.autofocus = false,
    this.onChanged,
    this.onCompleted,
  });

  final FocusNode? focusNode;
  final int pinLength;
  final double boxSize;
  final double boxSpacing;
  final bool autofocus;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;

  @override
  State<PinField> createState() => _PinFieldState();
}

class _PinFieldState extends State<PinField> {
  late final FocusNode _focusNode;
  final _controller = TextEditingController();
  bool _ownsFocusNode = false;
  bool _hasFocus = false;

  String get _pin => _controller.text;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _ownsFocusNode = widget.focusNode == null;
    _focusNode.addListener(() => setState(() => _hasFocus = _focusNode.hasFocus));
    _controller.addListener(() => setState(() {}));
    _focusNode.onKeyEvent = (_, event) {
      if (event is KeyDownEvent &&
          event.logicalKey == LogicalKeyboardKey.keyV &&
          (HardwareKeyboard.instance.isControlPressed || HardwareKeyboard.instance.isMetaPressed)) {
        _paste();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    };
    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _focusNode.onKeyEvent = null;
    if (_ownsFocusNode) _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _paste() async {
    final digits = ((await Clipboard.getData(Clipboard.kTextPlain))?.text ?? '')
        .replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return;
    final filled = digits.substring(0, digits.length.clamp(0, widget.pinLength));
    _controller.text = filled;
    _controller.selection = TextSelection.collapsed(offset: filled.length);
    widget.onChanged?.call(filled);
    if (filled.length == widget.pinLength) widget.onCompleted?.call(filled);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _focusNode.requestFocus(),
      onLongPress: _paste,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        children: [
          SizedBox(
            width: 0,
            height: 0,
            child: TextField(
              focusNode: _focusNode,
              controller: _controller,
              keyboardType: TextInputType.number,
              maxLength: widget.pinLength,
              enableInteractiveSelection: false,
              showCursor: false,
              style: const TextStyle(color: Colors.transparent),
              cursorColor: Colors.transparent,
              decoration: const InputDecoration(counterText: '', border: InputBorder.none),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (v) {
                widget.onChanged?.call(v);
                if (v.length == widget.pinLength) widget.onCompleted?.call(v);
              },
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(widget.pinLength, (i) => Padding(
              padding: EdgeInsets.only(right: i < widget.pinLength - 1 ? widget.boxSpacing : 0),
              child: _PinBox(
                digit: i < _pin.length ? _pin[i] : null,
                isActive: _hasFocus && i == _pin.length,
                isFilled: i < _pin.length,
                size: widget.boxSize,
              ),
            )),
          ),
        ],
      ),
    );
  }
}

class _PinBox extends StatelessWidget {
  const _PinBox({required this.size, this.digit, this.isActive = false, this.isFilled = false});

  final String? digit;
  final bool isActive;
  final bool isFilled;
  final double size;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : const Color.fromRGBO(242, 242, 247, 1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color.fromRGBO(198, 198, 200, 1),
          width: (isActive || isFilled) ? 2.0 : 1.0,
        ),
      ),
      child: Center(
        child: digit != null
            ? Text(digit!, style: AppTextStyles.body.copyWith(fontSize: size * 0.42))
            : isActive ? const _Cursor() : const SizedBox.shrink(),
      ),
    );
  }
}

class _Cursor extends StatefulWidget {
  const _Cursor();

  @override
  State<_Cursor> createState() => _CursorState();
}

class _CursorState extends State<_Cursor> with SingleTickerProviderStateMixin {
  late final AnimationController _blink;

  @override
  void initState() {
    super.initState();
    _blink = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);
  }

  @override
  void dispose() { _blink.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _blink,
    child: Container(
      width: 2, height: 20,
      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(1)),
    ),
  );
}