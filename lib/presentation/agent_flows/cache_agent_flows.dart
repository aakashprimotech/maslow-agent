import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../service/user_service.dart';
import '../../utils/timestamp_converter.dart';

typedef VoidCallbackAction = void Function(String, List<dynamic>);

class CachedStreamBuilder extends StatefulWidget {
  final String marketplaceId;
  final VoidCallbackAction onTap;

  const CachedStreamBuilder({Key? key, required this.marketplaceId, required this.onTap,}) : super(key: key);

  @override
  _CachedStreamBuilderState createState() => _CachedStreamBuilderState();
}

class _CachedStreamBuilderState extends State<CachedStreamBuilder> {
  late Stream<QuerySnapshot> _streamSnapshot;

  @override
  void initState() {
    super.initState();
    _streamSnapshot = FirebaseFirestore.instance
        .collection('marketplace')
        .doc(widget.marketplaceId)
        .collection(UserService().getUserReference()!.id)
        .orderBy('createdAt', descending: true) // Order by 'createdAt' field in descending order
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _streamSnapshot,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(height: 600, alignment: Alignment.center, child: const Text('No Data Available'));
        } else {
          var userDataList = snapshot.data!.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: userDataList.length,
            itemBuilder: (context, index) {
              var data = userDataList[index];
              String dummyQuestion = data['dummyQuestion'] ?? 'No Question';
              List<dynamic> dummyAnswer = data['dummyAnswer'] ?? [];

              return InkWell(
                onTap: () {
                  widget.onTap(dummyQuestion, dummyAnswer);
                },
                child: ListTile(
                  title: Text(
                    dummyQuestion,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    formatTimestamp(data['createdAt']),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black54,
                    ),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}
