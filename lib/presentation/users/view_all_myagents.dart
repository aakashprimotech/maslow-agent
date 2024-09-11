/*
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:maslow_agents/utils/captalize_string.dart';
import 'package:shimmer/shimmer.dart';

import '../../service/user_service.dart';
import '../../utils/colors.dart';
import '../agent_flows/agent_flow_model.dart';
import '../agent_flows/agent_flow_screen.dart';

class ViewAllMyagents extends StatefulWidget {
  const ViewAllMyagents({super.key});

  @override
  State<ViewAllMyagents> createState() => _ViewAllMyagentsState();
}

class _ViewAllMyagentsState extends State<ViewAllMyagents> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;
  String _searchText = "";

  final List<String> _categories = [
    'Education',
    'Recruitment',
    'Technology',
    'Sports',
    'Uncategorized'
  ];
  void _showCategoryFilter() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Category'),
          content: SingleChildScrollView(
            child: ListBody(
              children: _categories.map((category) {
                return ListTile(
                  title: Text(category),
                  tileColor: _selectedCategory == category ? Colors.grey[200] : null, // Highlight selected category
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                    Navigator.of(context).pop(); // Close the dialog
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedCategory = null; // Clear the selected category
                });
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Clear Filter'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
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
              'My Agents',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontFamily: 'Graphik',),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Container(color: AppColors.textFieldBorderColor, height: 1,),

              const SizedBox(height: 50.0),
              const Text(
                'My Agents',
                style: TextStyle(
                  fontSize: 25,
                  fontFamily: 'Graphik',
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20.0),
              Container(
                margin: const EdgeInsets.fromLTRB(80, 0, 80, 0),
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: SizedBox(
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

                      var filteredAgentFlows = _filterAgentFlows(agentFlows);

                      return  Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30),
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 8.0,
                            mainAxisSpacing: 8.0,
                            childAspectRatio: 1.8,
                          ),
                          itemCount: filteredAgentFlows.length,
                          itemBuilder: (context, index) {
                            var agentFlow = filteredAgentFlows[index];
                            var doc = filteredAgentFlows[index];

                            return Container(
                              width: 280.0,
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
                                            style: TextStyle(
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
                                        style:  TextStyle(fontSize: 12),
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
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:maslow_agents/utils/captalize_string.dart';
import 'package:shimmer/shimmer.dart';

import '../../service/user_service.dart';
import '../../utils/colors.dart';
import '../agent_flows/agent_flow_model.dart';
import '../agent_flows/agent_flow_screen.dart';

class ViewAllMyagents extends StatefulWidget {
  const ViewAllMyagents({super.key});

  @override
  State<ViewAllMyagents> createState() => _ViewAllMyagentsState();
}

class _ViewAllMyagentsState extends State<ViewAllMyagents> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;
  String _searchText = "";
  Timer? _debounce;

  final List<String> _categories = [
    'Education',
    'Recruitment',
    'Technology',
    'Sports',
    'Uncategorized'
  ];

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchText = value.toLowerCase();
      });
    });
  }

  void _showCategoryFilter() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Category'),
          content: SingleChildScrollView(
            child: ListBody(
              children: _categories.map((category) {
                return ListTile(
                  title: Text(category),
                  tileColor: _selectedCategory == category ? Colors.grey[200] : null, // Highlight selected category
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                    Navigator.of(context).pop(); // Close the dialog
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedCategory = null; // Clear the selected category
                });
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Clear Filter'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
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
              'My Agents',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontFamily: 'Graphik',),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Container(color: AppColors.textFieldBorderColor, height: 1,),

              const SizedBox(height: 50.0),
              const Text(
                'My Agents',
                style: TextStyle(
                  fontSize: 25,
                  fontFamily: 'Graphik',
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20.0),
              Container(
                margin: const EdgeInsets.fromLTRB(80, 0, 80, 0),
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
                  onChanged: _onSearchChanged,  // Use the debounce method for delayed search
                ),
              ),
              const SizedBox(height: 20.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: SizedBox(
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

                      var filteredAgentFlows = _filterAgentFlows(agentFlows);

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 8.0,
                            mainAxisSpacing: 8.0,
                            childAspectRatio: 1.8,
                          ),
                          itemCount: filteredAgentFlows.length,
                          itemBuilder: (context, index) {
                            var agentFlow = filteredAgentFlows[index];
                            var doc = snapshot.data!.docs[index];

                            return Container(
                              width: 280.0,
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
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
