import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maslow_agents/presentation/admin/admin_home.dart';
import 'package:maslow_agents/presentation/admin/admin_login.dart';
import 'package:maslow_agents/presentation/auth/login.dart';
import 'package:maslow_agents/presentation/users/user_home_page.dart';
import 'package:maslow_agents/service/shared_pref_service.dart';
import 'package:maslow_agents/utils/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_strategy/url_strategy.dart';

import 'model/user.dart';

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
  setPathUrlStrategy();
  final currentUrl = Uri.base;
  final redirect = currentUrl.queryParameters['redirect'];

  await ScreenUtil.ensureScreenSize();

  if (redirect != null && redirect.isNotEmpty) {
    runApp(MyApp(initialRoute: redirect));
  } else {
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, this.initialRoute = '/'});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(1440, 1024), // Example web design size
      minTextAdapt: true,
      splitScreenMode: true,
        builder: (context,child) {
          return FutureBuilder<bool>(
              future: _checkLoginStatus(),
              builder: (context, snapshot) {
                bool isLoggedIn = snapshot.data ?? false;
                return MaterialApp(
                  title: 'Maslow Agents',
                  debugShowCheckedModeBanner: false,
                  theme: ThemeData(
                    // Optional: Set a default font for the entire app
                    fontFamily: 'Manrope',
                    textTheme: const TextTheme(
                      bodyMedium: TextStyle(fontFamily: 'Manrope'),
                    ),
                  ),
                  initialRoute: '/',
                  onGenerateRoute: (settings) {
                    if (settings.name != null) {
                      final Uri uri = Uri.parse(settings.name!);
                      if(uri.pathSegments.length == 1 && uri.pathSegments.first == 'adminLogin'){
                        MaterialPageRoute(
                          builder: (context) => const AdminLoginScreen(),
                        );
                      }
                    }
                    return MaterialPageRoute(
                      builder: (context) => HomeScreen(isLoggedIn: isLoggedIn),
                    );
                  },
                  routes: {
                    '/login': (context) => const LoginScreen(),
                    '/adminHome': (context) => const AdminHomePage(),
                    '/adminLogin' : (context) => const AdminLoginScreen(),
                  },
                  /*initialRoute: '/',
                routes: {
                  '/' : (context) => const AdminLoginScreen(),
                },*/
                );
              }
          );
        },
      );
  }

  Future<bool> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString('uid');
    return uid != null && uid.isNotEmpty;
  }
}

class HomeScreen extends StatefulWidget {
  final bool isLoggedIn;

  const HomeScreen({super.key, required this.isLoggedIn});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserModel? currentUser;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    currentUser = await SessionManager.getUser();
    if (currentUser != null) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.isLoggedIn
        ? currentUser?.authType != 'user'
            ? const AdminHomePage()
            : const UserHomePage()
        :  const LoginScreen();
  }
}

/*
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
*/
