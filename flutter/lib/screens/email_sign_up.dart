import 'package:flutter/material.dart';
import 'package:auto_route/annotations.dart';
import '../theme/app_theme.dart';
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
            top: -kToolbarHeight, // offset back up by AppBar height
            child: Center(
              child: SizedBox(
                width: 400,
                child: Padding(
                  padding: .all(AppSpacing.padding),
                  child: CardList(
                    header: InteractiveCard(
                      backgroundColor: AppColors.primary,
                      iconBackgroundColor: AppColors.iconBackgroundColor,
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
                                  child: TextFormField(
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    keyboardType: TextInputType.emailAddress,
                                    cursorColor: Colors.black,
                                    validator: (value) {
                                      if (value != null) {
                                        // Regex for basic email validation
                                        final emailRegex = RegExp(
                                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                                        );
                                        if (!emailRegex.hasMatch(value)) {
                                          return 'Enter a valid email address';
                                        }
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      labelText: "Email",
                                      labelStyle: AppTextStyles.body,
                                      filled: true,
                                      fillColor: const Color.fromRGBO(
                                        242,
                                        242,
                                        247,
                                        1,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Color.fromRGBO(
                                            198,
                                            198,
                                            200,
                                            1,
                                          ),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Color.fromRGBO(
                                            198,
                                            198,
                                            200,
                                            1,
                                          ), 
                                          width: 1.5,
                                        ),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Colors.red,
                                          width: 1.5,
                                        ),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Colors.red,
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                    onFieldSubmitted: (value) {
                                      print("Email: $value");
                                    },
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
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
