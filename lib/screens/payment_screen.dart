import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart'; 
import 'package:latlong2/latlong.dart';       
import 'package:http/http.dart' as http; 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../data/app_data.dart';
import '../app_provider.dart';
import 'app_drawer.dart';
import 'tracking_screen.dart';

class ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;
    if (newValue.selection.baseOffset == 0) return newValue;
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex == 2 && nonZeroIndex != text.length) buffer.write('/');
    }
    var string = buffer.toString();
    return newValue.copyWith(text: string, selection: TextSelection.collapsed(offset: string.length));
  }
}

class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) return newValue;
    String enteredValue = newValue.text;
    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < enteredValue.length; i++) {
      buffer.write(enteredValue[i]);
      int nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != enteredValue.length) buffer.write(' ');
    }
    return newValue.copyWith(text: buffer.toString(), selection: TextSelection.collapsed(offset: buffer.toString().length));
  }
}

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  
  String _selectedMethod = 'Card';
  bool _isCvvHidden = true;
  String _cardNumber = '';
  String _selectedAddress = 'Colombo, Sri Lanka'; 
  final double _deliveryFee = 450.0;

  @override
  void dispose() {
    _mobileController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  String _getCardType() {
    if (_cardNumber.startsWith('4')) return 'VISA';
    if (_cardNumber.startsWith('5')) return 'MASTER';
    return '';
  }

  void _openMapSelector() {
    LatLng currentCenter = const LatLng(6.9271, 79.8612); 
    ValueNotifier<String> dialogAddressNotifier = ValueNotifier<String>("Searching location...");
    Timer? debounceTimer;
    final MapController mapController = MapController();
    final TextEditingController searchController = TextEditingController();

    Future<void> searchLocation(String query) async {
      if (query.trim().isEmpty) return;
      dialogAddressNotifier.value = "Searching...";
      try {
        final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=$query, Colombo District, Sri Lanka&format=json&limit=1');
        final response = await http.get(url, headers: {'User-Agent': 'VeloraBrewApp'});
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data.isNotEmpty) {
            double lat = double.parse(data[0]['lat']);
            double lon = double.parse(data[0]['lon']);
            LatLng newLoc = LatLng(lat, lon);
            mapController.move(newLoc, 15.0);
            currentCenter = newLoc;
            String name = data[0]['display_name'].split(',').first;
            dialogAddressNotifier.value = name.isNotEmpty ? name : "Location found";
          } else {
            dialogAddressNotifier.value = "Not found in Colombo";
          }
        }
      } catch (e) {
        dialogAddressNotifier.value = "Error searching";
      }
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1A110C),
        insetPadding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 5),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: "Search in Colombo...",
                        hintStyle: const TextStyle(color: Colors.white38),
                        prefixIcon: const Icon(Icons.search, color: Colors.amberAccent),
                        filled: true,
                        fillColor: const Color(0xFF2D1810),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                      onSubmitted: searchLocation,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(10)),
                    child: IconButton(
                      icon: const Icon(Icons.my_location, color: Colors.black),
                      iconSize: 24, 
                      onPressed: () {
                        mapController.move(const LatLng(6.9271, 79.8612), 15.0);
                        searchController.clear();
                      },
                    ),
                  ),
                ],
              ),
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(0)),
                  child: SizedBox(
                    height: 260,
                    width: MediaQuery.of(context).size.width,
                    child: FlutterMap(
                      mapController: mapController,
                      options: MapOptions(
                        initialCenter: currentCenter,
                        initialZoom: 15.0, 
                        maxZoom: 18.0,
                        minZoom: 11.0,
                        cameraConstraint: CameraConstraint.contain(
                          bounds: LatLngBounds(
                            const LatLng(6.65, 79.84), 
                            const LatLng(6.98, 80.25),
                          ),
                        ),
                        onPositionChanged: (camera, hasGesture) {
                          if (hasGesture) {
                            currentCenter = camera.center;
                            if (debounceTimer?.isActive ?? false) debounceTimer!.cancel();
                            debounceTimer = Timer(const Duration(milliseconds: 800), () async {
                              dialogAddressNotifier.value = "Loading map data...";
                              try {
                                final url = Uri.parse('https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=${currentCenter.latitude}&longitude=${currentCenter.longitude}&localityLanguage=en');
                                final response = await http.get(url);
                                if (response.statusCode == 200) {
                                  final data = json.decode(response.body);
                                  String locality = data['locality'] ?? '';
                                  String city = data['city'] ?? data['principalSubdivision'] ?? '';
                                  String formatted = [locality, city].where((e) => e.isNotEmpty).join(', ');
                                  if (formatted.isEmpty) formatted = "Colombo, Sri Lanka";
                                  dialogAddressNotifier.value = formatted;
                                } else {
                                  dialogAddressNotifier.value = "Location not found";
                                }
                              } catch (e) {
                                dialogAddressNotifier.value = "Location not found";
                              }
                            });
                          }
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
                          userAgentPackageName: 'com.velorabrew.app',
                        ),
                      ],
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on, color: Colors.redAccent, size: 45),
                    Container(
                      width: 10,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text('Confirm your Area', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ValueListenableBuilder<String>(
                    valueListenable: dialogAddressNotifier,
                    builder: (context, addressText, child) {
                      return ListTile(
                        tileColor: const Color(0xFF2D1810),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        leading: const Icon(Icons.check_circle_outline, color: Colors.amber),
                        title: Text(addressText, style: const TextStyle(color: Colors.amberAccent, fontSize: 13, fontWeight: FontWeight.bold)),
                        onTap: () {
                          if (addressText != "Searching location..." && addressText != "Loading map data..." && addressText != "Location not found" && addressText != "Searching..." && addressText != "Not found in Colombo") {
                            setState(() => _selectedAddress = addressText);
                            Navigator.pop(context);
                          }
                        },
                      );
                    }
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _processPayment(double subTotal, double discountAmount, double finalTotal, int usedPoints, int earnedPoints, AppProvider appProvider) {
    if (!_formKey.currentState!.validate()) {
      return; 
    }
    
    String paymentStatusMsg = _selectedMethod == 'COD' ? "Confirming Order..." : "Processing Bank Payment...";
    String fullAddress = "${_addressController.text.trim()}, $_selectedAddress";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: const Color(0xFF1E140F),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: Colors.amberAccent),
                const SizedBox(height: 20),
                Text(paymentStatusMsg, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                const SizedBox(height: 10),
                const Text("Please do not close the app", style: TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
        );
      },
    );

    Future.delayed(const Duration(seconds: 3), () async {
      Navigator.pop(context); 

      try {
        final orderData = {
          'items': appProvider.cartItems,
          'subTotal': subTotal,
          'deliveryFee': _deliveryFee,
          'discountAmount': discountAmount,
          'finalTotal': finalTotal,
          'usedPoints': usedPoints,
          'earnedPoints': earnedPoints,
          'deliveryAddress': fullAddress,
          'mobileNumber': _mobileController.text,
          'paymentMethod': _selectedMethod,
          'status': 'Pending', 
          'timestamp': FieldValue.serverTimestamp(),
        };

        final docRef = await FirebaseFirestore.instance.collection('orders').add(orderData);

        globalPoints.value = (globalPoints.value - usedPoints) + earnedPoints;
        appProvider.clearCart();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_selectedMethod == 'COD' ? 'Order Confirmed!' : 'Payment Successful!', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), 
              backgroundColor: Colors.green
            )
          );
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => TrackingScreen(address: fullAddress, orderId: docRef.id)));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to process. Try again.', style: TextStyle(color: Colors.white)), backgroundColor: Colors.redAccent)
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    double subTotal = appProvider.cartSubTotal;
    
    bool hasDiscount = globalPoints.value >= 300;
    int usedPoints = hasDiscount ? 300 : 0; 
    
    double discountAmount = hasDiscount ? (subTotal * 0.10) : 0; 
    double finalTotal = subTotal + _deliveryFee - discountAmount;
    int earnedPoints = (finalTotal / 100).floor(); 

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A110C),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: Colors.amberAccent, size: 28),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(t('Checkout', 'ගෙවීම් පිටුව'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t('Delivery Details', 'බාරදීමේ තොරතුරු'), style: const TextStyle(color: Colors.amberAccent, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _openMapSelector,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E140F), 
                      borderRadius: BorderRadius.circular(12), 
                      border: Border.all(color: Colors.white10)
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.map, color: Colors.amberAccent),
                        const SizedBox(width: 15),
                        Expanded(child: Text(_selectedAddress, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold))),
                        const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white38, size: 16),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _addressController,
                style: const TextStyle(color: Colors.white),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s,.\-/]'))], 
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Required';
                  final lowerVal = val.toLowerCase();
                  final outOfColomboDistricts = [
                    'hambantota', 'hambanthota', 'galle', 'matara', 'kandy', 'jaffna', 
                    'kurunegala', 'gampaha', 'kalutara', 'anuradhapura', 
                    'ratnapura', 'badulla', 'kegalle', 'nuwara eliya', 
                    'trincomalee', 'batticaloa', 'ampara', 'puttalam', 
                    'polonnaruwa', 'matale', 'monaragala', 'kilinochchi', 
                    'mannar', 'mullaitivu', 'vavuniya'
                  ];
                  for (String district in outOfColomboDistricts) {
                    if (lowerVal.contains(district)) {
                      return 'Delivery only available in Colombo District';
                    }
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: t('Home Address (House No, Street)', 'නිවසේ ලිපිනය'),
                  labelStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.home, color: Colors.amberAccent),
                  filled: true,
                  fillColor: const Color(0xFF1E140F),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 15),
              
              TextFormField(
                controller: _mobileController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.phone,
                maxLength: 10,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Required';
                  if (val.length != 10) return 'Must be 10 digits';
                  if (!val.startsWith('07')) return 'Invalid Sri Lankan number (Start with 07)';
                  return null;
                },
                decoration: InputDecoration(
                  labelText: t('Mobile Number', 'ජංගම දුරකථන අංකය'),
                  labelStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.phone, color: Colors.amberAccent),
                  counterText: "",
                  filled: true,
                  fillColor: const Color(0xFF1E140F),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 30),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E140F),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.amberAccent.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(t('Subtotal', 'එකතුව'), style: const TextStyle(color: Colors.white70, fontSize: 16)),
                        Text('Rs. ${subTotal.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(t('Delivery Fee', 'ප්‍රවාහන ගාස්තුව'), style: const TextStyle(color: Colors.white70, fontSize: 16)),
                        Text('+ Rs. ${_deliveryFee.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 16)),
                      ],
                    ),
                    if (hasDiscount) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(t('Discount (Uses 300 PTS)', 'වට්ටම (-300 PTS)'), style: const TextStyle(color: Colors.greenAccent, fontSize: 14)),
                          Text('- Rs. ${discountAmount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.greenAccent, fontSize: 14, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                    const Divider(color: Colors.white24, height: 25, thickness: 1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(t('Total Pay', 'ගෙවිය යුතු'), style: const TextStyle(color: Colors.amberAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('Rs. ${finalTotal.toStringAsFixed(2)}', style: const TextStyle(color: Colors.amberAccent, fontSize: 22, fontWeight: FontWeight.w900)),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.stars_rounded, color: Colors.amberAccent, size: 16),
                        const SizedBox(width: 5),
                        Text(
                          t('You will earn $earnedPoints PTS from this order', 'මෙම ඇණවුමෙන් ඔබට points $earnedPoints ක් හිමිවේ'), 
                          style: const TextStyle(color: Colors.white54, fontSize: 12)
                        ),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 30),

              Text(t('Payment Method', 'ගෙවීමේ ක්‍රමය'), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _paymentMethodOption('Card', Icons.credit_card, 'Visa/Master'),
                    const SizedBox(width: 12),
                    _paymentMethodOption('COD', Icons.payments_outlined, 'Cash on Delivery'),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              if (_selectedMethod == 'Card') ...[
                TextFormField(
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  maxLength: 19,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, CardNumberInputFormatter()],
                  onChanged: (val) => setState(() => _cardNumber = val),
                  validator: (val) => val!.length < 19 ? 'Invalid Card' : null,
                  decoration: InputDecoration(
                    labelText: t('Card Number', 'කාඩ්පත් අංකය'),
                    labelStyle: const TextStyle(color: Colors.white54),
                    prefixIcon: const Icon(Icons.credit_card, color: Colors.amberAccent),
                    suffixIcon: _getCardType().isNotEmpty 
                        ? Padding(padding: const EdgeInsets.all(12), child: Text(_getCardType(), style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)))
                        : null,
                    counterText: "",
                    filled: true,
                    fillColor: const Color(0xFF1E140F),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 15),
                
                TextFormField(
                  style: const TextStyle(color: Colors.white),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))], 
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Required';
                    if (RegExp(r'[0-9]').hasMatch(val)) return 'Numbers not allowed';
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: t('Name on Card', 'කාඩ්පතේ ඇති නම'),
                    labelStyle: const TextStyle(color: Colors.white54),
                    prefixIcon: const Icon(Icons.person, color: Colors.amberAccent),
                    filled: true,
                    fillColor: const Color(0xFF1E140F),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 15),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        maxLength: 5,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly, ExpiryDateFormatter()],
                        validator: (val) {
                          if (val == null || val.length < 5) return 'Invalid Format';
                          List<String> parts = val.split('/');
                          if (parts.length != 2) return 'Invalid';
                          int month = int.tryParse(parts[0]) ?? 0;
                          int year = int.tryParse(parts[1]) ?? 0;
                          if (month < 1 || month > 12) return 'Invalid Month';
                          if (year < 26) return 'Card Expired'; 
                          if (year == 26 && month < 8) return 'Card Expired'; 
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'MM/YY',
                          labelStyle: const TextStyle(color: Colors.white54),
                          prefixIcon: const Icon(Icons.calendar_month, color: Colors.amberAccent),
                          counterText: "",
                          filled: true,
                          fillColor: const Color(0xFF1E140F),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: TextFormField(
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        maxLength: 3,
                        obscureText: _isCvvHidden,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly], 
                        validator: (val) => val!.length < 3 ? 'Req' : null,
                        decoration: InputDecoration(
                          labelText: 'CVV',
                          labelStyle: const TextStyle(color: Colors.white54),
                          prefixIcon: const Icon(Icons.lock, color: Colors.amberAccent),
                          suffixIcon: IconButton(
                            icon: Icon(_isCvvHidden ? Icons.visibility_off : Icons.visibility, color: Colors.white38),
                            onPressed: () => setState(() => _isCvvHidden = !_isCvvHidden),
                          ),
                          counterText: "",
                          filled: true,
                          fillColor: const Color(0xFF1E140F),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  onPressed: () => _processPayment(subTotal, discountAmount, finalTotal, usedPoints, earnedPoints, appProvider),
                  child: Text(
                    _selectedMethod == 'COD' ? t('CONFIRM ORDER', 'ඇණවුම තහවුරු කරන්න') : t('PAY NOW', 'දැන් ගෙවන්න'), 
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.5)
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _paymentMethodOption(String method, IconData icon, String label) {
    bool isSelected = _selectedMethod == method;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = method),
      child: Container(
        width: 115,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: isSelected ? Colors.amber.withOpacity(0.2) : const Color(0xFF1E140F),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isSelected ? Colors.amberAccent : Colors.white10, width: isSelected ? 2 : 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.amberAccent : Colors.white54, size: 28),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: isSelected ? Colors.amberAccent : Colors.white70, fontSize: 11, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
          ],
        ),
      ),
    );
  }
}