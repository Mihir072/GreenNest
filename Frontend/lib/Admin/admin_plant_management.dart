import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:greennest/Services/api_service.dart';
import 'package:greennest/Widget/custom_toast.dart';

class AdminPlantManagement extends StatefulWidget {
  final String token;

  const AdminPlantManagement({required this.token, Key? key}) : super(key: key);

  @override
  State<AdminPlantManagement> createState() => _AdminPlantManagementState();
}

class _AdminPlantManagementState extends State<AdminPlantManagement> {
  List<dynamic> _plants = [];
  List<dynamic> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlants();
    _loadCategories();
  }

  Future<void> _loadPlants() async {
    try {
      final response = await ApiService.getAdminPlants(token: widget.token);
      print('Plants Response: ${response.body}');
      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        List<dynamic> plantsList = [];

        // Handle different response formats
        if (data is List) {
          plantsList = data;
        } else if (data is Map) {
          if (data.containsKey('data')) {
            plantsList = data['data'] ?? [];
          } else if (data.containsKey('content')) {
            plantsList = data['content'] ?? [];
          }
        }

        setState(() => _plants = plantsList);
      }
    } catch (e) {
      print('Error loading plants: $e');
      CustomToast.error(
        title: 'Load Error',
        message: 'Could not load plants',
      );
    }
    setState(() => _isLoading = false);
  }

  Future<void> _loadCategories() async {
    try {
      final response = await ApiService.getAdminCategories(token: widget.token);
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
      // Categories load failed, continue
    }
  }

  Future<void> _deletePlant(String plantId, String plantName) async {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Delete Plant'),
        content: Text('Are you sure you want to delete "$plantName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final response = await ApiService.deleteAdminPlant(
                  plantId,
                  token: widget.token,
                );
                if (response.statusCode == 200) {
                  CustomToast.success(
                    title: 'Plant Deleted',
                    message: 'Plant has been removed',
                  );
                  _loadPlants();
                } else {
                  CustomToast.error(
                    title: 'Delete Failed',
                    message: 'Could not delete plant',
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

  void _showAddEditDialog({dynamic plant}) {
    final isEdit = plant != null;
    final nameCtrl = TextEditingController(text: plant?['name'] ?? '');
    final descCtrl = TextEditingController(text: plant?['description'] ?? '');
    final priceCtrl =
        TextEditingController(text: plant?['price'].toString() ?? '');
    final stockCtrl =
        TextEditingController(text: plant?['stock'].toString() ?? '');
    final imageCtrl = TextEditingController(text: plant?['imageUrl'] ?? '');

    // Get the plant's current category
    String? plantCategory = plant?['category'];

    // Check if the plant's category exists in the available categories
    bool categoryExists =
        _categories.any((cat) => cat['name'] == plantCategory);

    // Set initial selected category - include legacy category if it exists
    String? selectedCategory = plantCategory;

    // Build dropdown items - include the plant's existing category if not in list
    List<DropdownMenuItem<String>> buildCategoryItems() {
      List<DropdownMenuItem<String>> items = _categories.map((cat) {
        return DropdownMenuItem<String>(
          value: cat['name'],
          child: Text(cat['name']),
        );
      }).toList();

      // If plant has a category that's not in the list, add it as an option
      if (plantCategory != null &&
          plantCategory.isNotEmpty &&
          !categoryExists) {
        items.insert(
            0,
            DropdownMenuItem<String>(
              value: plantCategory,
              child: Text('$plantCategory (legacy)'),
            ));
      }

      return items;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEdit ? 'Edit Plant' : 'Add Plant'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Plant Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceCtrl,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: stockCtrl,
                  decoration: const InputDecoration(labelText: 'Stock'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: imageCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Image URL',
                    helperText: 'Paste any image URL (jpg, png, etc.)',
                  ),
                  onChanged: (value) {
                    setState(() {}); // Rebuild on URL change
                  },
                ),
                const SizedBox(height: 12),
                // Image preview
                if (imageCtrl.text.isNotEmpty)
                  Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageCtrl.text,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.red[100],
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.broken_image,
                                    color: Colors.red, size: 40),
                                const SizedBox(height: 8),
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Invalid image URL.\nMake sure the URL points to a valid image.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category'),
                  hint: const Text('Select a category'),
                  items: buildCategoryItems(),
                  onChanged: (value) =>
                      setState(() => selectedCategory = value),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (nameCtrl.text.isEmpty ||
                    descCtrl.text.isEmpty ||
                    priceCtrl.text.isEmpty ||
                    stockCtrl.text.isEmpty ||
                    imageCtrl.text.isEmpty ||
                    selectedCategory == null) {
                  CustomToast.warning(
                    title: 'Incomplete Form',
                    message: 'Please fill in all required fields',
                  );
                  return;
                }

                // Validate image URL format
                if (!_isValidImageUrl(imageCtrl.text)) {
                  CustomToast.error(
                    title: 'Invalid URL',
                    message: 'Please enter a valid image URL',
                  );
                  return;
                }

                try {
                  final plantData = {
                    'name': nameCtrl.text,
                    'description': descCtrl.text,
                    'price': int.parse(priceCtrl.text),
                    'stock': int.parse(stockCtrl.text),
                    'imageUrl': imageCtrl.text,
                    'category': selectedCategory,
                  };

                  late final response;
                  if (isEdit) {
                    response = await ApiService.updateAdminPlant(
                      plant['id'],
                      plantData,
                      token: widget.token,
                    );
                  } else {
                    response = await ApiService.createAdminPlant(
                      plantData,
                      token: widget.token,
                    );
                  }

                  if (response.statusCode == 200 ||
                      response.statusCode == 201) {
                    Navigator.pop(context);
                    CustomToast.success(
                      title: isEdit ? 'Plant Updated' : 'Plant Added',
                      message: 'Changes have been saved',
                    );
                    _loadPlants();
                  } else {
                    final Map<String, dynamic> errorData =
                        jsonDecode(response.body);
                    CustomToast.error(
                      title: 'Save Failed',
                      message: 'Unable to save plant details',
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
      ),
    );
  }

  bool _isValidImageUrl(String url) {
    try {
      final uri = Uri.parse(url);

      // Just check if it's a valid absolute URL (http or https)
      // The image preview will handle actual image validation
      return uri.isAbsolute && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: Colors.green[700],
                  strokeWidth: 3,
                ),
                const SizedBox(height: 16),
                Text(
                  'Loading plants...',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
        : _plants.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.amber[50],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.local_florist_rounded,
                        size: 64,
                        color: Colors.amber[700],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Plants Yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start adding plants to your inventory',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => _showAddEditDialog(),
                      icon: const Icon(Icons.add_rounded, size: 20),
                      label: const Text('Add First Plant'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
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
                        'Add New Plant',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
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
                  // Plant Grid
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: List.generate(
                          _plants.length,
                          (index) {
                            final plant = _plants[index];
                            return _buildPlantCard(plant);
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              );
  }

  Widget _buildPlantCard(dynamic plant) {
    return Container(
      width: (MediaQuery.of(context).size.width - 36) / 2,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          Container(
            height: 140,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
              color: Colors.grey[200],
              image: plant['imageUrl'] != null
                  ? DecorationImage(
                      image: NetworkImage(plant['imageUrl']),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: plant['imageUrl'] == null
                ? Center(
                    child: Icon(
                      Icons.image_not_supported_rounded,
                      color: Colors.grey[400],
                      size: 40,
                    ),
                  )
                : null,
          ),
          // Content Section
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Plant Name
                Text(
                  plant['name'] ?? 'Unknown',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                // Category Badge
                if (plant['category'] != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.green[300]!),
                    ),
                    child: Text(
                      plant['category'],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.green[700],
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                // Price and Stock Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Price',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '₹${plant['price'] ?? 0}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Stock',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: (plant['stock'] ?? 0) > 5
                                ? Colors.green[50]
                                : Colors.orange[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${plant['stock'] ?? 0}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: (plant['stock'] ?? 0) > 5
                                  ? Colors.green[700]
                                  : Colors.orange[700],
                            ),
                          ),
                        ),
                      ],
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
                          onPressed: () => _showAddEditDialog(plant: plant),
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
                          onPressed: () => _deletePlant(
                            plant['_id'] ?? plant['id'],
                            plant['name'],
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
        ],
      ),
    );
  }
}
