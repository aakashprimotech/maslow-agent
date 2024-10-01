import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../service/shared_pref_service.dart';
import '../../utils/colors.dart';
import '../common/nothing_to_show.dart';

class AdminUsers extends StatefulWidget {
  const AdminUsers({super.key});

  @override
  State<AdminUsers> createState() => _AdminUsersState();
}

class _AdminUsersState extends State<AdminUsers> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  String? adminRole;

  Future<void> _checkAdminRole() async {
    final role = await SessionManager.getAdminRole();
    setState(() {
      adminRole = role;
    });
  }

  @override
  void initState() {
    _checkAdminRole();
    super.initState();
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('adminUsers').orderBy('createdAt', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ListView.builder(
                      itemCount: 6,
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

                  final filteredUsers = snapshot.data!.docs.where((doc) {
                    final displayName = doc['displayName']?.toString().toLowerCase() ?? '';
                    final email = doc['email']?.toString().toLowerCase() ?? '';
                    return displayName.contains(_searchText) || email.contains(_searchText);
                  }).toList();

                  if (filteredUsers.isEmpty) {
                    return const Center(child: Text('No users match your search.'));
                  }

                  return ListView.builder(
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final userDoc = filteredUsers[index];
                      final displayName = userDoc['displayName'] ?? 'No Name';
                      final email = userDoc['email'] ?? 'No Email';
                      String userImage = userDoc['profileImage'] ?? 'assets/images/user_placeholder.jpg';
                      final isBlocked = userDoc['isBlocked'] ?? false;
                      final userRole = userDoc['adminRole'] ?? "Editor";

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 16.0),
                        title: Text(displayName + " | "+ userRole ?? "N/A", style: const TextStyle(fontSize: 14)),
                        subtitle: Text(email, style: const TextStyle(fontSize: 12)),
                        leading: CircleAvatar(
                          backgroundImage: AssetImage(userImage),
                          radius: 18,
                        ),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        trailing : adminRole == "admin" ? InkWell(
                          onTap: () async {
                            try {
                              // Toggle the block/unblock status
                              await FirebaseFirestore.instance
                                  .collection('adminUsers')
                                  .doc(userDoc.id)
                                  .update({'isBlocked': !isBlocked});

                              // Optionally show a success message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(isBlocked ? 'User unblocked' : 'User blocked')),
                              );
                            } catch (e) {
                              // Handle error
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error updating user status: $e')),
                              );
                            }
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
                                  offset: const Offset(0, 1),
                                ),
                              ],
                              borderRadius: const BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                            padding: const EdgeInsets.all(5),
                            child: Text(
                              isBlocked ? 'Unblock' : 'Block',
                              style: const TextStyle(fontSize: 13, color: Colors.white),
                            ),
                          ),
                        ) :const SizedBox()
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
