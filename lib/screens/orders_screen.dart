import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/models/order_item.dart' as ord;
import 'package:shop_app/providers/orders.dart';
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/order_item.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = '/orders';
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<ord.OrderItem> orders = Provider.of<Orders>(context).orders;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Order'),
      ),
      drawer: const AppDrawer(),
      body: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return OrderItem(order: orders[index]);
        },
      ),
    );
  }
}
