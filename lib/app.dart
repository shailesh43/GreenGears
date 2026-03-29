import 'dart:async';
import 'dart:core';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
// Construct pages through shell
import 'core/dashboard_shell.dart';
// SAMAL(msauth) Login & logout function
import './auth/azure_auth_service.dart';
// Local storage
import './constants/local_prefs.dart';
import './network/api_client.dart';
import './core/utils/enum.dart';
import './core/helpers/emulator_detector.dart';

// Change this line in app.dart
final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ApiClient _client = ApiClient();
  bool isLoading = false;

  late Future<String?> _initFuture;

  @override
  void initState() {
    super.initState();

    // Start app initialization (auth + delay)
    _initFuture = _initializeApp();

    // Preload visual assets AFTER first frame
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

  // Initialize app with splash screen delay
  Future<String?> _initializeApp() async {
    await Future.delayed(const Duration(seconds: 2));

    // 🔐 Emulator detection
    final isEmulator = await EmulatorDetector.isEmulator();

    if (isEmulator) {
      debugPrint("⚠️ Emulator detected");

      // Just flag it
      return "EMULATOR_BLOCKED";
    }

    return _checkLoginStatus();
  }

  // Check if user is already logged in
  Future<String?> _checkLoginStatus() async {
    final isLoggedIn = await LocalPrefs.getIsLoggedIn();

    if (isLoggedIn) {
      // User is already logged in, get empId from local storage
      final empId = await LocalPrefs.getEmpCode();
      if (empId != null && empId.isNotEmpty) {
        return empId;
      }
    }

    // User is not logged in, perform login
    return _login();
  }

  // Login method that returns empId
  Future<String?> _login() async {
    final empId = await AuthenticationService.login();

    if (empId != null) {
      await LocalPrefs.saveEmpId(empCode: empId);
      // Save login status as true
      await LocalPrefs.saveLoginStatus(isLoggedIn: true);
    }
    return empId;
  }

  // Fetch role from API
  Future<UserRole> _fetchEmployeeRole(String empCode) async {
    if (empCode.isEmpty) {
      return UserRole.user; // default fallback
    }

    try {
      final result = await _client.getRoleByEmployee(empCode);
      final roleId = result.roleIds.isNotEmpty ? result.roleIds.first : 1;

      // Save roleId to local storage
      await LocalPrefs.saveRoleId(roleId: roleId);

      return UserRole.fromId(roleId) ?? UserRole.user;
    } catch (e) {
      debugPrint('Error fetching role: $e');
      return UserRole.user; // default fallback on error
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
      home: FutureBuilder<String?>(
        future: _initFuture,
        builder: (context, snapshot) {
          // Show splash screen while initializing
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }
          // Emulator Detection
          if (snapshot.hasData && snapshot.data == "EMULATOR_BLOCKED") {
            return const Scaffold(
              body: Center(
                child: Text(
                  "This app cannot run on emulator",
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            );
          }
          // Check if login was successful
          if (snapshot.hasData && snapshot.data != null) {
            final empCode = snapshot.data!;
            return FutureBuilder<UserRole>(
              future: _fetchEmployeeRole(empCode),
              builder: (context, roleSnapshot) {
                if (roleSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(
                        color: Color.fromRGBO(34, 197, 94, 1), // Your green color
                      ),
                    ),
                  );
                }
                final role = roleSnapshot.data ?? UserRole.user;
                return DashboardShell(role: role);
              },
            );
          }
          // Login failed - show error message
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '404 :(',
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, letterSpacing: -0.8, color: Colors.redAccent),
                  ),
                  const Text(
                    'Error! Login failed Please try again.',
                    style: TextStyle(fontSize: 18, letterSpacing: -0.2, color: Colors.redAccent),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _initFuture = _login();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.80), // glass effect
                      foregroundColor: Colors.black,
                      elevation: 6,
                      shadowColor: Colors.black.withOpacity(0.20),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Retry',
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
      begin: const Offset(-1.2, 0), // off-screen left
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
          // Logo + Text Block
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

          // ✅ Full-width Lottie
          SizedBox(
            width: double.infinity,
            height: 200,
            child: Lottie.asset(
              'assets/anims/moving_car_lottie.json',
              fit: BoxFit.cover, // important for full width feel
              repeat: true,
            ),
          ),
        ],
      ),
    );
  }
}
