import 'package:flutter/material.dart';
import 'category_page.dart';
import 'dish_page.dart';

class MenuManagementPage extends StatefulWidget {
  const MenuManagementPage({super.key});

  @override
  State<MenuManagementPage> createState() => _MenuManagementPageState();
}

class _MenuManagementPageState extends State<MenuManagementPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Theme.of(context).primaryColor,
          child: TabBar(
            indicatorColor: Colors.purple,
            unselectedLabelColor: Colors.white60,
            labelColor: Colors.white,
            controller: _tabController,
            tabs: const [
              Tab(text: 'Categorie',),
              Tab(text: 'Piatti'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              CategoryPage(),
              DishPage(),
            ],
          ),
        ),
      ],
    );
  }
}
