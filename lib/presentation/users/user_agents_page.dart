import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maslow_agents/presentation/users/view_all_myagents.dart';
import 'package:maslow_agents/presentation/users/viewall_marketplaces_page.dart';
import 'package:maslow_agents/utils/captalize_string.dart';

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
                fontFamily: 'Graphik',
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Browse and select which agent you would like to work with below.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black87,
                  ),
                ),
                InkWell(
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ViewallMarketplacesPage(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.only(right: 12),
                    child: const Text(
                      'View All',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Expanded(
              flex: 2,
              child: Container(
                margin: const EdgeInsets.only(top: 18),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('marketplace')
                      .where('isPublished',isEqualTo: true)
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 8.0,
                          mainAxisSpacing: 8.0,
                          childAspectRatio: (MediaQuery.of(context).size.width / 3) / (MediaQuery.of(context).size.height /3.2),
                        ),
                        itemCount: 8,
                        itemBuilder: (context, index) {
                          return Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
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

                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 1.0,
                        mainAxisSpacing: 8.0,
                        childAspectRatio: (MediaQuery.of(context).size.width / 3) / (MediaQuery.of(context).size.height / 2.8),
                      ),
                      itemCount: agentFlows.length<=8 ? agentFlows.length : 8,
                      itemBuilder: (context, index) {
                        var agentFlow = agentFlows[index];
                        var doc = snapshot.data!.docs[index];

                        return Container(
                          width: 280.0,
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
                                  // const Spacer(),
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
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'My Agents',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontFamily: 'Graphik',
                  ),
                ),
                InkWell(
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ViewAllMyagents(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.only(right: 12),
                    child: const Text(
                      'View All',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              flex: 1,
              child: Container(
                margin: const EdgeInsets.only(top: 18),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('marketplace')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 1.0,
                          mainAxisSpacing: 8.0,
                          childAspectRatio: (MediaQuery.of(context).size.width / 3) / (MediaQuery.of(context).size.height / 2.8),
                        ),
                        itemCount: 8, // Number of placeholder items
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

                    return GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 1.0,
                        mainAxisSpacing: 8.0,
                        childAspectRatio: 1.8,
                      ),
                      itemCount: agentFlows.length,
                      itemBuilder: (context, index) {
                        var agentFlow = agentFlows[index];
                        var doc = filteredDocs[index];

                        return Container(
                          width: 280.0,
                          margin: const EdgeInsets.only(right: 8.0),
                          padding: const EdgeInsets.all(12.0),
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
                                        style: TextStyle(
                                          fontSize: 14.sp,
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
                                    style:  TextStyle(fontSize: 12.sp),
                                  ),
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
            ),
          ],
        ),
      ),
    );
  }
}
