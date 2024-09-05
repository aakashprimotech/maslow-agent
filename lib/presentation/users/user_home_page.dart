import 'package:flutter/material.dart';
import 'package:maslow_agents/presentation/auth/login.dart';
import 'package:maslow_agents/presentation/users/user_agents_page.dart';
import 'package:maslow_agents/utils/captalize_string.dart';

import '../../model/user.dart';
import '../../service/shared_pref_service.dart';
import '../../utils/colors.dart';
import '../notification/notification_screen.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  int _selectedIndex = 0;
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

  final List<IconData> _pageIcons = [
    Icons.home,
  ];

  final List<String> _pageTitles = [
    'Home',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          backgroundColor: AppColors.messageBgColor.withAlpha(50),
          title: Image.asset('assets/images/maslow_logo.png', height: 22),
          actions: [
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(right: 10),
              height: 30,
              width: 30,
              decoration: const BoxDecoration(
                color: AppColors.messageBgColor,
                borderRadius: BorderRadius.all(
                  Radius.circular(5),
                ),
              ),
              child: InkWell(
                onTap: _logout,
                child: const Icon(
                  Icons.logout,
                  size: 20,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
            Container(
              alignment: Alignment.center,
              height: 30,
              width: 30,
              margin: const EdgeInsets.only(right: 10),
              decoration: const BoxDecoration(
                color: AppColors.messageBgColor,
                borderRadius: BorderRadius.all(
                  Radius.circular(5),
                ),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationScreen(),
                    ),
                  );
                },
                child: const Icon(
                  Icons.notifications_none_outlined,
                  size: 20,
                  color: AppColors.primaryColor,
                ),
              ),
            ),

            Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(right: 32),
                height: 30,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(5),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      currentUser?.name!=null ? "${currentUser!.name.capitalize()}" :"N/A" ,
                      style: const TextStyle(fontSize: 14, color: AppColors.primaryColor,fontWeight: FontWeight.w600
                      ),
                    ),
                    const SizedBox(width: 5),
                    const CircleAvatar(
                      backgroundImage: AssetImage('assets/images/user_placeholder.jpg'),
                      radius: 13,
                    ),
                  ],
                )
            )
          ],
        ),
        body: Column(
          children: [
            Container(color: AppColors.textFieldBorderColor, height: 1,),
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 250,
                    padding: const EdgeInsets.only(top: 10),
                    color: AppColors.messageBgColor.withAlpha(50),
                    child: ListView.builder(
                      itemCount: _pageTitles.length,
                      itemBuilder: (context, index) {
                        bool isSelected = _selectedIndex == index;
                        return Container(
                          margin: const EdgeInsets.fromLTRB(10,0,10,0) ,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.messageBgColor
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: SizedBox(
                            height: 50,
                            child: ListTile(
                              title: Row(
                                children: [
                                  Icon(
                                    _pageIcons[index],
                                    color: AppColors.primaryColor.withAlpha(150),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    _pageTitles[index].capitalize()!,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              selected: isSelected,
                              onTap: () => _onItemTapped(index),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.topCenter,
                      color: AppColors.backgroundColor,
                      child: _getPage(_selectedIndex),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return const UserAgentsPage();
      default:
        return const Center(child: Text('Logout Page'));
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          title: const Text("Confirm Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            InkWell(
              onTap: (){
                setState(() {
                  SessionManager.clearUser();
                });
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (Route<dynamic> route) => false, // This will remove all previous routes
                );
              },
              child: Container(
                height: 30,
                alignment: Alignment.center,
                width: 70,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 3,
                      blurRadius: 7,
                      offset: const Offset(0, 1), // changes position of shadow
                    ),
                  ],
                  borderRadius: const BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                padding: const EdgeInsets.all(5),
                child: const Text(
                  'Logout',
                  style: TextStyle(fontSize: 13, color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
