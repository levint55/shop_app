// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/widgets/products_grid.dart';
import 'package:shop_app/widgets/badge.dart';

enum FilterOptions {
  favorite,
  all,
}

class ProductsOverviewScreen extends StatefulWidget {
  const ProductsOverviewScreen({Key? key}) : super(key: key);

  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  bool _showOnlyFavorites = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyShop'),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (FilterOptions selectedValue) {
              setState(() {
                if (selectedValue == FilterOptions.all) {
                  _showOnlyFavorites = false;
                } else if (selectedValue == FilterOptions.favorite) {
                  _showOnlyFavorites = true;
                }
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                child: Text('Only Favorites'),
                value: FilterOptions.favorite,
              ),
              PopupMenuItem(
                child: Text('Show All'),
                value: FilterOptions.all,
              )
            ],
            icon: Icon(
              Icons.more_vert,
            ),
          ),
          Consumer<Cart>(
            builder: (context, cart, child) => Badge(
              value: cart.itemCount.toString(),
              child: child!,
            ),
            child: IconButton(
              icon: Icon(
                Icons.shopping_cart,
              ),
              onPressed: () {},
            ),
          )
        ],
      ),
      body: ProductsGrid(
        showOnlyFavorites: _showOnlyFavorites,
      ),
    );
  }
}
