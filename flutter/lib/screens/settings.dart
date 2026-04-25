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

  final randomNameGenerator = UniqueNamesGenerator(
    config: Config(
      length: 2,
      dictionaries: [adjectives, animals],
      separator: "",
      style: .capital,
    ),
  );

  // Used for Guest sign ins
  String? _pendingDisplayName;

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

    final user = FirebaseAuth.instance.currentUser;
    final anonymous = isAnonymous(user);

    if (kIsWeb) {
      final googleProvider = GoogleAuthProvider();
      if (!anonymous) {
        return await FirebaseAuth.instance.signInWithPopup(googleProvider);
      }
      return await _linkWithErrorHandling(
        () => user!.linkWithPopup(googleProvider),
      );
    }

    // Native: build credential from GoogleSignIn
    final googleUser = await GoogleSignIn.instance.authenticate();
    final googleAuth = googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    if (!anonymous) {
      return await FirebaseAuth.instance.signInWithCredential(credential);
    }

    return await _linkWithErrorHandling(
      () => user!.linkWithCredential(credential),
    );
  }

  Future<UserCredential?> _linkWithErrorHandling(
    Future<UserCredential> Function() linkFn,
  ) async {
    try {
      return await linkFn();
    } on FirebaseAuthException catch (e) {
      final message = switch (e.code) {
        "provider-already-linked" =>
          "The provider has already been linked to a user.",
        "invalid-credential" => "The provider's credential is not valid.",
        "credential-already-in-use" =>
          "The account corresponding to the credential already exists, or is already linked to a Firebase User.",
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

  Future<UserCredential> signInAnonymously() async {
    print("Signing in anonymously...");
    final userCredential = await FirebaseAuth.instance.signInAnonymously();
    setState(() => _pendingDisplayName = randomNameGenerator.generate());

    // Set display name to Guest
    await userCredential.user?.updateDisplayName(_pendingDisplayName);
    setState(() => _pendingDisplayName = null); // clear once real name is set

    return userCredential;
  }

  Future<void> _signOut() async {
    final user = FirebaseAuth.instance.currentUser;
    if (isAnonymous(user)) {
      _checkDeleteUser(isAnonymous: true);
    } else {
      await FirebaseAuth.instance.signOut();
    }
  }

  void _checkDeleteUser({bool isAnonymous = false}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm', style: AppTextStyles.label),
          content: Text(
            'This will remove all traces of the user and all game history.${(isAnonymous ? "\nIf you want to persist your data, link to an online account." : "")}',
            style: AppTextStyles.body,
            softWrap: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: AppTextStyles.body.copyWith(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                _deleteUser();
                Navigator.pop(context);
              },
              child: Text('OK', style: AppTextStyles.label),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteUser() async {
    final user = FirebaseAuth.instance.currentUser;

    user?.delete();
  }

  bool isAnonymous(User? user) {
    if (user == null) {
      return false;
    }
    return user.isAnonymous;
  }

  InteractiveCard getProvider(User? user) {
    late String provider;

    if (!isAnonymous(user)) {
      provider = user!.getProviders().join(', ');
    } else {
      provider = "Guest";
    }

    return InteractiveCard(
      borderRadius: 0,
      title: provider.contains(',') ? "Providers" : "Provider",
      subTitle: provider,
    );
  }

  List<Widget> _buildAuthContent(User? user) {
    return [
      if (user != null)
        CardList(
          header: InteractiveCard(
            backgroundColor: AppColors.primary,
            iconBackgroundColor: AppColors.iconBackgroundColor,
            title: "Account",
            icon: SFIcons.sf_person_circle_fill,
            showTrailingIcon: false,
            borderRadius: 0,
          ),
          children: [
            InteractiveCard(
              borderRadius: 0,
              title: "Display Name",
              subTitle: _pendingDisplayName ?? user.displayName ?? "Not set",
            ),
            getProvider(user),
            InteractiveCard(
              title: "Sign Out",
              icon: SFIcons.sf_arrowshape_left_fill,
              onTap: _signOut,
              borderRadius: 0,
            ),
            if (!isAnonymous(user))
              InteractiveCard(
                title: "Delete Account",
                icon: SFIcons.sf_x_circle_fill,
                onTap: _checkDeleteUser,
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
          header: InteractiveCard(
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
            InteractiveCard(
              borderRadius: 0,
              title: "Google",
              icon: SFIcons.sf_g_circle_fill,
              onTap: () {
                signInWithGoogle();
              },
            ),
            InteractiveCard(
              title: "Email",
              icon: SFIcons.sf_mail_fill,
              borderRadius: 0,
              onTap: () {
                context.router.pushNamed('/emailsignup');
              },
            ),
            if (!isAnonymous(user))
              InteractiveCard(
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
        centerTitle: true,
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
                          header: InteractiveCard(
                            backgroundColor: AppColors.primary,
                            iconBackgroundColor: AppColors.iconBackgroundColor,
                            title: "Sounds",
                            icon: SFIcons.sf_speaker_wave_3_fill,
                            showTrailingIcon: false,
                            borderRadius: 0,
                          ),
                          children: [
                            InteractiveCard(
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
                            InteractiveCard(
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
                        InteractiveCard(
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

extension UserExtensions on User {
  List<String> getProviders() {
    String getProvider(String rawProvider) {
      switch (rawProvider) {
        case "password":
          return "Email";
        case "google.com":
          return "Google";
        case "facebook.com":
          return "Facebook";
        case "twitter.com":
          return "X (Twitter)";
        case "github.com":
          return "GitHub";
        case "apple.com":
          return "Apple";
        case "phone":
          return "Phone";
        case "firebase":
          return "Guest";
        default:
          return "Unknown";
      }
    }

    List<String> providers = [];

    for (final providerProfile in providerData) {
      providers.add(getProvider(providerProfile.providerId));
      break;
    }

    return providers;
  }
}
