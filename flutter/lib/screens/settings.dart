import 'package:flutter/material.dart';
import 'package:auto_route/annotations.dart';
import '../theme/app_theme.dart';
import '../widgets/app_title.dart';
import '../widgets/card.dart';
import 'package:flutter_sficon/flutter_sficon.dart';
import 'package:auto_route/auto_route.dart';
import 'package:shared_preferences/shared_preferences.dart';

@RoutePage(name: 'Settings')
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool allowMusic = true;
  bool allowMotion = true;

  void _loadData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      allowMusic = prefs.getBool("allow_music") ?? true;
      allowMotion = prefs.getBool("allow_motion") ?? true;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void updateAllowMusic(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("allow_music", value);

    setState(() {
      allowMusic = value;
    });
  }

  void updateAllowMotion(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("allow_motion", value);

    setState(() {
      allowMotion = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
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
                    CardList(
                      header: BaseCard(
                        backgroundColor: AppColors.primary,
                        iconBackgroundColor: AppColors.iconBackgroundColor,
                        title: "Sounds",
                        icon: SFIcons.sf_speaker_wave_3_fill,
                        showTrailingIcon: false,
                        borderRadius: 0,
                      ),
                      children: [
                        BaseCard(
                          borderRadius: 0,
                          title: "Music",
                          subTitle: "Toggle in-game music",
                          trailingIcon: Switch(
                            value: allowMusic,
                            trackOutlineWidth:
                                WidgetStateProperty.resolveWith<double?>(
                                  (_) => 1.0,
                                ),
                            activeThumbColor: Colors.white,
                            activeTrackColor: Colors.green,
                            onChanged: (bool value) => updateAllowMusic(value),
                          ),
                        ),
                        BaseCard(
                          borderRadius: 0,
                          title: "Motion",
                          subTitle: "Toggle motion (ie. background suits)",
                          trailingIcon: Switch(
                            value: allowMotion,
                            trackOutlineWidth:
                                WidgetStateProperty.resolveWith<double?>(
                                  (_) => 1.0,
                                ),
                            activeThumbColor: Colors.white,
                            activeTrackColor: Colors.green,
                            onChanged: (bool value) => updateAllowMotion(value),
                          ),
                        ),
                      ],
                    ),
                    CardList(
                      header: BaseCard(
                        borderRadius: 0,
                        backgroundColor: AppColors.primary,
                        iconBackgroundColor: AppColors.iconBackgroundColor,
                        title: "Sign In",
                        icon: SFIcons.sf_checkmark_circle_fill,
                        showTrailingIcon: false,
                      ),
                      children: [
                        BaseCard(
                          borderRadius: 0,
                          title: "Google",
                          icon: SFIcons.sf_g_circle_fill,
                        ),
                        BaseCard(
                          borderRadius: 0,
                          title: "Facebook",
                          icon: SFIcons.sf_f_circle_fill,
                        ),
                        BaseCard(
                          title: "Email",
                          icon: SFIcons.sf_mail_fill,
                          borderRadius: 0,
                        ),
                      ],
                    ),
                    BaseCard(
                      borderRadius: 12,
                      backgroundColor: AppColors.primary,
                      iconBackgroundColor: AppColors.iconBackgroundColor,
                      title: "Buy me a Coffee",
                      icon: SFIcons.sf_cup_and_heat_waves_fill,
                      boxShadow: AppShadows.boxLayered,
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
