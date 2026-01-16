import 'package:flutter/material.dart';
import 'package:greennest/Auth/login_screen.dart';
import 'package:greennest/Helper/navigation_extensions.dart';
import 'package:greennest/Services/api_service.dart';
import 'package:greennest/Widget/custom_toast.dart';
import 'admin_plant_management.dart';
import 'admin_category_management.dart';
import 'admin_user_management.dart';
import 'dart:convert';

class AdminDashboard extends StatefulWidget {
  final String email;
  final String token;

  const AdminDashboard({
    required this.email,
    required this.token,
    Key? key,
  }) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  int _totalPlants = 0;
  int _totalCategories = 0;
  int _totalUsers = 0;
  bool _isLoading = false;
  late Future<void> _statsFuture;

  @override
  void initState() {
    super.initState();
    _verifyAdminAccess();
    _statsFuture = _loadDashboardStats();
  }

  Future<void> _verifyAdminAccess() async {
    try {
      final response = await ApiService.getAdminPlants(token: widget.token);
      if (response.statusCode != 200) {
        context.pushReplacement(const LoginScreen());
      }
    } catch (e) {
      CustomToast.error(
        title: 'Access Denied',
        message: 'Admin privileges required',
      );
      context.pushReplacement(const LoginScreen());
    }
  }

  Future<void> _loadDashboardStats() async {
    setState(() => _isLoading = true);
    try {
      // Fetch plants count
      final plantsResponse =
          await ApiService.getAdminPlants(token: widget.token);
      print('Plants Response Status: ${plantsResponse.statusCode}');
      print('Plants Response Body: ${plantsResponse.body}');

      if (plantsResponse.statusCode == 200) {
        final dynamic plantsData = jsonDecode(plantsResponse.body);
        int count = 0;

        if (plantsData is List) {
          count = plantsData.length;
        } else if (plantsData is Map && plantsData.containsKey('content')) {
          count = (plantsData['content'] as List).length;
        } else if (plantsData is Map && plantsData.containsKey('data')) {
          final data = plantsData['data'];
          count = data is List ? data.length : 1;
        }

        setState(() => _totalPlants = count);
      }

      // Fetch categories count
      final categoriesResponse =
          await ApiService.getAdminCategories(token: widget.token);
      print('Categories Response Status: ${categoriesResponse.statusCode}');
      print('Categories Response Body: ${categoriesResponse.body}');

      if (categoriesResponse.statusCode == 200) {
        final dynamic categoriesData = jsonDecode(categoriesResponse.body);
        int count = 0;

        if (categoriesData is List) {
          count = categoriesData.length;
        } else if (categoriesData is Map &&
            categoriesData.containsKey('content')) {
          count = (categoriesData['content'] as List).length;
        } else if (categoriesData is Map &&
            categoriesData.containsKey('data')) {
          final data = categoriesData['data'];
          count = data is List ? data.length : 1;
        }

        setState(() => _totalCategories = count);
      }

      // Fetch users count
      final usersResponse = await ApiService.getAdminUsers(token: widget.token);
      print('Users Response Status: ${usersResponse.statusCode}');
      print('Users Response Body: ${usersResponse.body}');

      if (usersResponse.statusCode == 200) {
        final dynamic usersData = jsonDecode(usersResponse.body);
        int count = 0;

        if (usersData is List) {
          count = usersData.length;
        } else if (usersData is Map && usersData.containsKey('content')) {
          count = (usersData['content'] as List).length;
        } else if (usersData is Map && usersData.containsKey('data')) {
          final data = usersData['data'];
          count = data is List ? data.length : 1;
        }

        setState(() => _totalUsers = count);
      }

      print(
          'Final counts - Plants: $_totalPlants, Categories: $_totalCategories, Users: $_totalUsers');
    } catch (e) {
      print('Error loading stats: $e');
      CustomToast.error(
        title: 'Load Error',
        message: 'Could not load dashboard statistics',
      );
    }
    setState(() => _isLoading = false);
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Confirm Logout',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: const Text(
          'Are you sure you want to logout from the admin panel?',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              CustomToast.success(
                title: 'Logged Out',
                message: 'You have been logged out',
              );
              context.pushReplacement(const LoginScreen());
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: _buildAppBar(),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Colors.green[700],
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Loading Dashboard',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Premium Stats Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green[700]!, Colors.green[600]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dashboard Overview',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Track your store performance',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.85),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildPremiumStatCard(
                              icon: Icons.local_florist_rounded,
                              label: 'Products',
                              value: _totalPlants,
                              color: Colors.amber,
                            ),
                            _buildPremiumStatCard(
                              icon: Icons.category_rounded,
                              label: 'Categories',
                              value: _totalCategories,
                              color: Colors.cyan,
                            ),
                            _buildPremiumStatCard(
                              icon: Icons.people_alt_rounded,
                              label: 'Customers',
                              value: _totalUsers,
                              color: Colors.deepPurple,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Content Section
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: _selectedIndex == 0
                        ? AdminPlantManagement(token: widget.token)
                        : _selectedIndex == 1
                            ? AdminCategoryManagement(token: widget.token)
                            : AdminUserManagement(token: widget.token),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      leading: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green[700]!, Colors.green[600]!],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Icon(
            Icons.admin_panel_settings_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'GreenNest Admin',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
          Text(
            'Store Management',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
      actions: [
        // Refresh Button
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: IconButton(
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _loadDashboardStats().then((_) {
                CustomToast.success(
                  title: 'Dashboard Refreshed',
                  message: 'Stats updated successfully',
                );
              });
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.refresh_rounded,
                color: Colors.grey[700],
              ),
            ),
            tooltip: 'Refresh Stats',
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 8),
          child: PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: _logout,
                child: Row(
                  children: [
                    const Icon(Icons.logout_rounded, color: Colors.red),
                    const SizedBox(width: 8),
                    const Text('Logout', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.more_vert_rounded,
                color: Colors.grey[700],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumStatCard({
    required IconData icon,
    required String label,
    required int value,
    required Color color,
  }) {
    return Container(
      width: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.green[700],
        unselectedItemColor: Colors.grey[500],
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        elevation: 0,
        items: [
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: _selectedIndex == 0
                  ? BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(10),
                    )
                  : null,
              child: const Icon(Icons.local_florist_rounded),
            ),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: _selectedIndex == 1
                  ? BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(10),
                    )
                  : null,
              child: const Icon(Icons.category_rounded),
            ),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: _selectedIndex == 2
                  ? BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(10),
                    )
                  : null,
              child: const Icon(Icons.people_alt_rounded),
            ),
            label: 'Customers',
          ),
        ],
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}
