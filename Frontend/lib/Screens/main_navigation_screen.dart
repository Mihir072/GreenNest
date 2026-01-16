import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'favorites_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final String email;
  final String token;

  const MainNavigationScreen({
    required this.email,
    required this.token,
    Key? key,
  }) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  List<dynamic> _cart = [];
  List<dynamic> _favorites = [];
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _updateCart(List<dynamic> newCart) {
    setState(() {
      _cart = newCart;
    });
  }

  void _updateFavorites(List<dynamic> newFavorites) {
    setState(() {
      _favorites = newFavorites;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics:
            const NeverScrollableScrollPhysics(), // Disable swipe, use nav bar only
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: [
          // Home Screen
          HomeScreen(
            email: widget.email,
            token: widget.token,
            cart: _cart,
            favorites: _favorites,
            onCartUpdated: _updateCart,
            onFavoritesUpdated: _updateFavorites,
          ),
          // Favorites Screen
          FavoritesScreen(
            email: widget.email,
            token: widget.token,
            favorites: _favorites,
            cart: _cart,
            onFavoritesUpdated: _updateFavorites,
            onCartUpdated: _updateCart,
            onAddToCart: (item) {
              setState(() {
                _cart.add(item);
              });
            },
          ),
          // Orders Screen
          OrdersScreen(
            email: widget.email,
            token: widget.token,
          ),
          // Profile Screen
          ProfileScreen(
            email: widget.email,
            token: widget.token,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.green[700],
        unselectedItemColor: Colors.grey[600],
        elevation: 8,
        onTap: _onNavItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_rounded),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_rounded),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
