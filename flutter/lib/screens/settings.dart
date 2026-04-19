import 'package:app/widgets/animated_chevron.dart';
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

@RoutePage(name: 'Settings')
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool allowMusic = true;
  bool allowMotion = true;

  bool signInExpanded = false;
  bool signUpExpanded = false;

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

  void toggleSignInExpanded() {
    setState(() {
      signUpExpanded = false;
      signInExpanded = !signInExpanded;
    });
  }

  void toggleSignUpExpanded() {
    setState(() {
      signInExpanded = false;
      signUpExpanded = !signUpExpanded;
    });
  }

  Future<UserCredential?> signInWithGoogle() async {
    print("Signing in with Google...");
    // Trigger the authentication flow
    final GoogleSignInAccount googleUser = await GoogleSignIn.instance
        .authenticate();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth = googleUser.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    if (isAnonymous(FirebaseAuth.instance.currentUser)) {
      // If signed in as anonymous user (guest), try to link guest account with permanent account
      try {
        return await FirebaseAuth.instance.currentUser!.linkWithCredential(
          credential,
        );
      } on FirebaseAuthException catch (e) {
        late String message;
        switch (e.code) {
          case "provider-already-linked":
            message = ("The provider has already been linked to a user.");
            break;
          case "invalid-credential":
            message = ("The provider's credential is not valid.");
            break;
          case "credential-already-in-use":
            message =
                ("The account corresponding to the credential already exists, or is already linked to a Firebase User.");
            break;
          // See the API reference for the full list of error codes.
          default:
            message = ("Unknown error.");
        }

        if (context.mounted) {
          showErrorSnackBar(
            context,
            message: message,
          );
        } else {
          print("Context isn't mounted???");
        }

        return null;
      }
    } else {
      // Once signed in, return the UserCredential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    }
  }

  Future<UserCredential> signInAnonymously() async {
    print("Signing in anonymously...");
    final userCredential = await FirebaseAuth.instance.signInAnonymously();

    // Set display name to Guest
    await userCredential.user?.updateDisplayName("Guest");

    return userCredential;
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  bool isAnonymous(User? user) {
    if (user == null) {
      return false;
    }
    return user.isAnonymous;
  }

  List<Widget> _buildAuthContent(User? user) {
    return [
      if (user != null)
        CardList(
          header: BaseCard(
            backgroundColor: AppColors.primary,
            iconBackgroundColor: AppColors.iconBackgroundColor,
            title: "Account",
            icon: SFIcons.sf_person_circle_fill,
            showTrailingIcon: false,
            borderRadius: 0,
          ),
          children: [
            BaseCard(
              borderRadius: 0,
              title: "Display Name",
              subTitle: user.displayName ?? "Not set",
            ),
            if (user.email != null)
              BaseCard(borderRadius: 0, title: "Email", subTitle: user.email!),
            BaseCard(
              title: "Sign Out",
              icon: SFIcons.sf_arrowshape_left_fill,
              onTap: _signOut,
              borderRadius: 0,
              backgroundColor: Colors.red.shade200,
              iconBackgroundColor: AppColors.iconBackgroundColor,
            ),
          ],
        ),

      if (user == null || isAnonymous(user))
        CardList(
          borderRadius: .vertical(
            top: Radius.circular(AppContainerConstraints.borderRadius),
            bottom: Radius.circular(AppContainerConstraints.borderRadius),
          ),
          header: BaseCard(
            backgroundColor: AppColors.primary,
            iconBackgroundColor: AppColors.iconBackgroundColor,
            title: isAnonymous(user) ? "Link with Online Account" : "Sign In",
            icon: SFIcons.sf_checkmark_circle_fill,
            trailingIcon: AnimatedChevron(expanded: signInExpanded),
            boxShadow: AppShadows.boxLayered,
            borderRadius: 0,
            showTrailingIcon: false,
          ),
          children: [
            BaseCard(
              borderRadius: 0,
              title: "Google",
              icon: SFIcons.sf_g_circle_fill,
              onTap: () => signInWithGoogle(),
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
            if (!isAnonymous(user))
              BaseCard(
                borderRadius: 0,
                title: "Guest",
                icon: SFIcons.sf_person_fill,
                onTap: () => signInAnonymously(),
              ),
          ],
        ),
    ];
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
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.userChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          // if (snapshot.connectionState == ConnectionState.waiting) {
          //   return const Center(child: Text("Loading..."));
          // }

          final user = snapshot.data;

          return SafeArea(
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
                                onChanged: (bool value) =>
                                    updateAllowMusic(value),
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
                                onChanged: (bool value) =>
                                    updateAllowMotion(value),
                              ),
                            ),
                          ],
                        ),
                        ..._buildAuthContent(user),
                        BaseCard(
                          borderRadius: 12,
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
          );
        },
      ),
    );
  }
}
