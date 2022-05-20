import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/orders.dart';
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/order_item.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late Future _ordersFuture;

  Future _obtainOrdersFuture() {
    return Provider.of<Orders>(context, listen: false).fetchData();
  }

  @override
  void initState() {
    _ordersFuture = _obtainOrdersFuture();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Order'),
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder(
        future: _ordersFuture,
        builder: (context, data) {
          if (data.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (data.connectionState == ConnectionState.done) {
            return Consumer<Orders>(builder: (context, orderData, child) {
              return ListView.builder(
                itemCount: orderData.orders.length,
                itemBuilder: (context, index) {
                  return OrderItem(order: orderData.orders[index]);
                },
              );
            });
          } else {
            return Container();
          }
        },
      ),
    );
  }
}
