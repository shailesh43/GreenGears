import 'package:flutter/material.dart';
import '../../network/api_client.dart';
import '../../network/api_models/role_by_employee.dart';
import '../../network/api_models/employee_profile_data.dart';
import '../request/request_vehicle.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

// Employee Profile Page
class _ProfilePageState extends State<ProfilePage> {
  final ApiClient _client = ApiClient();

  int? roleId;
  bool isLoading = true;
  String? employeeName;
  String? employeeEmail;


  @override
  void initState() {
    super.initState();
    _fetchRole();
    _fetchEmployeeProfile();
  }

  Future<void> _fetchRole() async {
    try {
      final RoleByEmployeeModel result =
      await _client.getRoleByEmployee('209164');

      setState(() {
        roleId = result.roleIds.isNotEmpty ? result.roleIds.first : null;
        isLoading = false;
      });

      debugPrint('GET 200 OK : "role-by-employee/:empId"');
      debugPrint('roleId: $roleId');
    } catch (e) {
      debugPrint('Error fetching role: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchEmployeeProfile() async {
    try {
      final result = await _client.getEmployeeProfile('209164');
      if (result != null) {
        setState(() {
          // Use the employee profile data directly
          // Since you don't have an employeeProfile state variable,
          // you can either create one or use the data directly here
          isLoading = false;
          employeeName = result.sapShortNameModify;
          employeeEmail = result.sapEmail;
        });

        debugPrint('POST 200 OK : "employees"');
        debugPrint('Employee Name: ${result
            .sapShortNameModify}'); // Adjust field names as needed
        debugPrint('Employee Email: ${result
            .sapEmail}'); // Adjust field names as needed

        // If you need to store specific fields, do it here
        // For example:
        // setState(() {
        //
        // });
      }
        else {
          debugPrint('Employee profile not found');
          setState(() => isLoading = false);
        }
    }
    catch (e) {
      debugPrint('Error fetching employee profile: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const VehicleDetailsPage(),
                ),
              );
            },
            child: const Text(
              'Next →',
              style: TextStyle(
                color: Color.fromRGBO(0, 122, 255, 1),
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Employee Details',
                style: TextStyle(
                  color: Color.fromRGBO(34, 197, 94, 1),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 16),
              Container(
                constraints: const BoxConstraints(minWidth: double.infinity),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    ProfileField(
                      label: 'Name',
                      value: 'Rahil Bopche',
                    ),
                    const Divider(height: 1, thickness: 1, color: Color.fromRGBO(229, 231, 235, 1)),
                    ProfileField(
                      label: 'Employee code',
                      value: '209164',
                    ),
                    const Divider(height: 1, thickness: 1, color: Color.fromRGBO(229, 231, 235, 1)),
                    ProfileField(
                      label: 'Mobile Name',
                      value: '+8435265646',
                    ),
                    const Divider(height: 1, thickness: 1, color: Color.fromRGBO(229, 231, 235, 1)),
                    ProfileField(
                      label: 'Email',
                      value: 'rahil.bopche@tatapower.com',
                    ),
                    const Divider(height: 1, thickness: 1, color: Color.fromRGBO(229, 231, 235, 1)),
                    ProfileField(
                      label: 'Company',
                      value: 'The Tata Power Co. Ltd.',
                    ),
                    const Divider(height: 1, thickness: 1, color: Color.fromRGBO(229, 231, 235, 1)),
                    ProfileField(
                      label: 'Grade',
                      value: 'ME03',
                    ),
                    const Divider(height: 1, thickness: 1, color: Color.fromRGBO(229, 231, 235, 1)),
                    ProfileField(
                      label: 'Eligibility',
                      value: '₹ 4300.50',
                    ),
                    const Divider(height: 1, thickness: 1, color: Color.fromRGBO(229, 231, 235, 1)),
                    ProfileField(
                      label: 'Cost Center',
                      value: '1900022041',
                    ),
                    const Divider(height: 1, thickness: 1, color: Color.fromRGBO(229, 231, 235, 1)),
                    ProfileField(
                      label: 'Address',
                      value: 'Technopolis Knowledge Park\n4th floor, Andheri (E),\nMumbai 400093',
                    ),
                    const Divider(height: 1, thickness: 1, color: Color.fromRGBO(229, 231, 235, 1)),
                    ProfileField(
                      label: 'Cluster',
                      value: 'Corporate Functions\n& International',
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Reusable Profile Field Widget
class ProfileField extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const ProfileField({
    Key? key,
    required this.label,
    required this.value,
    this.isLast = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: double.infinity,
        minHeight: 56,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                color: Color.fromRGBO(156, 163, 175, 1),
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontFamily: 'Inter',
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Color.fromRGBO(17, 24, 39, 1),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Vehicle Details Page
class VehicleDetailsPage extends StatelessWidget {
  const VehicleDetailsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vehicle Details',
              style: TextStyle(
                color: Color.fromRGBO(34, 197, 94, 1),
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'You haven\'t registered for any Vehicle yet.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color.fromRGBO(17, 24, 39, 1),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const VehicleRequestPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(34, 197, 94, 1),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Request a Vehicle',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
