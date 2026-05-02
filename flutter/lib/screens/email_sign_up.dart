import 'package:app/widgets/error_snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/annotations.dart';
import 'package:unique_names_generator/unique_names_generator.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_expandable.dart';
import '../widgets/app_title.dart';
import '../widgets/card.dart';
import 'package:flutter_sficon/flutter_sficon.dart';
import 'package:auto_route/auto_route.dart';
import '../widgets/smart_text_field.dart';

@RoutePage(name: 'EmailSignUp')
class EmailSignUp extends StatefulWidget {
  const EmailSignUp({super.key});

  @override
  State<EmailSignUp> createState() => _EmailSignUpState();
}

class _EmailSignUpState extends State<EmailSignUp> {
  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();
  bool _showRequirements = false;
  late String email;
  late String password;
  bool emailValidated = false;
  bool passwordValidated = false;

  final randomNameGenerator = UniqueNamesGenerator(
    config: Config(
      length: 2,
      dictionaries: [adjectives, animals],
      separator: "",
      style: .capital,
    ),
  );

  @override
  void initState() {
    super.initState();
    _passwordFocusNode.addListener(() {
      setState(() => _showRequirements = _passwordFocusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<UserCredential?> signUp() async {
    print("Signing up with email...");
    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await userCredential.user?.updateDisplayName(
        randomNameGenerator.generate(),
      );

      return userCredential;
    } on FirebaseAuthException catch (e) {
      final message = switch (e.code) {
        'weak-password' => 'The password provided is too weak.',
        'email-already-in-use' => 'The account already exists for that email.',
        _ => "Unknown error.",
      };

      if (context.mounted) {
        showErrorSnackBar(context, message: message);
      } else {
        print("Context isn't mounted???");
      }

      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        centerTitle: true,
        title: Padding(
          padding: .only(top: 15),
          child: AppTitle(
            text: 'Email Sign Up',
            style: AppTextStyles.pageTitle,
            strokeWidth: 1.5,
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            top: -kToolbarHeight,
            child: Center(
              child: SizedBox(
                width: 400,
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(
                    context,
                  ).copyWith(scrollbars: false),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(AppSpacing.padding),
                    physics: const ClampingScrollPhysics(),
                    child: Padding(
                      padding: .all(AppSpacing.padding),
                      child: Column(
                        spacing: AppSpacing.spacing,
                        children: [
                          CardList(
                            header: InteractiveCard(
                              backgroundColor: AppColors.primary,
                              iconBackgroundColor:
                                  AppColors.iconBackgroundColor,
                              title: "Type in Email and Password",
                              icon: SFIcons.sf_list_clipboard_fill,
                              showTrailingIcon: false,
                              borderRadius: 0,
                            ),
                            children: [
                              InteractiveCard(
                                borderRadius: 0,
                                content: Column(
                                  spacing: AppSpacing.spacing,
                                  mainAxisAlignment: .center,
                                  children: [
                                    Row(
                                      mainAxisAlignment: .center,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            spacing: AppSpacing.spacing,
                                            children: [
                                              // Track validation state in onChanged, not in validator
                                              TextFormField(
                                                autocorrect: false,
                                                enableSuggestions: false,
                                                textInputAction:
                                                    TextInputAction.next,
                                                autovalidateMode:
                                                    AutovalidateMode
                                                        .onUserInteraction,
                                                keyboardType:
                                                    TextInputType.emailAddress,
                                                onChanged: (value) {
                                                  final emailRegex = RegExp(
                                                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                                                  );
                                                  setState(() {
                                                    email = value;
                                                    emailValidated = emailRegex
                                                        .hasMatch(value);
                                                  });
                                                },
                                                validator: (value) {
                                                  final emailRegex = RegExp(
                                                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                                                  );
                                                  if (value == null ||
                                                      !emailRegex.hasMatch(
                                                        value,
                                                      )) {
                                                    return 'Enter a valid email address';
                                                  }
                                                  return null;
                                                },
                                                decoration: InputDecoration(
                                                  labelText: "Email",
                                                ),
                                              ),
                                              AnimatedExpandable(
                                                reverse: true,
                                                isExpanded: _showRequirements,
                                                header: PasswordField(
                                                  controller:
                                                      _passwordController,
                                                  focusNode: _passwordFocusNode,
                                                  textInputAction:
                                                      TextInputAction.next,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      password = value;
                                                    });
                                                  },
                                                  validator: (v) {
                                                    if (v == null ||
                                                        !_passwordStrong(v)) {
                                                      return 'Password does not meet requirements';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                                child: Column(
                                                  children: [
                                                    PasswordRequirementsPanel(
                                                      controller:
                                                          _passwordController,
                                                    ),
                                                    SizedBox(
                                                      height:
                                                          AppSpacing.spacing,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              PasswordField(
                                                label: 'Confirm Password',
                                                onChanged: (value) {
                                                  setState(() {
                                                    passwordValidated =
                                                        value ==
                                                        _passwordController
                                                            .text;
                                                  });
                                                },
                                                validator: (v) {
                                                  if (v !=
                                                      _passwordController
                                                          .text) {
                                                    return 'Passwords do not match';
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                showTrailingIcon: false,
                              ),
                            ],
                          ),
                          Container(
                            decoration: BoxDecoration(
                              boxShadow: AppShadows.boxLayered,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ElevatedButton(
                              onPressed: (emailValidated && passwordValidated)
                                  ? () {
                                      signUp();
                                      context.router.maybePop();
                                    }
                                  : null,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 15,
                                    ),
                                    child: Text("Continue"),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── PasswordField ─────────────────────────────────────────────────────────────

class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    this.controller,
    this.focusNode,
    this.label = 'Password',
    this.validator,
    this.onChanged,
    this.textInputAction = TextInputAction.done,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String label;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final TextInputAction textInputAction;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autocorrect: false,
      enableSuggestions: false,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      controller: widget.controller,
      focusNode: widget.focusNode,
      obscureText: _obscured,
      textInputAction: widget.textInputAction,
      validator: widget.validator,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        labelText: widget.label,
        suffixIcon: IconButton(
          icon: Icon(_obscured ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => _obscured = !_obscured),
          tooltip: _obscured ? 'Show password' : 'Hide password',
        ),
      ),
    );
  }
}

// ── PasswordRequirementsPanel ─────────────────────────────────────────────────

class PasswordRequirementsPanel extends StatefulWidget {
  const PasswordRequirementsPanel({super.key, required this.controller});

  final TextEditingController controller;

  @override
  State<PasswordRequirementsPanel> createState() =>
      _PasswordRequirementsPanelState();
}

class _PasswordRequirementsPanelState extends State<PasswordRequirementsPanel> {
  static const _requirements = [
    ('At least 8 characters', _minLength),
    ('Uppercase letter', _hasUpper),
    ('Lowercase letter', _hasLower),
    ('Number', _hasDigit),
    ('Special character', _hasSpecial),
  ];

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChange);
    super.dispose();
  }

  void _onTextChange() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = widget.controller.text;

    return FractionallySizedBox(
      widthFactor: 0.9,
      child: Column(
        children: [
          BaseCard(
            backgroundColor: Colors.white,
            height: null,
            child: Column(
              children: _requirements.map((r) {
                final passed = r.$2(text);
                final color = passed ? Colors.green : Colors.red;
                return Row(
                  children: [
                    Icon(
                      passed
                          ? Icons.check_circle_rounded
                          : Icons.remove_circle_rounded,
                      size: 16,
                      color: color,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      r.$1,
                      style: theme.textTheme.bodySmall?.copyWith(color: color),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

bool _minLength(String v) => v.length >= 8;
bool _hasUpper(String v) => v.contains(RegExp(r'[A-Z]'));
bool _hasLower(String v) => v.contains(RegExp(r'[a-z]'));
bool _hasDigit(String v) => v.contains(RegExp(r'[0-9]'));
bool _hasSpecial(String v) => v.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));
bool _passwordStrong(String v) =>
    _minLength(v) &&
    _hasUpper(v) &&
    _hasLower(v) &&
    _hasDigit(v) &&
    _hasSpecial(v);
