import 'package:flutter/material.dart';
import '../data/app_data.dart';

class OrderTrackingScreen extends StatelessWidget {
  final int pointsEarned;
  const OrderTrackingScreen({super.key, required this.pointsEarned});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(t('Delivery Tracking', 'ඇණවුම ලුහුබැඳීම'), style: const TextStyle(color: Colors.white)), automaticallyImplyLeading: false),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage('https://upload.wikimedia.org/wikipedia/commons/thumb/c/cd/Sri_Lanka_location_map.svg/1024px-Sri_Lanka_location_map.svg.png'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.black45, BlendMode.darken),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 150,
                    child: Column(
                      children: [
                        const Icon(Icons.location_on, color: Colors.redAccent, size: 50),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: const Color(0xFF1E140F), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.amber)),
                          child: Text(t('Delivery to Colombo, LK', 'කොළඹට ප්‍රවාහනය කෙරේ'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(color: Color(0xFF1A110C), borderRadius: BorderRadius.vertical(top: Radius.circular(30)), boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, -5))]),
              child: Column(
                children: [
                  Text(t('Payment Successful!', 'ගෙවීම සාර්ථකයි!'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
                  const SizedBox(height: 8),
                  Text(t('🎉 You earned $pointsEarned Loyalty Points!', '🎉 ඔබට ලකුණු $pointsEarned ක් හිමිවිය!'), style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16)),
                  const Divider(height: 30, color: Colors.white24),
                  
                  _buildTrackStep(Icons.receipt_long, t('Order Confirmed', 'ඇණවුම තහවුරු කර ඇත'), true),
                  _buildTrackStep(Icons.soup_kitchen, t('Preparing your order', 'ඇණවුම සූදානම් කරමින් පවතී'), true),
                  _buildTrackStep(Icons.moped, t('Out for Delivery', 'බෙදා හැරීම සඳහා පිටත් කර ඇත'), false),
                  _buildTrackStep(Icons.home, t('Delivered', 'ලබා දෙන ලදී'), false),
                  
                  const Spacer(),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5D4037), minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                    onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                    child: Text(t('Back to Home', 'ප්‍රධාන පිටුවට'), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTrackStep(IconData icon, String title, bool isDone) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: isDone ? Colors.green.withOpacity(0.2) : Colors.white10, shape: BoxShape.circle),
            child: Icon(icon, color: isDone ? Colors.green : Colors.white54, size: 28),
          ),
          const SizedBox(width: 15),
          Expanded(child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDone ? Colors.white : Colors.white54))),
        ],
      ),
    );
  }
}