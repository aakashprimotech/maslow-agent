import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:maslow_agents/presentation/admin/admin_home.dart';
import 'package:maslow_agents/presentation/admin/admin_login.dart';
import 'package:maslow_agents/presentation/auth/login.dart';
import 'package:maslow_agents/utils/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_strategy/url_strategy.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCntQ7YMMMi87qgayHOW7GOMvHtWfwkGGI",
        projectId: "maslow-agents",
        messagingSenderId: "1079508285618",
        appId: "1:1079508285618:web:7dfd3ecde0ab43223471ab",
        databaseURL: "https://maslow-agents.firebaseio.com",
        storageBucket: "maslow-agents.appspot.com",
      ),
    );
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, this.initialRoute = '/'});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
        future: _checkLoginStatus(),
        builder: (context, snapshot) {
          bool isLoggedIn = snapshot.data ?? false;
          return MaterialApp(
            title: 'MaslowAgents',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              primaryColor: AppColors.primaryColor,
            ),

            initialRoute: '/',
            routes: {
              '/' : (context) => const AdminLoginScreen(),
            },
          );
        }
    );
  }

  Future<bool> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString('uid');
    return uid != null && uid.isNotEmpty;
  }
}

class HomeScreen extends StatelessWidget {
  final bool isLoggedIn;

  const HomeScreen({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return isLoggedIn ? const AdminHomePage() : const AdminLoginScreen();
  }
}
