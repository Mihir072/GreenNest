import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:greennest/Services/api_service.dart';
import 'package:greennest/Widget/custom_toast.dart';

class AdminCategoryManagement extends StatefulWidget {
  final String token;

  const AdminCategoryManagement({required this.token, Key? key})
      : super(key: key);

  @override
  State<AdminCategoryManagement> createState() =>
      _AdminCategoryManagementState();
}

class _AdminCategoryManagementState extends State<AdminCategoryManagement> {
  List<dynamic> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final response = await ApiService.getAdminCategories(token: widget.token);
      print('Categories Response: ${response.body}');
      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        List<dynamic> categoriesList = [];

        // Handle different response formats
        if (data is List) {
          categoriesList = data;
        } else if (data is Map) {
          if (data.containsKey('data')) {
            categoriesList = data['data'] ?? [];
          } else if (data.containsKey('content')) {
            categoriesList = data['content'] ?? [];
          }
        }

        setState(() => _categories = categoriesList);
      }
    } catch (e) {
      print('Error loading categories: $e');
      CustomToast.error(
        title: 'Load Error',
        message: 'Could not load categories',
      );
    }
    setState(() => _isLoading = false);
  }

  Future<void> _deleteCategory(String categoryId, String categoryName) async {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text(
            'Are you sure you want to delete "$categoryName"? Make sure no plants exist in this category.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final response = await ApiService.deleteAdminCategory(
                  categoryId,
                  token: widget.token,
                );
                if (response.statusCode == 200) {
                  CustomToast.success(
                    title: 'Category Deleted',
                    message: 'Category has been removed',
                  );
                  _loadCategories();
                } else {
                  final Map<String, dynamic> errorData =
                      jsonDecode(response.body);
                  CustomToast.error(
                    title: 'Delete Failed',
                    message: 'Could not delete category',
                  );
                }
              } catch (e) {
                CustomToast.error(
                  title: 'Error',
                  message: 'Something went wrong',
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddEditDialog({dynamic category}) {
    final isEdit = category != null;
    final nameCtrl = TextEditingController(text: category?['name'] ?? '');
    final descCtrl =
        TextEditingController(text: category?['description'] ?? '');

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(isEdit ? 'Edit Category' : 'Add Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Category Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (nameCtrl.text.isEmpty || descCtrl.text.isEmpty) {
                CustomToast.warning(
                  title: 'Incomplete Form',
                  message: 'Please fill in all fields',
                );
                return;
              }

              try {
                final categoryData = {
                  'name': nameCtrl.text,
                  'description': descCtrl.text,
                };

                late final response;
                if (isEdit) {
                  response = await ApiService.updateAdminCategory(
                    category['_id'] ?? category['id'],
                    categoryData,
                    token: widget.token,
                  );
                } else {
                  response = await ApiService.createAdminCategory(
                    categoryData,
                    token: widget.token,
                  );
                }

                if (response.statusCode == 200 || response.statusCode == 201) {
                  Navigator.pop(context);
                  CustomToast.success(
                    title: isEdit ? 'Category Updated' : 'Category Added',
                    message: 'Changes have been saved',
                  );
                  _loadCategories();
                } else {
                  final Map<String, dynamic> errorData =
                      jsonDecode(response.body);
                  CustomToast.error(
                    title: 'Save Failed',
                    message: 'Unable to save category',
                  );
                }
              } catch (e) {
                CustomToast.error(
                  title: 'Error',
                  message: 'Something went wrong',
                );
              }
            },
            child: Text(isEdit ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: Colors.cyan[700],
                  strokeWidth: 3,
                ),
                const SizedBox(height: 16),
                Text(
                  'Loading categories...',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
        : _categories.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.cyan[50],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.category_rounded,
                        size: 64,
                        color: Colors.cyan[700],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Categories Yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create categories to organize your plants',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => _showAddEditDialog(),
                      icon: const Icon(Icons.add_rounded, size: 20),
                      label: const Text('Create First Category'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyan[700],
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  // Add Button
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton.icon(
                      onPressed: () => _showAddEditDialog(),
                      icon: const Icon(Icons.add_rounded,
                          size: 20, color: Colors.white),
                      label: const Text(
                        'Add New Category',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyan[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  // Categories Grid
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        children: List.generate(
                          _categories.length,
                          (index) => _buildCategoryCard(_categories[index]),
                        ),
                      ),
                    ),
                  ),
                ],
              );
  }

  Widget _buildCategoryCard(dynamic category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                // Icon Container
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.cyan[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.cyan[200]!),
                  ),
                  child: Icon(
                    Icons.category_rounded,
                    color: Colors.cyan[700],
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category['name'] ?? 'Unknown',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        category['description'] ?? 'No description',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () => _showAddEditDialog(category: category),
                      icon: const Icon(Icons.edit_rounded, size: 18),
                      label: const Text(
                        'Edit',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () => _deleteCategory(
                        category['_id'] ?? category['id'],
                        category['name'],
                      ),
                      icon: const Icon(Icons.delete_rounded, size: 18),
                      label: const Text(
                        'Delete',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
