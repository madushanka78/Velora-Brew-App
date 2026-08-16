import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending': return Colors.orange;
      case 'Preparing': return Colors.blueAccent;
      case 'Delivering': return Colors.purpleAccent;
      case 'Delivered': return Colors.green;
      default: return Colors.white54;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A110C),
        title: const Text('Admin Dashboard', style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.amberAccent),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.amber));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No orders found', style: TextStyle(color: Colors.white54)));
          }

          var orders = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              var doc = orders[index];
              var data = doc.data() as Map<String, dynamic>;
              
              String status = data['status'] ?? 'Pending';
              double total = data['finalTotal'] ?? 0.0;
              String address = data['deliveryAddress'] ?? 'N/A';
              String mobile = data['mobileNumber'] ?? 'N/A';
              List<dynamic> items = data['items'] ?? [];
              
              String itemsSummary = items.map((item) => "${item['nameEn']} (x1)").join(', ');
              
              return Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E140F),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: _getStatusColor(status).withOpacity(0.5), width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Order ID: ${doc.id.substring(0, 8)}...', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                        Text('Rs. ${total.toStringAsFixed(2)}', style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text('Items: $itemsSummary', style: const TextStyle(color: Colors.amber, fontSize: 13)),
                    const SizedBox(height: 5),
                    Text('Address: $address', style: const TextStyle(color: Colors.white, fontSize: 14)),
                    Text('Mobile: $mobile', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                    
                    const Divider(color: Colors.white24, height: 25),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Update Status:', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A2A2A),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButton<String>(
                            value: status,
                            dropdownColor: const Color(0xFF2A2A2A),
                            style: TextStyle(color: _getStatusColor(status), fontWeight: FontWeight.bold),
                            underline: Container(),
                            items: ['Pending', 'Preparing', 'Delivering', 'Delivered']
                                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                .toList(),
                            onChanged: (newStatus) {
                              if (newStatus != null) {
                                FirebaseFirestore.instance.collection('orders').doc(doc.id).update({'status': newStatus});
                              }
                            },
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}