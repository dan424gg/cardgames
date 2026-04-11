import 'package:flutter/material.dart';
import 'package:auto_route/annotations.dart';
import '../theme/app_theme.dart';
import '../widgets/app_title.dart';
import '../widgets/card.dart';
import 'package:flutter_sficon/flutter_sficon.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage(name: 'Settings')
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool light = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(SFIcons.sf_chevron_backward),
          onPressed: () {
            context.router.maybePop();
          },
        ),
        title: Padding(
          padding: .only(top: 15),
          child: AppTitle(
            text: 'Settings',
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
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(
                context,
              ).copyWith(scrollbars: false),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppSpacing.padding),
                physics: const ClampingScrollPhysics(),
                child: Column(
                  spacing: AppSpacing.spacing,
                  children: [
                    GroupedCard(
                      header: HeaderCard(
                        title: "Sounds",
                        icon: SFIcons.sf_speaker_wave_3_fill,
                      ),
                      children: [
                        ChildCard(
                          title: "Music",
                          subTitle: "Toggle in-game music",
                          trailingIcon: Switch(
                            value: light,
                            trackOutlineWidth:
                                WidgetStateProperty.resolveWith<double?>(
                                  (_) => 1.0,
                                ),
                            activeThumbColor: Colors.white,
                            activeTrackColor: Colors.green,
                            onChanged: (bool value) =>
                                setState(() => light = value),
                          ),
                        ),
                        ChildCard(
                          title: "Motion",
                          subTitle: "Toggle motion (ie. background suits)",
                          trailingIcon: Switch(
                            value: light,
                            trackOutlineWidth:
                                WidgetStateProperty.resolveWith<double?>(
                                  (_) => 1.0,
                                ),
                            activeThumbColor: Colors.white,
                            activeTrackColor: Colors.green,
                            onChanged: (bool value) =>
                                setState(() => light = value),
                          ),
                        ),
                      ],
                    ),
                    GroupedCard(
                      header: HeaderCard(
                        title: "Sign In",
                        icon: SFIcons.sf_checkmark_circle_fill,
                      ),
                      children: [
                        ChildCard(
                          title: "Google",
                          icon: SFIcons.sf_g_circle_fill,
                        ),
                        ChildCard(
                          title: "Facebook",
                          icon: SFIcons.sf_f_circle_fill,
                        ),
                        ChildCard(title: "Email", icon: SFIcons.sf_mail_fill),
                      ],
                    ),
                    GroupedCard(
                      header: HeaderCard(
                        title: "Buy me a Coffee",
                        icon: SFIcons.sf_cup_and_heat_waves_fill,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
