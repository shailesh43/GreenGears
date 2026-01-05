import 'package:flutter/material.dart';
//Home dashboard body
import '../features/dashboard/dashboard_user.dart'; // for user -> this + bottom nav
import '../features/dashboard/dashboard_admin.dart';// for admin -> this + bottom nav

// Profile page body
import '../features/profile/profile_page.dart';
//Policy page body
import '../features/policy/policy_page.dart';
// Processing page body - for admin only
import '../features/processing/processing_page.dart';

enum UserRole { admin, user }

class DashboardShell extends StatefulWidget {
  final UserRole role;
  const DashboardShell({super.key, required this.role});

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;
  late final List<BottomNavigationBarItem> _navItems;

  @override
  void initState() {
    super.initState();

    if (widget.role == UserRole.admin) {
      _pages = const [
        DashboardAdmin(),
        ProcessingPage(),
        EmployeeDetailsPage(),
        PolicyPage(),
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
    } else {
      _pages = const [
        DashboardUser(),
        EmployeeDetailsPage(),
        PolicyPage(),
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
    }
  }

  @override
  Widget build(BuildContext context) {
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
        backgroundColor: Color.fromRGBO(248, 248, 248, 0.75),
        selectedItemColor: Color.fromRGBO(0, 0, 0, 0.75),
      ),
    );
  }
}
