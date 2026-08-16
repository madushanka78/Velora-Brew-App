import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/app_data.dart';
import '../app_provider.dart';

class MenuScreen extends StatefulWidget {
  final VoidCallback onCartUpdate;
  const MenuScreen({super.key, required this.onCartUpdate});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String selectedCat = 'All';

  @override
  Widget build(BuildContext context) {
    
    final filteredMenu = selectedCat == 'All' 
        ? fullMenu 
        : fullMenu.where((item) => item['cat'] == selectedCat).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 15, bottom: 5),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: ['All', 'Drinks', 'Food', 'Dessert'].map((cat) {
                  bool isSelected = selectedCat == cat;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      selectedColor: Colors.amber,
                      backgroundColor: const Color(0xFF1E140F),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.black : Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (val) => setState(() => selectedCat = cat),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: filteredMenu.isEmpty 
              ? const Center(
                  child: Text("No items found.", style: TextStyle(color: Colors.white54)),
                )
              : GridView.builder(
                  padding: const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 90),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemCount: filteredMenu.length,
                  itemBuilder: (context, index) {
                    final item = filteredMenu[index];

                    return Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E140F),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                              child: Image.network(
                                item['image'] ?? '', 
                                width: double.infinity, 
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[850],
                                    child: const Center(
                                      child: Icon(Icons.broken_image_rounded, color: Colors.white38, size: 30),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 6,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        t(item['nameEn'] ?? '', item['nameSi'] ?? ''),
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Rs. ${item['price']}',
                                        style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.w600, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 34,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.amber,
                                        foregroundColor: Colors.black,
                                        padding: EdgeInsets.zero,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      onPressed: () {
                                        context.read<AppProvider>().addToCart(item);
                                        widget.onCartUpdate();
                                        
                                        ScaffoldMessenger.of(context).clearSnackBars();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              t('Added to cart!', 'කරත්තයට එකතු කරන ලදී!'),
                                              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                            ),
                                            backgroundColor: Colors.greenAccent,
                                            duration: const Duration(seconds: 1),
                                            behavior: SnackBarBehavior.floating,
                                            margin: const EdgeInsets.only(bottom: 10, left: 15, right: 15),
                                          ),
                                        );
                                      },
                                      child: Text(t('Add', 'එකතු කරන්න'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }
}