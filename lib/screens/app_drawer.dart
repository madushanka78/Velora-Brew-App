import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'chat_screen.dart';
import 'tracking_screen.dart';
import 'order_history_screen.dart';
import 'admin_dashboard_screen.dart';
import 'profile_screen.dart';

bool isSinhalaGlobal = false;

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String? _activeOrderId;
  String? _activeAddress;

  @override
  void initState() {
    super.initState();
    _checkActiveOrder();
  }

  Future<void> _checkActiveOrder() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _activeOrderId = prefs.getString('saved_order_id');
      _activeAddress = prefs.getString('saved_address') ?? 'Colombo, Sri Lanka';
    });
  }

  void _showLoginDialog(BuildContext context) {
    bool isPasswordHidden = true;
    bool isLoading = false;
    
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF2A2A2A),
              title: Text(
                isSinhalaGlobal ? 'ලොග් වෙන්න' : 'Login',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: emailController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: isSinhalaGlobal ? 'ඊමේල් ලිපිනය' : 'Email Address',
                      labelStyle: const TextStyle(color: Colors.grey),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.orange),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.orange),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: isPasswordHidden,
                    maxLength: 8, 
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      counterText: "", 
                      labelText: isSinhalaGlobal ? 'මුරපදය' : 'Password',
                      labelStyle: const TextStyle(color: Colors.grey),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.orange),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.orange),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordHidden ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            isPasswordHidden = !isPasswordHidden;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  child: Text(
                    isSinhalaGlobal ? 'අවලංගු කරන්න' : 'Cancel',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  onPressed: isLoading ? null : () async {
                    String email = emailController.text.trim();
                    String password = passwordController.text;

                    if (!email.endsWith('@gmail.com')) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isSinhalaGlobal ? 'කරුණාකර නිවැරදි @gmail.com ලිපිනයක් ඇතුළත් කරන්න' : 'Please enter a valid @gmail.com address'), backgroundColor: Colors.redAccent));
                      return; 
                    }

                    String username = email.split('@')[0];
                    if (username.length > 10 || username.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isSinhalaGlobal ? 'Username එක අකුරු 10 කට වඩා අඩු විය යුතුය' : 'Username must be 10 characters or less'), backgroundColor: Colors.redAccent));
                      return; 
                    }

                    if (password.length != 8) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isSinhalaGlobal ? 'මුරපදය අකුරු 8ක් විය යුතුය' : 'Password must be exactly 8 characters'), backgroundColor: Colors.redAccent));
                      return; 
                    }

                    setState(() => isLoading = true);

                    try {
                      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
                      if (context.mounted) Navigator.pop(context);
                    } on FirebaseAuthException catch (_) {
                      try {
                        await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
                        if (context.mounted) Navigator.pop(context);
                      } catch (e2) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isSinhalaGlobal ? 'මුරපදය වැරදියි!' : 'Incorrect password!'), backgroundColor: Colors.redAccent));
                        }
                      }
                    } finally {
                      setState(() => isLoading = false);
                    }
                  },
                  child: isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                      : Text(
                          isSinhalaGlobal ? 'ලොග් වෙන්න' : 'Login',
                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showContactUsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A2A2A),
          title: Text(
            isSinhalaGlobal ? 'අපව අමතන්න' : 'Contact Us',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(
            isSinhalaGlobal
                ? 'ක්ෂණික ඇමතුම්: 077 123 4567\nඊමේල්: support@velorabrew.com'
                : 'Hotline: 077 123 4567\nEmail: support@velorabrew.com',
            style: const TextStyle(color: Colors.white70, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(isSinhalaGlobal ? 'හරි' : 'OK', style: const TextStyle(color: Colors.orange, fontSize: 16)),
            ),
          ],
        );
      },
    );
  }

  void _showFeedbackDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A2A2A),
          title: Text(
            isSinhalaGlobal ? 'අදහස් දක්වන්න' : 'Feedback',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(
            isSinhalaGlobal
                ? 'ඔබගේ අදහස් අපට ඉතා වැදගත්! කරුණාකර ඔබගේ අදහස් අපගේ ඊමේල් ලිපිනයට යොමු කරන්න: feedback@velorabrew.com'
                : 'Your feedback is very important to us! Please send your thoughts to: feedback@velorabrew.com',
            style: const TextStyle(color: Colors.white70, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(isSinhalaGlobal ? 'හරි' : 'OK', style: const TextStyle(color: Colors.orange, fontSize: 16)),
            ),
          ],
        );
      },
    );
  }

  void _showAboutUsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A2A2A),
          title: Text(
            isSinhalaGlobal ? 'අපි ගැන' : 'About Us',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(
            isSinhalaGlobal
                ? 'Velora Brew යනු ඔබට හොඳම කෝපි සහ රසවත් කේක් පිරිනමන සුවිශේෂී කෝපි හලකි. අප සමඟ රැඳී සිටීම ගැන ස්තුතියි!'
                : 'Velora Brew is a premium coffee shop offering the best coffee and delicious cakes. Thank you for being with us!',
            style: const TextStyle(color: Colors.white70, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(isSinhalaGlobal ? 'හරි' : 'OK', style: const TextStyle(color: Colors.orange, fontSize: 16)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        final isLoggedIn = user != null;
        
        String username = 'Username';
        if (isLoggedIn && user.email != null) {
          username = user.email!.split('@')[0];
        }

        return Drawer(
          backgroundColor: const Color(0xFF121212),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  if (!isLoggedIn) {
                    Navigator.pop(context);
                    _showLoginDialog(context);
                  } else {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
                  }
                },
                child: UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(color: Color(0xFF1A1A1A)),
                  accountName: Text(username, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  accountEmail: Text(
                    isLoggedIn 
                        ? user.email! 
                        : (isSinhalaGlobal ? 'ලොග් වීමට මෙතන ඔබන්න' : 'Tap here to login'),
                    style: TextStyle(color: isLoggedIn ? Colors.white70 : Colors.orange),
                  ),
                  currentAccountPicture: const CircleAvatar(
                    backgroundColor: Colors.orange,
                    child: Icon(Icons.person, color: Colors.black, size: 40),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    if (_activeOrderId != null)
                      Container(
                        margin: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.amberAccent.withOpacity(0.5)),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.location_on, color: Colors.amberAccent),
                          title: Text(isSinhalaGlobal ? 'ඔබගේ ඇණවුම බලන්න' : 'Track Active Order', style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold)),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.amberAccent, size: 16),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) => TrackingScreen(
                                address: _activeAddress ?? 'Colombo, Sri Lanka',
                                orderId: _activeOrderId!,
                              )
                            ));
                          },
                        ),
                      ),
                      
                    if (isLoggedIn && user.email == 'admin@gmail.com')
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.admin_panel_settings, color: Colors.redAccent),
                          title: Text(isSinhalaGlobal ? 'ඇඩ්මින් පැනලය' : 'Admin Dashboard', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.redAccent, size: 16),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminDashboardScreen()));
                          },
                        ),
                      ),
                      
                    ListTile(
                      leading: const Icon(Icons.history, color: Colors.orange),
                      title: Text(isSinhalaGlobal ? 'පසුගිය ඇණවුම්' : 'Order History', style: const TextStyle(color: Colors.white)),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const OrderHistoryScreen()));
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.support_agent, color: Colors.orange),
                      title: Text(isSinhalaGlobal ? 'සජීවී චැට් සහාය' : 'Live Chat Support', style: const TextStyle(color: Colors.white)),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatScreen()));
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.phone, color: Colors.orange),
                      title: Text(isSinhalaGlobal ? 'අමතන්න' : 'Contact Us', style: const TextStyle(color: Colors.white)),
                      onTap: () {
                        Navigator.pop(context);
                        _showContactUsDialog();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.star, color: Colors.orange),
                      title: Text(isSinhalaGlobal ? 'අදහස් දක්වන්න' : 'Feedback', style: const TextStyle(color: Colors.white)),
                      onTap: () {
                        Navigator.pop(context);
                        _showFeedbackDialog();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.info, color: Colors.orange),
                      title: Text(isSinhalaGlobal ? 'අපි ගැන' : 'About Us', style: const TextStyle(color: Colors.white)),
                      onTap: () {
                        Navigator.pop(context);
                        _showAboutUsDialog();
                      },
                    ),
                  ],
                ),
              ),
              
              if (isLoggedIn) ...[
                const Divider(color: Colors.white24),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.white70),
                  title: Text(isSinhalaGlobal ? 'ඉවත් වෙන්න' : 'Sign Out', style: const TextStyle(color: Colors.white70)),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
                  title: Text(isSinhalaGlobal ? 'ගිණුම මකන්න' : 'Delete Account', style: const TextStyle(color: Colors.redAccent)),
                  onTap: () async {
                    try {
                      await user.delete();
                      if (context.mounted) Navigator.pop(context);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(isSinhalaGlobal ? 'ගිණුම මැකීමට නැවත ලොග් වන්න' : 'Please sign in again to delete account'),
                          backgroundColor: Colors.redAccent,
                        ));
                      }
                    }
                  },
                ),
                const SizedBox(height: 20),
              ]
            ],
          ),
        );
      },
    );
  }
}