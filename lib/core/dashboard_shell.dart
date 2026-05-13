import 'package:flutter/material.dart';
import '../features/dashboard/dashboard_main.dart';
import '../features/processing/processing_page.dart';
import '../features/profile/profile_page.dart';
import '../features/policy/policy_page.dart';
import '../core/utils/enum.dart';
import '../constants/local_prefs.dart';

class DashboardShell extends StatefulWidget {
  final UserRole role;

  const DashboardShell({
    super.key,
    required this.role,
  });

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  int _selectedIndex = 0;
  bool isLoading = true;
  String empId = '';
  int roleId = 0;
  late final UserRole role;

  late List<Widget> _pages;
  late List<BottomNavigationBarItem> _navItems;

  Future<int> getUserRole() async {
    int? rId = await LocalPrefs.getRoleId();
    return rId ?? 0;
  }

  @override
  void initState() {
    role = widget.role;
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final code = await LocalPrefs.getEmpCode();
    setState(() {
      empId = code ?? '';
    });
    int rId = await getUserRole();
    setState(() {
      roleId = rId;
    });
    _setupPagesAndNav();
    setState(() {
      isLoading = false;
    });
  }

  void _setupPagesAndNav() {

    const _fourTabNav = [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Processing'),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      BottomNavigationBarItem(icon: Icon(Icons.policy), label: 'Policy'),
    ];

    const _threeTabNav = [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      BottomNavigationBarItem(icon: Icon(Icons.policy), label: 'Policy'),
    ];


    switch (role) {
      case UserRole.admin:
        _pages = [
          MainDashboard(role: role),
          ProcessingPage(role: role),
          const ProfilePage(),
          const PolicyPage(),
        ];
        break;

      case UserRole.esna:
        _pages = [
          MainDashboard(role: role),
          ProcessingPage(role: role),
          const ProfilePage(),
          const PolicyPage(),
        ];
        break;

      case UserRole.insurance:
        _pages = [
          MainDashboard(role: role),
          ProcessingPage(role: role),
          const ProfilePage(),
          const PolicyPage(),
        ];
        break;

      case UserRole.centralAdmin:
        _pages = [
          MainDashboard(role: role),
          ProcessingPage(role: role),
          const ProfilePage(),
          const PolicyPage(),
        ];
        break;

      case UserRole.user:
        _pages = [
          MainDashboard(role: role),
          const ProfilePage(),
          const PolicyPage(),
        ];
        break;
    }

    _navItems = _pages.length == 4
        ?  _fourTabNav
        : _threeTabNav;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Color.fromRGBO(34, 197, 94, 1), // Your green color
          ),
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: _navItems,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        backgroundColor: const Color.fromRGBO(248, 248, 248, 0.75),
        selectedItemColor: const Color.fromRGBO(0, 0, 0, 0.75),
      ),
    );
  }
}