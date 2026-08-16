import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/app_data.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    
    if (user == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1A110C),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.amberAccent),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(t('My Profile', 'මගේ ගිණුම'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        body: Center(
          child: Text(
            t('Please login to view profile.', 'කරුණාකර ලොග් වන්න.'),
            style: const TextStyle(color: Colors.white54, fontSize: 16),
          ),
        ),
      );
    }

    String email = user.email ?? 'Unknown';
    String username = email.split('@')[0];

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A110C),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.amberAccent),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(t('My Profile', 'මගේ ගිණුම'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            
           
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.amber.withOpacity(0.2),
                    child: Text(
                      username[0].toUpperCase(),
                      style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold, color: Colors.amberAccent),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.edit, color: Colors.black, size: 20),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
          
            Text(
              username,
              style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              email,
              style: const TextStyle(color: Colors.white54, fontSize: 16),
            ),
            const SizedBox(height: 40),
            
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2A1A10), Color(0xFF1E140F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.amberAccent.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 2,
                  )
                ]
              ),
              child: Column(
                children: [
                  const Icon(Icons.stars_rounded, color: Colors.amberAccent, size: 50),
                  const SizedBox(height: 15),
                  Text(
                    t('Loyalty Points', 'ඔබේ Points'),
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  ValueListenableBuilder<int>(
                    valueListenable: globalPoints,
                    builder: (context, points, child) {
                      return Text(
                        '$points PTS',
                        style: const TextStyle(color: Colors.amberAccent, fontSize: 36, fontWeight: FontWeight.w900),
                      );
                    }
                  ),
                  const SizedBox(height: 15),
                  Text(
                    t('Use 300 PTS for a 10% discount on your next order!', 'ඊළඟ ඇණවුමට 10% ක වට්ටමක් ලබා ගැනීමට Points 300 ක් භාවිතා කරන්න!'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white54, fontSize: 13, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}