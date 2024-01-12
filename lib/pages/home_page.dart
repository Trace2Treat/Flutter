import 'package:flutter/material.dart';
import 'package:bottom_navigation_view/bottom_navigation_view.dart';
import 'dashboard_page.dart';
// import 'search_page.dart';
// import 'favorite_page.dart';
// import 'profile_page.dart';
import '../theme/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late final BottomNavigationController _controller;
  DateTime? currentBackPressTime;

  @override
  void initState() {
    super.initState();
    _controller = BottomNavigationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        DateTime now = DateTime.now();
        if (currentBackPressTime == null || now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
          currentBackPressTime = now;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Press back again to exit the app'),
            ),
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: BottomNavigationView(
          controller: _controller,
          transitionType: BottomNavigationTransitionType.none,
          children: const [
            DashboardPage(),
            DefaultPage(color: Colors.green, name: 'Search'),
            DefaultPage(color: Colors.green, name: 'Favorite'),
            DefaultPage(color: Colors.green, name: 'Profile'),
          ],
        ),
        bottomNavigationBar: BottomNavigationIndexedBuilder(
          controller: _controller,
          builder: (context, index, child) {
            return BottomNavigationBar(
              currentIndex: index,
              onTap: (index) {
                _controller.goTo(index);
              },
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  label: 'Home', 
                  icon: Icon(Icons.home_outlined, color: AppColors.primary),
                  activeIcon: Icon(Icons.home, color: AppColors.primary)
                ),
                BottomNavigationBarItem(
                  label: 'Search', 
                  icon: Icon(Icons.search, color: AppColors.primary),
                  activeIcon: Icon(Icons.search, color: AppColors.primary)
                ),
                BottomNavigationBarItem(
                  label: 'Favorite', 
                  icon: Icon(Icons.favorite_border_outlined, color: AppColors.primary),
                  activeIcon: Icon(Icons.favorite, color: AppColors.primary),
                ),
                BottomNavigationBarItem(
                  label: 'Profile', 
                  icon: Icon(Icons.person_2_outlined, color: AppColors.primary),
                  activeIcon: Icon(Icons.person, color: AppColors.primary),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class DefaultPage extends StatelessWidget {
  final Color color;
  final String name;

  const DefaultPage({Key? key, required this.color, required this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: Container(
        color: color,
        child: Center(
          child: Text(
            'This is the $name Page',
            style: const TextStyle(fontSize: 20, color: Colors.white),
          ),
        ),
      ),
    );
  }
}