import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:maslow_agents/utils/captalize_string.dart';
import 'package:shimmer/shimmer.dart';

import '../../utils/colors.dart';
import '../common/nothing_to_show.dart';

class AdminUsersPage extends StatefulWidget {
  @override
  _AdminUsersPageState createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 50, 30, 0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {
                    // Handle filter action
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchText = value.toLowerCase();
                });
              },
            ),
          ),
          const SizedBox(height: 16.0),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 30),
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Users'),
                Tab(text: 'Organizations'),
              ],
              // indicatorColor: BoxDecoration(),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Individual Users View
                _buildUsersView('individual'),

                // Organizations View
                _buildUsersView('organization'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersView(String userType) {
    if (userType == 'organization') {
      return Center(
        child: Text(
          'Feature coming soon!',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    // The existing code for 'individual' userType
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.builder(
              itemCount: 6, // Number of shimmer items
              itemBuilder: (context, index) {
                return Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    leading: const CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 20,
                    ),
                    title: Container(
                      width: double.infinity,
                      height: 10.0,
                      color: Colors.white,
                    ),
                    subtitle: Container(
                      width: 150.0,
                      height: 10.0,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error fetching data'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const NothingToShow();
          }

          // Filter users based on search text and type
          var users = snapshot.data!.docs.where((userDoc) {
            Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
            String userName = userData['displayName'] ?? 'No Name';
            String userEmail = userData['email'] ?? 'No Email';
            String type = userData['type'] ?? 'individual'; // Assuming you have a 'type' field

            return type == userType &&
                (userName.toLowerCase().contains(_searchText) ||
                    userEmail.toLowerCase().contains(_searchText));
          }).toList();

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              DocumentSnapshot userDoc = users[index];
              Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
              String userName = userData['displayName'] ?? 'No Name';
              String userEmail = userData['email'] ?? 'No Email';
              String userImage = userData['profileImage'] ?? 'assets/images/user_placeholder.jpg';

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                leading: CircleAvatar(
                  backgroundImage: AssetImage(userImage),
                  radius: 20,
                ),
                title: Text(userName.capitalize() ?? "N/A"),
                subtitle: Text(userEmail),
                trailing: InkWell(
                  onTap: () {},
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
                      'Block',
                      style: TextStyle(fontSize: 13, color: Colors.white),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }


/*  Widget _buildUsersView(String userType) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.builder(
              itemCount: 6, // Number of shimmer items
              itemBuilder: (context, index) {
                return Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    leading: const CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 20,
                    ),
                    title: Container(
                      width: double.infinity,
                      height: 10.0,
                      color: Colors.white,
                    ),
                    subtitle: Container(
                      width: 150.0,
                      height: 10.0,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error fetching data'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const NothingToShow();
          }

          // Filter users based on search text and type
          var users = snapshot.data!.docs.where((userDoc) {
            Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
            String userName = userData['displayName'] ?? 'No Name';
            String userEmail = userData['email'] ?? 'No Email';
            String type = userData['type'] ?? 'individual'; // Assuming you have a 'type' field

            return type == userType &&
                (userName.toLowerCase().contains(_searchText) ||
                    userEmail.toLowerCase().contains(_searchText));
          }).toList();

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              DocumentSnapshot userDoc = users[index];
              Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
              String userName = userData['displayName'] ?? 'No Name';
              String userEmail = userData['email'] ?? 'No Email';
              String userImage = userData['profileImage'] ?? 'assets/images/user_placeholder.jpg';

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                leading: CircleAvatar(
                  backgroundImage: AssetImage(userImage),
                  radius: 20,
                ),
                title: Text(userName.capitalize() ?? "N/A"),
                subtitle: Text(userEmail),
                trailing: InkWell(
                  onTap: () {},
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
                      'Block',
                      style: TextStyle(fontSize: 13, color: Colors.white),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }*/
}
