import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:maslow_agents/presentation/admin/admin_home.dart';
import 'package:maslow_agents/presentation/auth/signup.dart';
import 'package:maslow_agents/presentation/users/user_home_page.dart';
import 'package:maslow_agents/utils/custom_snackbar.dart';

import '../../../service/shared_pref_service.dart';
import '../../model/user.dart';
import '../../utils/colors.dart';
import '../common/app_logo_horizontal.dart';
import '../common/password_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage = '';

  Future<User?> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() {
          _errorMessage = 'User cancelled the sign-in';
        });
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        await FirebaseAuth.instance.signOut();
        setState(() {
          _errorMessage = 'User account does not exist. Please register.';
        });
        context.showCustomSnackBar(_errorMessage);
        return null;
      }

      Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

      if (userData != null) {
        bool isBlocked = userData['isBlocked'] ?? false;

        if (isBlocked) {
          await FirebaseAuth.instance.signOut();
          setState(() {
            _errorMessage = 'Your account is blocked. Please contact support.';
          });
          context.showCustomSnackBar(_errorMessage);
          return null;
        }
      } else {
        setState(() {
          _errorMessage = 'User data not found';
        });
        return null;
      }

      await SessionManager.saveUser(UserModel(
        uid: userCredential.user?.uid ?? '',
        name: userCredential.user?.displayName ?? '',
        email: userCredential.user?.email ?? '',
        authType: 'user',
      ));

      return userCredential.user;
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to sign in with Google: $e';
        print("Error: $e");
      });
      return null;
    }
  }

  void _signInWithEmailAndPassword() async {
    try {
      if (_formKey.currentState!.validate()) {
        final String email = _emailController.text.trim();
        final String password = _passwordController.text;

        UserCredential userCredential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        bool isBlocked = userData['isBlocked'] ?? false;

        if (isBlocked) {
          await FirebaseAuth.instance.signOut();
          setState(() {
            _errorMessage = 'Your account is blocked. Please contact support.';
          });
          context.showCustomSnackBar(_errorMessage);
          return;
        }

        await SessionManager.saveUser(UserModel(
          uid: userCredential.user?.uid ?? '',
          name: userData['displayName'] ?? '',
          email: userCredential.user?.email ?? '',
          authType: 'user',
          primaryWorkSpace: (userData['primaryWorkSpace'] as DocumentReference?)?.id,
        ));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const UserHomePage()),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to sign in with Email and Password: $e';
      });
      context.showCustomSnackBar(_errorMessage);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFDB91B9), Color(0xFF39D2C0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        alignment: Alignment.center,
        height: MediaQuery
            .of(context)
            .size
            .height,
        width: MediaQuery
            .of(context)
            .size
            .width,
        child: Form(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.8),
                    spreadRadius: 3,
                    blurRadius: 7,
                    offset: const Offset(0, 1), // changes position of shadow
                  ),
                ]),
            height: MediaQuery
                .of(context)
                .size
                .height / 1.2,
            width: MediaQuery
                .of(context)
                .size
                .width / 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const AppLogoHorizontal(),
                const SizedBox(
                  height: 25,
                ),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Login',
                    style: TextStyle(
                      color: Colors.black87,
                      fontFamily: 'Graphik',
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email',
                    hintText: 'Enter email',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(
                  height: 10,
                ),
                PasswordField(
                  controller: _passwordController,
                  labelText: 'Password',
                  hintText: 'Enter password',
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                Container(
                  margin: const EdgeInsets.only(top: 25),
                  child: InkWell(
                    onTap: _signInWithEmailAndPassword,
                    child: Container(
                      height: 45,
                      alignment: Alignment.center,
                      width: 200,
                      decoration: BoxDecoration(
                        //0xFF39D2C0
                        color: AppColors.primaryColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 3,
                            blurRadius: 7,
                            offset: const Offset(
                                0, 1), // changes position of shadow
                          ),
                        ],
                        borderRadius: const BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      padding: const EdgeInsets.all(5),
                      child: const Text(
                        'Login',
                        style: TextStyle(fontSize: 15, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account?",
                      style: TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignupScreen()),
                        );
                      },
                      child: const Text(
                        " Sign up",
                        style: TextStyle(
                            fontSize: 13,
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 25,
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    User? user = await _signInWithGoogle();
                    if (user != null) {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const UserHomePage()));
                    } else {
                      // Failed sign in
                      context.showCustomSnackBar(_errorMessage);
                    }
                  },
                  icon: Image.asset(
                    'assets/images/iv_google.png',
                    height: 20,
                    width: 20,
                  ),
                  label: const Text('Sign in with Google'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(200.0, 50.0),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: const BorderSide(color: AppColors.primaryColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
