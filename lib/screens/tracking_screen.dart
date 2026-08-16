import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/app_data.dart';

class TrackingScreen extends StatefulWidget {
  final String address;
  final String? orderId;
  const TrackingScreen({super.key, required this.address, this.orderId});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  String? _activeOrderId;
  int _rating = 0;
  final TextEditingController _feedbackController = TextEditingController();
  bool _isFeedbackSubmitted = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initOrderTracking();
  }

  Future<void> _initOrderTracking() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    if (widget.orderId != null) {
      _activeOrderId = widget.orderId;
      await prefs.setString('saved_order_id', widget.orderId!);
      await prefs.setString('saved_address', widget.address);
    } else {
      _activeOrderId = prefs.getString('saved_order_id');
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF121212),
        body: Center(child: CircularProgressIndicator(color: Colors.amber)),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1A110C),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.amberAccent),
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
          ),
          title: Text(t('Track Order', 'ඇණවුම ලුහුබැඳීම'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        body: _activeOrderId == null
            ? Center(child: Text(t("No active orders found.", "ක්‍රියාකාරී ඇණවුම් නොමැත."), style: const TextStyle(color: Colors.white54, fontSize: 16)))
            : StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('orders').doc(_activeOrderId).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.amber));
                  }
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return Center(child: Text(t("Order details not found.", "ඇණවුම් විස්තර හමුවුණේ නැත."), style: const TextStyle(color: Colors.white54)));
                  }

                  var data = snapshot.data!.data() as Map<String, dynamic>;
                  String status = data['status'] ?? 'Pending';
                  String deliveryAddress = data['deliveryAddress'] ?? widget.address;

                  int currentStep = 1;
                  if (status == 'Preparing') currentStep = 2;
                  if (status == 'Delivering') currentStep = 3;
                  if (status == 'Delivered') currentStep = 4;

                  if (currentStep == 4) {
                    SharedPreferences.getInstance().then((prefs) {
                      prefs.remove('saved_order_id');
                      prefs.remove('saved_address');
                    });
                  }

                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t('Order Status', 'ඇණවුමේ තත්වය'), 
                            style: const TextStyle(color: Colors.amberAccent, fontSize: 24, fontWeight: FontWeight.bold)
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${t('Delivering to: ', 'බාරදෙන ස්ථානය: ')} $deliveryAddress',
                            style: const TextStyle(color: Colors.white54, fontSize: 13),
                          ),
                          const SizedBox(height: 35),
                          
                          _buildTrackingStep(1, currentStep, Icons.receipt_long, t('Order Placed', 'ඇණවුම ලැබුණි'), t('We have received your order.', 'අපට ඔබගේ ඇණවුම ලැබී ඇත.')),
                          _buildTrackingLine(1, currentStep),
                          
                          _buildTrackingStep(2, currentStep, Icons.coffee_maker, t('Preparing Brew', 'කෝපි සකසමින් පවතී'), t('Your order is being prepared.', 'ඔබගේ ඇණවුම සූදානම් කරමින් පවතී.')),
                          _buildTrackingLine(2, currentStep),
                          
                          _buildTrackingStep(3, currentStep, Icons.two_wheeler, t('Out for Delivery', 'බාරදීම සඳහා පිටත්ව ඇත'), t('Rider is on the way to your location.', 'රියදුරා ඔබ වෙත පැමිණෙමින් සිටී.')),
                          _buildTrackingLine(3, currentStep),
                          
                          _buildTrackingStep(4, currentStep, Icons.check_circle_rounded, t('Delivered', 'බාරදුන්නා'), t('Order accepted by the customer.', 'පාරිභෝගිකයා විසින් ඇණවුම ලබා ගන්නා ලදී.')),

                          if (currentStep == 4) ...[
                            const SizedBox(height: 40),
                            _buildFeedbackSection(),
                          ]
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildTrackingStep(int step, int currentStep, IconData icon, String title, String subtitle) {
    bool isCompleted = currentStep >= step;
    bool isActive = currentStep == step;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(15), 
          decoration: BoxDecoration(
            color: isCompleted ? Colors.amber : const Color(0xFF2D1810),
            shape: BoxShape.circle,
            boxShadow: isActive ? [BoxShadow(color: Colors.amber.withOpacity(0.5), blurRadius: 15, spreadRadius: 2)] : [],
          ),
          child: Icon(icon, color: isCompleted ? Colors.black : Colors.white54, size: 28),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: isCompleted ? Colors.white : Colors.white54, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(color: isCompleted ? Colors.white70 : Colors.white38, fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrackingLine(int step, int currentStep) {
    bool isCompleted = currentStep > step;
    return Container(
      margin: const EdgeInsets.only(left: 28, top: 5, bottom: 5), 
      width: 3,
      height: 45,
      color: isCompleted ? Colors.amber : const Color(0xFF2D1810),
    );
  }

  Widget _buildFeedbackSection() {
    if (_isFeedbackSubmitted) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.greenAccent.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            const Icon(Icons.favorite, color: Colors.greenAccent, size: 40),
            const SizedBox(height: 10),
            Text(
              t('Thank you for your feedback!', 'ඔබගේ ප්‍රතිචාරයට ස්තූතියි!'),
              style: const TextStyle(color: Colors.greenAccent, fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E140F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amberAccent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            t('How was your order?', 'ඔබගේ ඇණවුම කෙසේද?'),
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                icon: Icon(
                  index < _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: Colors.amberAccent,
                  size: 35,
                ),
                onPressed: () => setState(() => _rating = index + 1),
              );
            }),
          ),
          const SizedBox(height: 15),
          
          TextField(
            controller: _feedbackController,
            style: const TextStyle(color: Colors.white),
            maxLines: 2,
            decoration: InputDecoration(
              hintText: t('Leave a comment...', 'ඔබගේ අදහස මෙහි ලියන්න...'),
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: const Color(0xFF121212),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                if (_rating > 0) {
                  setState(() => _isFeedbackSubmitted = true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(t('Please give a rating first!', 'කරුණාකර තරු මඟින් රේටින් එකක් ලබා දෙන්න!')),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              },
              child: Text(t('SUBMIT', 'යොමු කරන්න'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}