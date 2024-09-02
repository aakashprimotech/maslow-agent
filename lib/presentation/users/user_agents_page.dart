import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:maslow_agents/utils/captalize_string.dart';
import 'package:maslow_agents/utils/custom_snackbar.dart';

import 'package:shimmer/shimmer.dart';

import '../../service/user_service.dart';
import '../agent_flows/agent_flow_model.dart';
import '../agent_flows/agent_flow_screen.dart';

class UserAgentsPage extends StatelessWidget {
  const UserAgentsPage({super.key});

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
            Container(
              margin: const EdgeInsets.only(top: 20),
              height: 170,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('marketplace')
                    .snapshots(),
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
                            width: 200.0,
                            // Fixed width for horizontal scrolling
                            margin: const EdgeInsets.symmetric(horizontal: 8.0),
                            padding: const EdgeInsets.all(12.0),
                            // Reduced padding
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(
                                  color: Colors.grey.shade300), // Added border
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
                    scrollDirection: Axis.horizontal,
                    itemCount: agentFlows.length,
                    itemBuilder: (context, index) {
                      var agentFlow = agentFlows[index];
                      var doc = filteredDocs[index];

                      return Container(
                        width: 280.0,
                        // Fixed width for horizontal scrolling
                        margin: const EdgeInsets.only(right: 8.0),
                        padding: const EdgeInsets.all(12.0),
                        // Reduced padding
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                              color: Colors.grey.shade300), // Added border
                        ),
                        child: Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                        agentFlow.category.capitalize() ??
                                            "N/A",
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
                                        // marketplaceReference: doc.reference,
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
                                    'Chat',
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.white),
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
          ],
        ),
      ),
    );
  }
}
