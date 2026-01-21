import 'package:flutter/material.dart';
//Home dashboard body
import '../features/dashboard/dashboard_main.dart';

// Profile page body
import '../features/profile/profile_page.dart';
//Policy page body
import '../features/policy/policy_page.dart';
// Processing page body
import '../features/processing/processing_page.dart';

// Fetch role to get Started
import '../../network/api_client.dart';
import '../../network/api_models/role_by_employee.dart';
import '../../constants/local_prefs.dart';
import '../constants/utils.dart';
import '../constants/local_prefs.dart';
import '../network/api_client.dart';

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
  final ApiClient _client = ApiClient();

  bool isLoading = true;
  String empId = '';
  int roleId = 0;

  late List<Widget> _pages;
  late List<BottomNavigationBarItem> _navItems;

  Future<int> getUserRole() async {
    int? rId = await LocalPrefs.getRoleId();
    return rId ?? 0;
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    // load empId
    final code = await LocalPrefs.getEmpCode();
    setState(() {
      empId = code ?? '';
    });

    // load roleId
    int rId = await getUserRole();
    setState(() {
      roleId = rId;
    });

    // setup pages
    _setupPagesAndNav();

    setState(() {
      isLoading = false;
    });
  }


  // Future<void> _loadEmpId() async {
  //   final code = await LocalPrefs.getEmpCode();
  //   setState(() {
  //     empId = code ?? '';
  //   });
  // }

  // Future<void> _fetchRole() async {
  //   if (empId.isEmpty) {
  //     setState(() => isLoading = false);
  //     return;
  //   }
  //
  //   try {
  //     final result = await _client.getRoleByEmployee(empId);
  //     setState(() {
  //       roleId = result.roleIds.isNotEmpty ? result.roleIds.first : 0;
  //       isLoading = false;
  //     });
  //     debugPrint('GET 200 OK : "role-by-employee/:empId"');
  //     debugPrint('roleId: $roleId');
  //   } catch (e) {
  //     debugPrint('Error fetching role: $e');
  //     setState(() => isLoading = false);
  //   }
  // }

  void _setupPagesAndNav() {
    switch (widget.role) {
      case UserRole.admin:
        _pages = [
          MainDashboard(role: widget.role),
          ProcessingPage(role: UserRole.admin),
          const ProfilePage(),
          const PolicyPage(),
        ];
        _navItems = const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Processing',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.policy),
            label: 'Policy',
          ),
        ];
        break;

      case UserRole.esna:
        _pages = [
          MainDashboard(role: widget.role),
          ProcessingPage(role: UserRole.esna),
          const ProfilePage(),
          const PolicyPage(),
        ];
        _navItems = const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Processing',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.policy),
            label: 'Policy',
          ),
        ];
        break;

      case UserRole.insurance:
        _pages = [
          MainDashboard(role: widget.role),
          ProcessingPage(role: UserRole.insurance),
          const ProfilePage(),
          const PolicyPage(),
        ];
        _navItems = const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Processing',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.policy),
            label: 'Policy',
          ),
        ];
        break;

      case UserRole.user:
        _pages = [
          MainDashboard(role: widget.role),
          const ProfilePage(),
          const PolicyPage(),
        ];
        _navItems = const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.policy),
            label: 'Policy',
          ),
        ];
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
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