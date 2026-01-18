// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:greennest/Helper/media_query_extensions.dart';
import 'package:greennest/Helper/navigation_extensions.dart';
import 'package:greennest/Helper/spacing_helper.dart';
import 'package:greennest/Util/colors.dart';
import 'package:greennest/Util/icons.dart';
import 'package:greennest/Util/sizes.dart';
import 'package:greennest/Util/strings.dart';
import 'package:greennest/Widget/custom_text.dart';
import 'package:greennest/Widget/custom_text_field2.dart';
import 'package:greennest/Widget/custom_toast.dart';
import 'package:greennest/services/api_service.dart';
import 'dart:convert';
import 'cart_screen.dart';
import 'plant_detail_screen.dart';
import 'profile_screen.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  final String email;
  final String token;
  final List<dynamic>? cart;
  final List<dynamic>? favorites;
  final Function(List<dynamic>)? onCartUpdated;
  final Function(List<dynamic>)? onFavoritesUpdated;

  const HomeScreen({
    super.key,
    required this.email,
    required this.token,
    this.cart,
    this.favorites,
    this.onCartUpdated,
    this.onFavoritesUpdated,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  List<dynamic> plants = [];
  List<dynamic> categories = [];
  List<dynamic> cart = [];
  List<dynamic> favorites = [];
  String searchQuery = '';
  String selectedCategory = 'all';
  String username = '';
  bool isLoadingCategories = true;
  bool isLoadingPlants = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    fetchCategories();
    fetchPlants('', 'all');
    fetchUserInfo();
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update favorites if they changed from parent
    if (oldWidget.favorites != widget.favorites) {
      setState(() {
        favorites = List.from(widget.favorites ?? []);
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh data when returning to this screen
      print('HomeScreen resumed - refreshing data');
      fetchCategories();
      fetchPlants(searchQuery, selectedCategory);
      fetchUserInfo();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> fetchCategories() async {
    try {
      final response = await ApiService.getCategories();
      print('Categories Response Status: ${response.statusCode}');
      print('Categories Response Body: ${response.body}');

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

        print('Parsed ${categoriesList.length} categories');
        setState(() {
          categories = categoriesList;
          isLoadingCategories = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoadingCategories = false;
      });
      print('Error fetching categories: $e');
    }
  }

  Future<void> fetchPlants(String query, String category) async {
    setState(() {
      isLoadingPlants = true;
    });

    try {
      final response = query.isEmpty
          ? await ApiService.getPlants(
              category: category != 'all' ? category : null)
          : await ApiService.searchPlants(query,
              category: category != 'all' ? category : null);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Handle both direct array and paginated response
        List<dynamic> plantsList;
        if (responseData is List) {
          plantsList = responseData;
        } else if (responseData is Map && responseData.containsKey('content')) {
          plantsList = responseData['content'] ?? [];
        } else if (responseData is Map && responseData.containsKey('data')) {
          plantsList = responseData['data'] ?? [];
        } else {
          plantsList = [];
        }

        setState(() {
          searchQuery = query;
          selectedCategory = category;
          plants = plantsList;
          isLoadingPlants = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoadingPlants = false;
      });
      CustomToast.error(
        title: 'Load Failed',
        message: 'Unable to fetch plants. Check your connection',
      );
      print('Error fetching plants: $e');
    }
  }

  Future<void> fetchUserInfo() async {
    try {
      final response = await ApiService.getUserByEmail(widget.email);
      if (response.statusCode == 200) {
        final user = jsonDecode(response.body);
        setState(() {
          username = user['name'] ?? '';
        });
      }
    } catch (e) {
      print('Error fetching user info: $e');
      CustomToast.warning(
        title: 'User Info',
        message: 'Could not load profile. Pull to refresh',
      );
    }
  }

  void addToCart(dynamic plant) {
    setState(() {
      cart.add({...plant, 'quantity': 1});
    });
  }

  void _toggleFavorite(Map<String, dynamic> plant) {
    setState(() {
      final index = favorites.indexWhere((fav) => fav['id'] == plant['id']);
      if (index >= 0) {
        // Remove from favorites
        favorites.removeAt(index);
      } else {
        // Add to favorites
        favorites.add(plant);
      }
    });
    // Update parent widget
    if (widget.onFavoritesUpdated != null) {
      widget.onFavoritesUpdated!(favorites);
    }
  }

  void _addToCartFromDetail(Map<String, dynamic> plant) {
    setState(() {
      cart.add({...plant, 'quantity': 1});
    });
    // Update parent widget
    if (widget.onCartUpdated != null) {
      widget.onCartUpdated!(cart);
    }
  }

  int getTotalAmount() {
    return cart.fold(
        0,
        (sum, item) =>
            sum + ((item['price'] as num) * (item['quantity'] as num)).toInt());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: splashScreenColor,

      //--------------------- BODY ---------------------//
      body: SafeArea(
        top: false,
        bottom: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(
                      text: 'Hey, $username',
                      textColor: white,
                      textSize: GSizes.fontSizeLg,
                      fontWeight: FontWeight.bold),
                  GestureDetector(
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(profileHome),
                      radius: 20,
                    ),
                    onTap: () => context.push(
                      ProfileScreen(email: widget.email, token: widget.token),
                    ),
                  ),
                ],
              ),
            ),

            // Welcome Message
            Padding(
              padding: EdgeInsets.only(right: 8, left: 12, bottom: 20),
              child: CustomText(
                  text: welcomeLine,
                  textColor: white,
                  textSize: GSizes.fontSizeSm,
                  fontWeight: FontWeight.normal),
            ),

            // Search Bar
            Padding(
              padding: EdgeInsets.only(right: 15, left: 15, bottom: 20),
              child: CustomTextField2(
                hintText: searchPlants,
                keyboardType: TextInputType.text,
                textFieldImage: treeHome,
                onChanged: (val) {
                  fetchPlants(val, selectedCategory);
                },
              ),
            ),

            // Category Filter Chips
            isLoadingCategories
                ? Padding(
                    padding: EdgeInsets.only(left: 15, bottom: 15),
                    child: SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                width: 80,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Padding(
                    padding: EdgeInsets.only(left: 15, bottom: 15, right: 15),
                    child: SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            // "All" chip
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: CustomText(
                                  text: 'All Plants',
                                  textColor: selectedCategory == 'all'
                                      ? Colors.white
                                      : Colors.grey[700] ?? Colors.grey,
                                  textSize: GSizes.fontSizeSm,
                                  fontWeight: FontWeight.w600,
                                ),
                                selected: selectedCategory == 'all',
                                onSelected: (bool selected) {
                                  if (selected) {
                                    fetchPlants(searchQuery, 'all');
                                  }
                                },
                                backgroundColor: Colors.white,
                                selectedColor: Colors.green.shade600,
                                side: BorderSide(
                                  color: selectedCategory == 'all'
                                      ? Colors.green.shade600
                                      : Colors.grey[300]!,
                                ),
                              ),
                            );
                          }

                          final category = categories[index - 1];
                          final categoryName = category['name'] ?? '';
                          final categoryId = category['id'] ?? '';

                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: CustomText(
                                text: categoryName,
                                textColor: selectedCategory == categoryName
                                    ? white
                                    : Colors.grey[700] ?? Colors.grey,
                                textSize: GSizes.fontSizeSm,
                                fontWeight: FontWeight.w600,
                              ),
                              selected: selectedCategory == categoryName,
                              onSelected: (bool selected) {
                                if (selected) {
                                  fetchPlants(searchQuery, categoryName);
                                }
                              },
                              backgroundColor: Colors.white,
                              selectedColor: Colors.green.shade600,
                              side: BorderSide(
                                color: selectedCategory == categoryName
                                    ? Colors.green.shade600
                                    : Colors.grey[300]!,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

            //--------------------- PLANT LIST ---------------------//
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(36),
                        topRight: Radius.circular(36))),
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: isLoadingPlants
                      ? Center(
                          child: CircularProgressIndicator(
                            color: Colors.green[700],
                          ),
                        )
                      : plants.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.eco,
                                      size: 64, color: Colors.grey[400]),
                                  const SizedBox(height: 16),
                                  CustomText(
                                    text: 'No plants found',
                                    textColor: Colors.grey[600] ?? Colors.grey,
                                    textSize: GSizes.fontSizeMd,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  const SizedBox(height: 8),
                                  CustomText(
                                    text: 'Try a different search or category',
                                    textColor: Colors.grey[500] ?? Colors.grey,
                                    textSize: GSizes.fontSizeSm,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: () async {
                                await fetchPlants('', selectedCategory);
                              },
                              child: GridView.builder(
                                shrinkWrap: true,
                                physics: const AlwaysScrollableScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 12,
                                  childAspectRatio: 0.68,
                                ),
                                padding: const EdgeInsets.all(12),
                                itemCount: plants.length,
                                itemBuilder: (context, index) {
                                  final plant = plants[index];

                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              PlantDetailScreen(
                                            plant: plant,
                                            favorites: favorites,
                                            onFavoriteToggle: _toggleFavorite,
                                            onAddToCart: _addToCartFromDetail,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Material(
                                      elevation: 2,
                                      borderRadius: BorderRadius.circular(16),
                                      shadowColor: Colors.grey.shade200,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Image Container
                                            Stack(
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius
                                                          .vertical(
                                                    top: Radius.circular(16),
                                                  ),
                                                  child: Container(
                                                    height: 130,
                                                    width: double.infinity,
                                                    color: Colors.grey[200],
                                                    child: Image.network(
                                                      plant['imageUrl'] ?? '',
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context,
                                                          error, stackTrace) {
                                                        // Show placeholder with plant name instead of error
                                                        return Container(
                                                          color:
                                                              Colors.grey[300],
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .image_not_supported,
                                                                color: Colors
                                                                    .grey[600],
                                                                size: 40,
                                                              ),
                                                              const SizedBox(
                                                                  height: 8),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        8.0),
                                                                child: Text(
                                                                  plant['name'] ??
                                                                      'Plant',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: Colors
                                                                            .grey[
                                                                        700],
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                                // Category Badge
                                                Positioned(
                                                  top: 8,
                                                  right: 8,
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.green[700],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                    ),
                                                    child: Text(
                                                      plant['category'] ?? '',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),

                                            // Content Section
                                            Expanded(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(12),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    // Plant Name
                                                    Text(
                                                      plant['name'] ?? 'Plant',
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: Colors.black,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(height: 2),
                                                    // Price
                                                    Text(
                                                      '₹${plant['price'] ?? '0'}',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color:
                                                            Colors.green[700],
                                                      ),
                                                    ),
                                                    const Spacer(),
                                                    // Add to Cart Button
                                                    SizedBox(
                                                      width: double.infinity,
                                                      height: 36,
                                                      child:
                                                          ElevatedButton.icon(
                                                        onPressed: () =>
                                                            addToCart(plant),
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              Colors.green[700],
                                                          elevation: 0,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                          ),
                                                        ),
                                                        icon: const Icon(
                                                          Icons
                                                              .add_shopping_cart,
                                                          size: 16,
                                                          color: Colors.white,
                                                        ),
                                                        label: const Text(
                                                          'Add',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: Colors.white,
                                                          ),
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
                                  );
                                },
                              ),
                            ),
                ),
              ),
            ),
          ],
        ),
      ),

      //--------------------- CART BOX ---------------------//
      bottomNavigationBar: cart.isNotEmpty
          ? GestureDetector(
              onTap: () => context.push(CartScreen(
                token: widget.token,
                cart: cart,
                email: widget.email,
                onOrderPlaced: () {
                  setState(() {
                    cart.clear();
                  });
                },
                onCartUpdated: (updatedCart) {
                  setState(() {
                    cart = updatedCart;
                  });
                },
              )),
              child: Container(
                height: context.heightPct(11),
                color: cartBoxColor,
                padding: Spacing.all16,
                child: Column(
                  children: [
                    CustomText(
                        text: '${cart.length} items added ➲',
                        textColor: white,
                        textSize: GSizes.fontSizeLg,
                        fontWeight: FontWeight.bold),
                    CustomText(
                        text: 'Total: ₹${getTotalAmount()}',
                        textColor: white,
                        textSize: GSizes.fontSizeMd,
                        fontWeight: FontWeight.normal),
                  ],
                ),
              ),
            )
          : const SizedBox(),
    );
  }
}

// Simple shimmer placeholder (optional - can be replaced with actual shimmer package)
class Shimmer extends StatelessWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;

  const Shimmer({
    Key? key,
    required this.child,
    required this.baseColor,
    required this.highlightColor,
  }) : super(key: key);

  static Widget fromColors({
    required Color baseColor,
    required Color highlightColor,
    required Widget child,
  }) {
    return Shimmer(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
