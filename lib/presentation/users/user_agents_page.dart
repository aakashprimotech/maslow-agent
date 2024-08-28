import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:maslow_agents/utils/captalize_string.dart';
import 'package:maslow_agents/utils/custom_snackbar.dart';

import 'package:shimmer/shimmer.dart';

import '../../service/user_service.dart';
import '../../utils/colors.dart';
import '../agent_flows/agent_flow_model.dart';
import '../agent_flows/agent_flow_screen.dart';
import '../common/nothing_to_show.dart';
import '../admin/admin_workspace_dialog.dart';

class UserAgentsPage extends StatelessWidget {
  const UserAgentsPage({super.key});

  _deleteAgentFlowDialog(String documentId,BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          content: const Text("Are you sure you want to delete agent flow?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Delete"),
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection('agent_flow')
                      .doc(documentId) // Specify the document ID
                      .delete();

                  Navigator.pop(context);
                  context.showCustomSnackBar('Agent flow deleted successfully');
                } catch (e) {
                  context.showCustomSnackBar('Failed to delete document');
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20.0),
            const Text(
              'Marketplace',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'Browse and select which agent you would like to work with below.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8.0),
            Container(
              margin: const EdgeInsets.only(top: 20),
              height: 170,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('marketplace').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 3, // Number of placeholder items
                      itemBuilder: (context, index) {
                        return Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            width: 200.0, // Fixed width for horizontal scrolling
                            margin: const EdgeInsets.symmetric(horizontal: 8.0),
                            padding: const EdgeInsets.all(12.0), // Reduced padding
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(color: Colors.grey.shade300), // Added border
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 60.0, // Fixed height
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 8.0),
                                Container(
                                  width: 120.0,
                                  height: 10.0,
                                  color: Colors.white,
                                ),
                                const Spacer(),
                                Container(
                                  height: 24.0,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Error fetching data'));
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('Nothing to show'));
                  }

                  var agentFlows = snapshot.data!.docs.map((doc) {
                    return AgentFlowModel.fromFirestore(doc);
                  }).toList();

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    // padding: const EdgeInsets.symmetric(horizontal: 15),
                    itemCount: agentFlows.length,
                    itemBuilder: (context, index) {
                      var agentFlow = agentFlows[index];
                      var doc = snapshot.data!.docs[index];

                      return Container(
                        width: 280.0, // Fixed width for horizontal scrolling
                        margin: const EdgeInsets.only(right: 8.0),
                        padding: const EdgeInsets.all(12.0), // Reduced padding
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(color: Colors.grey.shade300), // Added border
                        ),
                        child: Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      agentFlow.flowName.capitalize() ?? "N/A",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (agentFlow.category != "Uncategorized")
                                      Text(
                                        agentFlow.category.capitalize() ?? "N/A",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF40bc92),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  agentFlow.description,
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const Spacer(),
                              ],
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AgentFlowScreen(
                                        agentFlowModel: agentFlow,
                                        marketplaceReference: doc.reference,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  height: 30,
                                  alignment: Alignment.center,
                                  width: 80,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF40bc92),
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
                                    'Chat',
                                    style: TextStyle(fontSize: 14, color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20.0),
            const Text(
              'My Agents',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
        Expanded(
          child: Container(alignment: Alignment.center,
            child: const Text(
                  'Feature coming soon!',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,color: Colors.black54),
                ),
              ),
        )
        /*    Container(
              margin: const EdgeInsets.only(top: 20),
              height: 170,
              child: Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('agent_flow')
                      .where("createdBy", isEqualTo: UserService().getUserReference())
                      .orderBy("updatedAt", descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColor,
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return const Center(child: Text('Error fetching data'));
                    } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const NothingToShow();
                    }

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final doc = snapshot.data!.docs[index];
                        AgentFlowModel agentFlowModel =
                        AgentFlowModel.fromFirestore(doc);

                        return Container(
                          width: 280.0,
                          height: 100,
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.all(12.0), // Reduced padding
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: Colors.grey.shade300), // Added border
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    agentFlowModel.flowName.capitalize() ?? "N/A",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (agentFlowModel.category != "Uncategorized")
                                    Text(
                                      agentFlowModel.category.capitalize() ?? "N/A",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF40bc92),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                agentFlowModel.description,
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12),
                              ),
                              const SizedBox(height: 10,),
                              Align(
                                alignment: Alignment.centerRight,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AgentFlowScreen(
                                          agentFlowModel: agentFlowModel,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    height: 30,
                                    alignment: Alignment.center,
                                    width: 80,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF40bc92),
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
                                      'Chat',
                                      style: TextStyle(fontSize: 14, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),*/
          ],
        ),
      ),
    );
  }
}
