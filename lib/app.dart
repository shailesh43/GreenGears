import 'dart:async';
import 'dart:core';
import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'core/dashboard_shell.dart';
import './auth/azure_auth_service.dart';
import './constants/local_prefs.dart';
import './network/api_client.dart';
import './core/utils/enum.dart';
import './core/helpers/emulator_detector.dart';
import 'package:greengears/main.dart';

final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();

// Wrapper so FutureBuilder can distinguish "cancelled" from "hard failure"
enum _LoginResult { success, cancelled, failed }

class _InitResult {
  final String? empId;
  final _LoginResult loginResult;

  const _InitResult.success(this.empId) : loginResult = _LoginResult.success;
  const _InitResult.cancelled() : empId = null, loginResult = _LoginResult.cancelled;
  const _InitResult.failed() : empId = null, loginResult = _LoginResult.failed;
  const _InitResult.emulatorBlocked() : empId = "EMULATOR_BLOCKED", loginResult = _LoginResult.success;
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ApiClient _client = globalApiClient;

  late Future<_InitResult> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _initializeApp();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preloadAssets(context);
    });


  }

  Future<void> _preloadAssets(BuildContext context) async {
    await precacheImage(
      const AssetImage('assets/images/tata_power_full_logo.png'),
      context,
    );
  }

  Future<_InitResult> _initializeApp() async {
    await Future.delayed(const Duration(seconds: 2));

    if (Platform.isAndroid) {
      var isRoot = await androidRootChecker();
      var isDeveloperMode = await developerMode();
      var isEmulatorDevice = await isEmulator();
      if (!isRoot && !isDeveloperMode && !isEmulatorDevice) {
        moveToNext();
      } else {
        if (isRoot) {
          showErrorDialog('You cannot use the Tata Power CP app on a jailbroken or rooted device.');
        } else if (isDeveloperMode) {
          showErrorDialog(
            'Developer Mode is enabled, preventing you from using the app. To disable it, go to Settings > search for Developer > select Developer options > toggle it Off, then restart the app.',
          );
        } else if (isEmulatorDevice) {
          showErrorDialog('The Tata Power CP app cannot run on an emulator. Please install the app on a physical device.');
        }
      }
    } else if (Platform.isIOS) {
      var isIosJailbreak = await iosJailbreak();
      var isEmulatorDevice = await isEmulator();
      if (!isIosJailbreak && !isEmulatorDevice) {
        moveToNext();
      } else {
        if (isIosJailbreak) {
          showErrorDialog('You cannot use the Tata Power CP app on a jailbroken or rooted device.');
        } else if (isEmulatorDevice) {
          showErrorDialog('The Tata Power CP app cannot run on an emulator. Please install the app on a physical device.');
        }
      }
    }

    return null;

  }

  moveToNext() {
    // If we already have a stored empId, skip login entirely
    final storedEmpId = await LocalPrefs.getEmpCode();
    if (storedEmpId != null && storedEmpId.isNotEmpty) {
      return _InitResult.success(storedEmpId);
    }

    // No session — launch SAMAL login
    return _login();
  }

  Future<bool> androidRootChecker() async {
    if (kDebugMode) {
      return false;
    }
    try {
      return await JailbreakRootDetection.instance.isJailBroken;
      // return (await RootCheckerPlus.isRootChecker())!;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> isEmulator() async {
    if (kDebugMode) {
      return false;
    }
    return !(await JailbreakRootDetection.instance.isRealDevice);
    // final deviceInfoPlugin = DeviceInfoPlugin();
    // if (Platform.isAndroid) {
    //   final androidInfo = await deviceInfoPlugin.androidInfo;
    //   return !androidInfo.isPhysicalDevice;
    // } else if (Platform.isIOS) {
    //   final iosInfo = await deviceInfoPlugin.iosInfo;
    //   return !iosInfo.isPhysicalDevice;
    // }
    return false;
  }

  Future<bool> developerMode() async {
    if (kDebugMode) {
      return false;
    }
    try {
      return await JailbreakRootDetection.instance.isDevMode;
      // return (await RootCheckerPlus.isDeveloperMode())!;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> iosJailbreak() async {
    if (kDebugMode) {
      return false;
    }
    try {
      final bundleId = 'com.tatapower.greengears';
      return await JailbreakRootDetection.instance.isJailBroken || await JailbreakRootDetection.instance.isTampered(bundleId);
    } on PlatformException {
      return false;
    }
  }

  void showErrorDialog(String message) {
    Get.dialog(
      PopScope(
        canPop: false,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(15)),
                margin: EdgeInsets.symmetric(horizontal: 15),
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Error', style: TextStyle(color: AppColors.redColor, fontSize: 22, fontWeight: FontWeight.w600)),
                      verticalSpace(15),
                      Text(message, style: TextStyle(color: AppColors.black, fontSize: 16, fontWeight: FontWeight.w400)),
                      verticalSpace(25),
                      SizedBox(
                        width: Get.width,
                        child: ElevatedButton(
                          onPressed: () {
                            exit(0);
                          },
                          style: primaryButtonStyle,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Exit App', style: TextStyle(color: AppColors.white)),
                              horizontalSpace(10),
                              Icon(Icons.arrow_forward, size: 20, color: AppColors.white),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<_InitResult> _login() async {
    final empId = await AuthenticationService.login();

    if (empId != null) {
      await LocalPrefs.saveEmpId(empCode: empId);
      await LocalPrefs.saveLoginStatus(isLoggedIn: true);
      return _InitResult.success(empId);
    }

    // AuthenticationService.login() returns null for both cancellation
    // and hard failure. The SAMAL screen was shown — returning cancelled
    // so the UI shows the retry screen without a harsh error message.
    // If you later want to distinguish cancellation from failure,
    // AuthenticationService.login() would need to surface that separately.
    return const _InitResult.cancelled();
  }

  Future<UserRole> _fetchEmployeeRole(String empCode) async {
    if (empCode.isEmpty) return UserRole.user;

    try {
      final result = await _client.getRoleByEmployee(empCode);
      final roleId = result.roleIds.isNotEmpty ? result.roleIds.first : 1;
      await LocalPrefs.saveRoleId(roleId: roleId);
      return UserRole.fromId(roleId) ?? UserRole.user;
    } catch (e) {
      assert(() {
        debugPrint('Error fetching role: $e');
        return true;
      }());
      return UserRole.user;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GreenGears',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      navigatorObservers: [routeObserver],
      home: FutureBuilder<_InitResult>(
        future: _initFuture,
        builder: (context, snapshot) {
          // Still initialising — show splash
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }

          final result = snapshot.data;

          // Emulator blocked
          if (result?.empId == "EMULATOR_BLOCKED") {
            return const Scaffold(
              body: Center(
                child: Text(
                  "This app cannot run on emulator",
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            );
          }

          // Login succeeded — fetch role and enter app
          if (result?.loginResult == _LoginResult.success && result?.empId != null) {
            final empCode = result!.empId!;
            return FutureBuilder<UserRole>(
              future: _fetchEmployeeRole(empCode),
              builder: (context, roleSnapshot) {
                if (roleSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(
                        color: Color.fromRGBO(34, 197, 94, 1),
                      ),
                    ),
                  );
                }
                final role = roleSnapshot.data ?? UserRole.user;
                return DashboardShell(role: role);
              },
            );
          }

          // Cancelled or failed — show retry screen.
          // Only show the error text on a hard failure, not on cancellation.
          final isCancelled = result?.loginResult == _LoginResult.cancelled;
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!isCancelled) ...[
                    const Text(
                      '404 :(',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.8,
                        color: Colors.redAccent,
                      ),
                    ),
                    const Text(
                      'Error! Login failed. Please try again.',
                      style: TextStyle(
                        fontSize: 18,
                        letterSpacing: -0.2,
                        color: Colors.redAccent,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (isCancelled)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: Text(
                        'Sign in to continue.',
                        style: TextStyle(
                          fontSize: 18,
                          letterSpacing: -0.2,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _initFuture = _login();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.80),
                      foregroundColor: Colors.black,
                      elevation: 6,
                      shadowColor: Colors.black.withOpacity(0.20),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Sign in',
                      style: TextStyle(
                        color: Color.fromRGBO(80, 80, 80, 1.0),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Splash Screen Widget
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _slideController;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.2, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeOutCubic,
      ),
    );

    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/tata_power_full_logo.png',
                height: 80,
                color: const Color.fromRGBO(22, 100, 162, 1.0),
              ),
              const SizedBox(height: 32),
              const Text(
                'GreenGears',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.8,
                  color: Color.fromRGBO(15, 111, 16, 1.0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 42),
          SizedBox(
            width: double.infinity,
            height: 200,
            child: Lottie.asset(
              'assets/anims/moving_car_lottie.json',
              fit: BoxFit.cover,
              repeat: true,
            ),
          ),
        ],
      ),
    );
  }
}
