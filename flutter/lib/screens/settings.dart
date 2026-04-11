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
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: AppShadows.boxLayered,
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(12),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            BaseCard(
                              borderRadius: 0,
                              title: "Sounds",
                              icon: SFIcons.sf_speaker_wave_3_fill,
                              backgroundColor: AppColors.primary,
                              iconBackgroundColor: AppColors.secondary
                                  .withAlpha(153),
                              trailingIcon: null,
                            ),
                            Divider(color: AppColors.divider, height: 0),
                            BaseCard(
                              borderRadius: 0,
                              title: "Music",
                              subTitle: "Toggle in-game music",
                              trailingIcon: Switch(
                                value: light,
                                trackOutlineWidth:
                                    WidgetStateProperty.resolveWith<double?>((
                                      Set<WidgetState> states,
                                    ) {
                                      return 1.0;
                                    }),
                                activeThumbColor: Colors.white,
                                activeTrackColor: Colors.green,
                                onChanged: (bool value) {
                                  setState(() {
                                    light = value;
                                  });
                                },
                              ),
                            ),
                            Divider(color: AppColors.divider, height: 0),
                            BaseCard(
                              borderRadius: 0,
                              title: "Motion",
                              subTitle: "Toggle motion (ie. background suits)",
                              trailingIcon: Switch(
                                value: light,
                                trackOutlineWidth:
                                    WidgetStateProperty.resolveWith<double?>((
                                      Set<WidgetState> states,
                                    ) {
                                      return 1.0;
                                    }),
                                activeThumbColor: Colors.white,
                                activeTrackColor: Colors.green,
                                onChanged: (bool value) {
                                  setState(() {
                                    light = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: AppShadows.boxLayered,
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(12),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            BaseCard(
                              borderRadius: 0,
                              title: "Sign In",
                              icon: SFIcons.sf_checkmark_circle_fill,
                              backgroundColor: AppColors.primary,
                              iconBackgroundColor: AppColors.secondary
                                  .withAlpha(153),
                              trailingIcon: null,
                            ),
                            Divider(color: AppColors.divider, height: 0),
                            BaseCard(
                              borderRadius: 0,
                              title: "Google",
                              icon: SFIcons.sf_g_circle_fill,
                            ),
                            Divider(color: AppColors.divider, height: 0),
                            BaseCard(
                              borderRadius: 0,
                              title: "Facebook",
                              icon: SFIcons.sf_f_circle_fill,
                            ),
                            Divider(color: AppColors.divider, height: 0),
                            BaseCard(
                              borderRadius: 0,
                              title: "Email",
                              icon: SFIcons.sf_mail_fill,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: AppShadows.boxLayered,
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(12),
                        ),
                        child: BaseCard(
                          title: "Buy me a Coffee",
                          icon: SFIcons.sf_cup_and_heat_waves_fill,
                          backgroundColor: AppColors.primary,
                          iconBackgroundColor: AppColors.secondary.withAlpha(
                            153,
                          ),
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
    );
  }
}
