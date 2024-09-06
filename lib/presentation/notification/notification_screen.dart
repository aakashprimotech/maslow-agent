import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:maslow_agents/service/user_service.dart';
import 'package:shimmer/shimmer.dart';

import '../../model/notification.dart';
import '../../model/user.dart';
import '../../service/shared_pref_service.dart';
import '../../utils/colors.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
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

  Stream<List<NotificationModel>> _notificationStream() {
    return FirebaseFirestore.instance
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs
          .map((doc) {
        return NotificationModel.fromFirestore(doc);
      }).toList();
    });
  } 
  
  Stream<List<NotificationModel>> _usersNotificationsStream() {
    return FirebaseFirestore.instance
        .collection('notifications')
        .where('isAccepted',isEqualTo: true)
        .where('userRef',isEqualTo: UserService().getUserReference())
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs
          .map((doc) {
        return NotificationModel.fromFirestore(doc);
      }).toList();
    });
  }

  Stream<Map<String, dynamic>?> _marketplaceDataStream(DocumentReference workspaceRef) {
    return workspaceRef.snapshots().map((snapshot) {
      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>?;
      }
      return null;
    });
  }

  Future<void> _updateMarketplaceUsers(DocumentReference agentFlowRef, DocumentReference userRef) async {
    final workspaceSnapshot = await agentFlowRef.get();

    if (workspaceSnapshot.exists) {
      final workspaceData = workspaceSnapshot.data() as Map<String, dynamic>;
      final List<dynamic>? marketplaceUsers = workspaceData['marketplaceUsers'];

      if (marketplaceUsers != null) {
        if (!marketplaceUsers.contains(userRef)) {
          marketplaceUsers.add(userRef);
          await agentFlowRef.update({
            'marketplaceUsers': marketplaceUsers,
          });
        }
      } else {
        await agentFlowRef.update({
          'marketplaceUsers': [userRef],
        });
      }

      final notificationsQuery = FirebaseFirestore.instance
          .collection('notifications')
          .limit(1);

      final querySnapshot = await notificationsQuery.get();
      if (querySnapshot.docs.isNotEmpty) {
        final notificationDoc = querySnapshot.docs.first;
        await notificationDoc.reference.update({'status': true,'isAccepted' : true});
      }

    } else {
      throw Exception("Workspace not found.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            Image.asset(
              'assets/images/maslow_icon.png',
              height: 22,
              width: 22,
            ),
            const SizedBox(
              width: 10,
            ),
            const Text(
              'Notifications',
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                fontFamily: 'Graphik',),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(color: AppColors.textFieldBorderColor, height: 1,),
          const SizedBox(height: 20,),
          if (currentUser?.authType == 'admin')  Expanded(
            child: StreamBuilder<List<NotificationModel>>(
              stream: _notificationStream(),
              builder: (context, notificationSnapshot) {
                if (notificationSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (notificationSnapshot.hasError) {
                  return Center(child: Text('Error: ${notificationSnapshot.error}'));
                } else if (!notificationSnapshot.hasData || notificationSnapshot.data!.isEmpty) {
                  return const Center(child: Text('No notifications'));
                } else {
                  final notifications = notificationSnapshot.data!;
                  return ListView(
                    children: notifications.map((notification) {
                      return StreamBuilder<Map<String, dynamic>?>(
                        stream: _marketplaceDataStream(notification.agentFlowRef),
                        builder: (context, marketplaceSnapshot) {
                          if (marketplaceSnapshot.connectionState == ConnectionState.waiting) {
                            return Container(
                              height: 70,
                              alignment: Alignment.center,
                              margin: const EdgeInsets.fromLTRB(50, 8, 50, 8),
                              decoration: BoxDecoration(
                                color: AppColors.messageBgColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        height: 10,
                                        width: double.infinity,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        height: 10,
                                        width: 100,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          } else if (marketplaceSnapshot.hasError) {
                            return Center(child: Text('Error: ${marketplaceSnapshot.error}'));
                          } else if (!marketplaceSnapshot.hasData) {
                            return const Center(child: Text('Marketplace data not found'));
                          } else {
                            final marketplaceSnapshotData = marketplaceSnapshot.data!;
                            return Container(
                              margin: const EdgeInsets.fromLTRB(50, 8, 50, 8),
                              decoration: BoxDecoration(
                                color: notification.status ? AppColors.messageBgColor.withOpacity(0.4) : AppColors.messageBgColor,
                                borderRadius: const BorderRadius.all(Radius.circular(8)),
                              ),
                              child: InkWell(
                                onTap: () {
                                  if (notification.status == false) {
                                    _updateMarketplaceUserDialog(notification, marketplaceSnapshotData['flowName']);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  child: ListTile(
                                    title: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: notification.email,
                                                style: const TextStyle(fontSize: 14, color: Colors.black87),
                                              ),
                                              const TextSpan(
                                                text: " is requesting access to the marketplace ",
                                                style: TextStyle(fontSize: 14, color: Colors.black87),
                                              ),
                                              TextSpan(
                                                text: marketplaceSnapshotData['flowName'],
                                                style: const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.bold),
                                              ),
                                              const TextSpan(
                                                text: " Would you like to approve and grant permission?",
                                                style: TextStyle(fontSize: 14, color: Colors.black87),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(
                                          Icons.circle,
                                          size: 12,
                                          color: !notification.status ? Colors.green : Colors.yellow,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                      );
                    }).toList(),
                  );
                }
              },
            ),
          ) else Expanded(
            child: StreamBuilder<List<NotificationModel>>(
              stream: _usersNotificationsStream(),
              builder: (context, notificationSnapshot) {
                if (notificationSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (notificationSnapshot.hasError) {
                  return Center(child: Text('Error: ${notificationSnapshot.error}'));
                } else if (!notificationSnapshot.hasData || notificationSnapshot.data!.isEmpty) {
                  return const Center(child: Text('No notifications'));
                } else {
                  final notifications = notificationSnapshot.data!;
                  return ListView(
                    children: notifications.map((notification) {
                      return StreamBuilder<Map<String, dynamic>?>(
                        stream: _marketplaceDataStream(notification.agentFlowRef),
                        builder: (context, marketplaceSnapshot) {
                          if (marketplaceSnapshot.connectionState == ConnectionState.waiting) {
                            return Container(
                              height: 70,
                              alignment: Alignment.center,
                              margin: const EdgeInsets.fromLTRB(50, 8, 50, 8),
                              decoration: BoxDecoration(
                                color: AppColors.messageBgColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        height: 10,
                                        width: double.infinity,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        height: 10,
                                        width: 100,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          } else if (marketplaceSnapshot.hasError) {
                            return Center(child: Text('Error: ${marketplaceSnapshot.error}'));
                          } else if (!marketplaceSnapshot.hasData) {
                            return const Center(child: Text('Marketplace data not found'));
                          } else {
                            final marketplaceSnapshotData = marketplaceSnapshot.data!;
                            return Container(
                              margin: const EdgeInsets.fromLTRB(50, 8, 50, 8),
                              decoration: const BoxDecoration(
                                color: AppColors.messageBgColor,
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                              ),
                              child: Container(
                                    padding: const EdgeInsets.all(6),
                                    child: ListTile(
                                      title: RichText(
                                        text: TextSpan(
                                          children: [
                                            const TextSpan(
                                              text: 'Your ',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black87),
                                            ),
                                            TextSpan(
                                              text: marketplaceSnapshotData[
                                                  'flowName'],
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.black87,
                                                fontFamily: 'Graphik',
                                              ),
                                            ),
                                            const TextSpan(
                                              text:
                                                  " marketplace request has been accepted by the admin. You can now access all the features.",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black87),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                          }
                        },
                      );
                    }).toList(),
                  );
                }
              },
            ),
          )
        ],
      )
    );
  }

  void _updateMarketplaceUserDialog(NotificationModel notification, String marketplaceName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          title: const Text(
            'Marketplace access request',
            style: TextStyle(
              fontSize: 18,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
              children: [
                const TextSpan(
                  text: 'Hello! ',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                TextSpan(
                  text: notification.email,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(
                  text: " has sent you an access request for the marketplace ",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                TextSpan(
                  text: marketplaceName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(
                  text: '. Would you like to accept this request?',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Close',
                style: TextStyle(color: Colors.black87),
              ),
            ),
            InkWell(
              onTap: () async {
                await _updateMarketplaceUsers(notification.agentFlowRef, notification.userRef!);
                Navigator.of(context).pop();
              },
              child: Container(
                height: 30,
                alignment: Alignment.center,
                width: 80,
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
                child: const Text(
                  'Accept',
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
