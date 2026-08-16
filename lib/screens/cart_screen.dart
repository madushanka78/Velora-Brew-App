import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/app_data.dart';
import '../app_provider.dart';
import 'payment_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final cartItems = appProvider.cartItems;

    final Map<String, Map<String, dynamic>> groupedItems = {};
    for (var item in cartItems) {
      String nameEn = item['nameEn'] ?? '';
      if (groupedItems.containsKey(nameEn)) {
        groupedItems[nameEn]!['quantity'] = (groupedItems[nameEn]!['quantity'] as int) + 1;
      } else {
        groupedItems[nameEn] = {
          'item': item,
          'quantity': 1,
        };
      }
    }

    final cartList = groupedItems.values.toList();
    final total = appProvider.cartSubTotal;

    void removeItemDialog(String itemName, String nameEn) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1A110C),
          title: Text(t('Remove Item', 'අයිතමය ඉවත් කරන්න'), style: const TextStyle(color: Colors.amber)),
          content: Text(t('Are you sure you want to remove all $itemName?', 'ඔබට විශ්වාසද ඔබට සියලු $itemName ඉවත් කිරීමට අවශ්‍යද?'), style: const TextStyle(color: Colors.white70)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t('Cancel', 'අවලංගු කරන්න'), style: const TextStyle(color: Colors.white38))),
            TextButton(
              onPressed: () {
                context.read<AppProvider>().removeAllByEnName(nameEn);
                Navigator.pop(ctx);
              },
              child: Text(t('Remove', 'ඉවත් කරන්න'), style: const TextStyle(color: Colors.redAccent)),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: cartList.isEmpty
          ? Center(
              child: Text(
                t('Your cart is empty', 'ඔබගේ කරත්තය හිස්ය'),
                style: const TextStyle(color: Colors.white54, fontSize: 18),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(15),
                    itemCount: cartList.length,
                    itemBuilder: (context, index) {
                      final entry = cartList[index];
                      final item = entry['item'];
                      final quantity = entry['quantity'] as int;
                      String itemName = t(item['nameEn'], item['nameSi']);
                      String nameEn = item['nameEn'];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E140F),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                item['image'] ?? '', 
                                width: 60, height: 60, fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  width: 60, height: 60, color: Colors.grey[850],
                                  child: const Icon(Icons.fastfood, color: Colors.amber, size: 24),
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    itemName,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Rs. ${item['price']}',
                                    style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.w600, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.amberAccent.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_rounded, color: Colors.amberAccent, size: 20),
                                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                                    padding: EdgeInsets.zero,
                                    onPressed: () {
                                      if (quantity > 1) {
                                        context.read<AppProvider>().removeOneItemByEnName(nameEn);
                                      } else {
                                        removeItemDialog(itemName, nameEn);
                                      }
                                    },
                                  ),
                                  Text(
                                    '$quantity',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_rounded, color: Colors.amberAccent, size: 20),
                                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                                    padding: EdgeInsets.zero,
                                    onPressed: () {
                                      context.read<AppProvider>().addToCart(item);
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 22),
                              onPressed: () => removeItemDialog(itemName, nameEn),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 85),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A110C),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    border: const Border(top: BorderSide(color: Colors.amberAccent, width: 1)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10)],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(t('Total', 'එකතුව'), style: const TextStyle(color: Colors.white70, fontSize: 16)),
                          Text(
                            'Rs. ${total.toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.amberAccent, fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          ),
                          onPressed: cartList.isEmpty ? null : () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentScreen()));
                          },
                          child: Text(t('CHECKOUT', 'ගෙවන්න'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}