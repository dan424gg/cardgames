import 'package:flutter/material.dart';
import 'package:auto_route/annotations.dart';
import '../theme/app_theme.dart';
import '../widgets/app_title.dart';
import '../widgets/card.dart';
import 'package:flutter_sficon/flutter_sficon.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/services.dart';
import '../widgets/smart_text_field.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

@RoutePage(name: 'JoinGame')
class JoinGameScreen extends StatefulWidget {
  const JoinGameScreen({super.key});

  @override
  State<JoinGameScreen> createState() => _JoinGameScreenState();
}

class _JoinGameScreenState extends State<JoinGameScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        centerTitle: true,
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
                      title: "Game Code",
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
                                MaterialPinField(
                                  length: 4,
                                  onCompleted: (pin) {
                                    print('PIN: $pin');
                                    context.router.maybePop();
                                  },
                                  autoFocus: true,
                                ),
                              ],
                            ),
                            Text(
                              "Enter 4 digit session code from the host.",
                              style: AppTextStyles.bodySmall,
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
