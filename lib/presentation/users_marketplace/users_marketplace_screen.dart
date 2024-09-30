import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:maslow_agents/utils/captalize_string.dart';
import 'package:maslow_agents/utils/custom_snackbar.dart';
import 'package:shimmer/shimmer.dart';

import '../admin/admin_workspace_dialog.dart';
import '../agent_flows/agent_flow_model.dart';
import '../agent_flows/agent_flow_screen.dart';

class UsersMarketplaceScreen extends StatefulWidget {
  const UsersMarketplaceScreen({super.key});

  @override
  State<UsersMarketplaceScreen> createState() => _UsersMarketplaceScreenState();
}

class _UsersMarketplaceScreenState extends State<UsersMarketplaceScreen> {
  String _searchText = "";
  String? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
                      .collection('marketplace')
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

  List<AgentFlowModel> _filterAgentFlows(List<AgentFlowModel> agentFlows) {
    if (_searchText.isEmpty && _selectedCategory == null) {
      return agentFlows;
    }

    return agentFlows.where((agentFlow) {
      final matchesSearchText = agentFlow.category.toLowerCase().contains(_searchText) ||
          agentFlow.flowName.toLowerCase().contains(_searchText);
      final matchesCategory = _selectedCategory == null || agentFlow.category == _selectedCategory;

      return matchesSearchText && matchesCategory;
    }).toList();
  }

  void _showCategoryFilter() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Category'),
          content: SizedBox(
            width: 250,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('marketplaceCategories').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No categories found.'));
                }

                final categories = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: categories.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    var categoryData = categories[index].data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(categoryData['name']),
                      onTap: () {
                        // Handle category selection here
                        setState(() {
                          _selectedCategory = categoryData['name'];
                        });
                        Navigator.of(context).pop();
                      },
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedCategory = null;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Clear Filter'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20.0),
            const Text(
              'Agents',
              style: TextStyle(
                fontSize: 25,
                fontFamily: 'Graphik',
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
            const SizedBox(height: 30.0),
            Container(
              margin: const EdgeInsets.fromLTRB(30, 0, 30, 0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search agents...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.filter_list),
                        if (_selectedCategory != null) ...[
                          const SizedBox(width: 4),
                          Text(
                            _selectedCategory!,
                            style: const TextStyle(color: Colors.black54, fontSize: 14),
                          ),
                        ],
                      ],
                    ),
                    onPressed: _showCategoryFilter, // Show category filter on button press
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
            const SizedBox(height: 20.0),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('marketplace')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 16.0,
                          mainAxisSpacing: 16.0,
                          childAspectRatio: 1.5 / 0.7,
                        ),
                        itemCount: 3,
                        itemBuilder: (context, index) {
                          return Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              padding: const EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: 60.0,
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
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Error fetching data'));
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('Nothing to show'));
                  }

                  var agentFlows = snapshot.data!.docs.map((doc) {
                    return AgentFlowModel.fromFirestore(doc);
                  }).toList();

                  var filteredAgentFlows = _filterAgentFlows(agentFlows);

                  return filteredAgentFlows.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 10.0,
                              mainAxisSpacing: 10.0,
                              childAspectRatio:
                                  (MediaQuery.of(context).size.width / 3) /
                                      (MediaQuery.of(context).size.height /
                                          3.2),
                            ),
                            itemCount: filteredAgentFlows.length,
                            itemBuilder: (context, index) {
                              var agentFlow = filteredAgentFlows[index];
                              final doc = snapshot.data!.docs[index];

                              return Container(
                                padding: const EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8.0),
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              agentFlow.flowName.capitalize() ??
                                                  "N/A",
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            if (agentFlow.category !=
                                                "Uncategorized")
                                              Text(
                                                agentFlow.category
                                                        .capitalize() ??
                                                    "N/A",
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF40bc92),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 10.0),
                                        Text(
                                          agentFlow.description,
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        const SizedBox(
                                          height: 4,
                                        ),
                                        Row(
                                          children: [
                                            const Text(
                                              'Marketplace visibility: ',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              agentFlow.isPublished
                                                      .toString()
                                                      .capitalize() ??
                                                  'false',
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                IconButton(
                                                  icon:
                                                      const Icon(Icons.delete),
                                                  onPressed: () {
                                                    _deleteAgentFlowDialog(
                                                        doc.id, context);
                                                  },
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.edit),
                                                  onPressed: () {
                                                    showDialog<void>(
                                                      context: context,
                                                      builder: (context) {
                                                        return AdminWorkspaceDialog(
                                                          agentFlowModel:
                                                              agentFlow,
                                                          flowDocumentId:
                                                              doc.id,
                                                        );
                                                      },
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                            InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        AgentFlowScreen(
                                                      agentFlowModel: agentFlow,
                                                      marketplaceReference:
                                                          doc.reference,
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                height: 30,
                                                alignment: Alignment.center,
                                                width: 80,
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xFF40bc92),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey
                                                          .withOpacity(0.2),
                                                      spreadRadius: 3,
                                                      blurRadius: 7,
                                                      offset:
                                                          const Offset(0, 1),
                                                    ),
                                                  ],
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                    Radius.circular(10),
                                                  ),
                                                ),
                                                padding:
                                                    const EdgeInsets.all(5),
                                                child: const Text(
                                                  'Chat',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                        )
                      : const Center(
                          child: Text('No marketplace found'),
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
