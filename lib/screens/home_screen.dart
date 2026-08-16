import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/app_data.dart';
import '../app_provider.dart';
import 'menu_screen.dart';
import 'cart_screen.dart';
import 'chat_screen.dart';
import 'app_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _goToMenu() => setState(() => _currentIndex = 1);

  Widget _premiumBrandText({double fontSize = 22}) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Color(0xFFFFEE55), Color(0xFFFFA000), Color(0xFFFF8F00)],
      ).createShader(bounds),
      child: Text(
        'Velora Brew',
        style: TextStyle(
          fontFamily: 'Georgia',
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          fontStyle: FontStyle.italic,
          color: Colors.white,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _languageToggle() {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF3E2723), Color(0xFF1A110C)]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amberAccent, width: 1),
      ),
      child: TextButton(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        onPressed: () => isSinhala.value = !isSinhala.value,
        child: Text(
          isSinhala.value ? 'EN' : 'සිංහල',
          style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ),
    );
  }

  void _showRewardsMenu(BuildContext context, int points) {
    bool hasDiscount = points >= 300;
    int pointsNeeded = hasDiscount ? 0 : (300 - points);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        decoration: const BoxDecoration(
          color: Color(0xFF1A110C),
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          border: Border(top: BorderSide(color: Colors.amberAccent, width: 2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white38, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            const Icon(Icons.stars_rounded, color: Colors.amberAccent, size: 60),
            const SizedBox(height: 10),
            Text(
              '$points PTS',
              style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 1.5),
            ),
            const SizedBox(height: 5),
            Text(
              t('Your Velora Rewards', 'ඔබගේ Velora ප්‍රතිලාභ'),
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 25),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: hasDiscount ? Colors.green.withOpacity(0.1) : const Color(0xFF2D1810),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: hasDiscount ? Colors.greenAccent : Colors.amber.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(hasDiscount ? Icons.check_circle_rounded : Icons.lock_outline_rounded, 
                       color: hasDiscount ? Colors.greenAccent : Colors.white54, size: 30),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t('10% OFF on Checkout', 'ගෙවීම් වලදී 10% ක වට්ටමක්'),
                          style: TextStyle(color: hasDiscount ? Colors.greenAccent : Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                      
                        Text(
                          hasDiscount 
                              ? t('Reward applied! 300 PTS will be used.', 'වට්ටම සක්‍රීයයි! (ගෙවීමේදී Points 300 ක් අඩුවේ)') 
                              : t('Earn $pointsNeeded more points to unlock.', 'මෙය ලබාගැනීමට තව points $pointsNeeded ක් අවශ්‍යයි.'),
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text(t('AWESOME!', 'නියමයි!'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = context.watch<AppProvider>().cartItems;

    final List<Widget> pages = [
      _FrontScreen(onMenuTap: _goToMenu, brandTextWidget: _premiumBrandText(fontSize: 52)),
      MenuScreen(onCartUpdate: () => setState(() {})),
      const CartScreen()
    ];

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF121212),
      drawer: const AppDrawer(),
      extendBodyBehindAppBar: _currentIndex == 0,
      
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        elevation: 8,
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen())),
        child: const Icon(Icons.support_agent_rounded, color: Colors.black, size: 28),
      ),

      appBar: AppBar(
        backgroundColor: _currentIndex == 0 ? Colors.transparent : const Color(0xFF1A110C),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, color: Colors.amberAccent, size: 28),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: null,
        actions: [
          Center(
            child: ValueListenableBuilder<int>(
              valueListenable: globalPoints,
              builder: (context, points, child) {
                var level = getMembershipLevel(points);
                return GestureDetector(
                  onTap: () => _showRewardsMenu(context, points),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amberAccent, width: 0.8),
                    ),
                    child: Row(
                      children: [
                        Text(level['icon'], style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 4),
                        Text('$points PTS', style: const TextStyle(color: Colors.amberAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          _languageToggle(),
        ],
      ),

      body: pages[_currentIndex],

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF1F100A), Color(0xFF0D0604)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
          border: const Border(top: BorderSide(color: Colors.amberAccent, width: 0.8)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.8), blurRadius: 15, offset: const Offset(0, -5))],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Colors.amberAccent,
          unselectedItemColor: Colors.white38,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          onTap: (index) => setState(() => _currentIndex = index),
          items: [
            BottomNavigationBarItem(icon: const Icon(Icons.home_rounded), label: t('Home', 'මුල් පිටුව')),
            BottomNavigationBarItem(icon: const Icon(Icons.restaurant_menu_rounded), label: t('Menu', 'මෙනුව')),
            BottomNavigationBarItem(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.shopping_cart_rounded),
                  if (cartItems.isNotEmpty)
                    Positioned(
                      right: -5,
                      top: -5,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1)),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text('${cartItems.length}', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                      ),
                    )
                ],
              ),
              label: t('Cart', 'කරත්තය'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FrontScreen extends StatelessWidget {
  final VoidCallback onMenuTap;
  final Widget brandTextWidget;
  const _FrontScreen({required this.onMenuTap, required this.brandTextWidget});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(image: NetworkImage('https://images.unsplash.com/photo-1511920170033-f8396924c348'), fit: BoxFit.cover),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withOpacity(0.3), Colors.black.withOpacity(0.85)]),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.amber.withOpacity(0.15), border: Border.all(color: Colors.amberAccent.withOpacity(0.5), width: 1.5)),
              child: const Icon(Icons.coffee_rounded, size: 55, color: Colors.amberAccent),
            ),
            const SizedBox(height: 25),
            brandTextWidget,
            const SizedBox(height: 12),
            Text(
              t('THE ART OF SUPREME COFFEE', 'දිව්‍යමය කෝපි රසයේ සැබෑ කලාව'),
              style: const TextStyle(fontSize: 13, color: Colors.amberAccent, letterSpacing: 3.5, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 40),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 30),
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFFC107), Color(0xFFFF8F00)]),
                borderRadius: BorderRadius.circular(35),
                boxShadow: [BoxShadow(color: Colors.amber.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35))),
                onPressed: onMenuTap,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(t('EXPLORE OUR MENU', 'මෙනුවට පිවිසෙන්න'), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF1A110C), letterSpacing: 2)),
                    const SizedBox(width: 12),
                    const Icon(Icons.arrow_forward_rounded, color: Color(0xFF1A110C), size: 22),
                  ],
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}