import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:maslow_agents/presentation/auth/login.dart';
import 'package:maslow_agents/presentation/users/user_agents_page.dart';
import 'package:maslow_agents/utils/captalize_string.dart';
import 'package:shimmer/shimmer.dart';

import '../../model/user.dart';
import '../../service/shared_pref_service.dart';
import '../../service/user_service.dart';
import '../../utils/colors.dart';
import '../agent_flows/agent_flow_model.dart';
import '../common/user_popup_menu.dart';
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

  final List<String> strings = [
    'First item',
    'Second item',
    'Third item',
    'Fourth item',
    'Fifth item',
  ];


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
            PopupMenuButton<String>(
              position: PopupMenuPosition.under,
              offset: Offset(-25, 15),  // Adjusts the position of the menu
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              onSelected: (value) {
                if (value == 'logout') {
                  _logout();
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem<String>(
                    value: 'profile',
                    child: UserPopupMenu(
                      user: currentUser,
                      onLogout: _logout,
                    ),
                  ),
                ];
              },
              child: Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(right: 32),
                height: 30,
                child: Row(
                  children: [
                    Text(
                      currentUser?.name != null ? "${currentUser!.name.capitalize()}" : "N/A",
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.primaryColor,
                        fontFamily: 'Graphik',
                      ),
                    ),
                    const SizedBox(width: 5),
                    const CircleAvatar(
                      backgroundImage: AssetImage('assets/images/user_placeholder.jpg'),
                      radius: 13,
                    ),
                  ],
                ),
              ),
            ),
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
                    child: Column(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
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
                        ExpansionTile(
                          backgroundColor: Colors.transparent,
                          collapsedBackgroundColor: Colors.transparent,
                          // Remove borders/lines by setting collapsedShape and shape to a Border with no borders
                          collapsedShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0.0),
                            side: BorderSide.none,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0.0),
                            side: BorderSide.none,
                          ),
                          title: const Text(
                            'Marketplace',
                            style: TextStyle(fontSize: 14, color: Colors.black87),
                          ),
                          children: <Widget>[
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 200),
                              child: StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('marketplace')
                                    .where('isPublished', isEqualTo: true)
                                    .orderBy('createdAt', descending: true)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return _buildShimmer();
                                  } else if (snapshot.hasError) {
                                    return Center(child: Text('Error: ${snapshot.error}'));
                                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                    return Center(child: Text('No items found.'));
                                  }

                                  // Convert Firestore documents to your model
                                  var filteredDocs = snapshot.data!.docs;
                                  var agentFlows = filteredDocs.map((doc) {
                                    return AgentFlowModel.fromFirestore(doc);
                                  }).toList();

                                  return ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: agentFlows.length,
                                    itemBuilder: (context, index) {
                                      return ListTile(
                                        title: Row(
                                          children: [
                                            Container(
                                              height: 8,
                                              width: 8,
                                              decoration: BoxDecoration(
                                                color: Colors.green,
                                                borderRadius: BorderRadius.circular(150),
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            Text(
                                              agentFlows[index].flowName,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.black87,
                                              ),
                                            )
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        ExpansionTile(
                          backgroundColor: Colors.transparent,
                          collapsedBackgroundColor: Colors.transparent,
                          // Remove borders/lines by setting collapsedShape and shape to a Border with no borders
                          collapsedShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0.0),
                            side: BorderSide.none,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0.0),
                            side: BorderSide.none,
                          ),
                          title: const Text(
                            'My Agents',
                            style: TextStyle(fontSize: 14, color: Colors.black87,),
                          ),
                          children: <Widget>[
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 200),
                              child: StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('marketplace')
                                    .orderBy('createdAt', descending: true)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return _buildShimmer();
                                  } else if (snapshot.hasError) {
                                    return Center(child: Text('Error: ${snapshot.error}'));
                                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                    return Center(child: Text('No items found.'));
                                  }

                                  var filteredDocs = snapshot.data!.docs.where((doc) {
                                    final data = doc.data() as Map<String, dynamic>;
                                    if (data.containsKey('marketplaceUsers')) {
                                      List<dynamic> marketplaceUsers = data['marketplaceUsers'];
                                      return marketplaceUsers
                                          .contains(UserService().getUserReference());
                                    }

                                    return false;
                                  }).toList();

                                  if (filteredDocs.isEmpty) {
                                    return const Center(child: Text('No agents found'));
                                  }

                                  // Create AgentFlowModel list based on filteredDocs
                                  var agentFlows = filteredDocs.map((doc) {
                                    return AgentFlowModel.fromFirestore(doc);
                                  }).toList();

                                  return ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: agentFlows.length,
                                    itemBuilder: (context, index) {
                                      return ListTile(
                                        title: Row(
                                          children: [
                                            Container(
                                              height: 8,
                                              width: 8,
                                              decoration: BoxDecoration(
                                                color: Colors.green,
                                                borderRadius: BorderRadius.circular(150),
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            Text(
                                              agentFlows[index].flowName,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.black87,
                                              ),
                                            )
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
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

  Widget _buildShimmer() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: ListTile(
            title: Container(
              height: 20,
              color: Colors.white,
            ),
          ),
        );
      },
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
          title: const Text("Confirm Logout",style: TextStyle(fontSize: 20,fontFamily: 'Graphik',),),
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
