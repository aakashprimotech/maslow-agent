
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:maslow_agents/utils/custom_snackbar.dart';

import '../../service/user_service.dart';
import '../../utils/colors.dart';
import '../admin/admin_workspace_dialog.dart';
import '../common/nothing_to_show.dart';
import '../users_marketplace/users_marketplace_screen.dart';
import 'agent_flow_model.dart';
import 'agent_flow_screen.dart';

class AgentsListingScreen extends StatefulWidget {
  const AgentsListingScreen({super.key});

  @override
  State<AgentsListingScreen> createState() => _AgentsListingScreenState();
}

class _AgentsListingScreenState extends State<AgentsListingScreen> {

  _deleteAgentFlowDialog(String documentId) {
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
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        elevation: 5,
        backgroundColor: AppColors.backgroundColor,
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
              "Agent Flow",
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          Container(
            height: 30,
            alignment: Alignment.center,

            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: const BoxDecoration(
              color: Color(0xFF40bc92),
              borderRadius: BorderRadius.all(
                Radius.circular(5),
              ),
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UsersMarketplaceScreen(),
                  ),
                );
              },
              child: const Text(
                'Marketplace',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        /*  Container(
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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UsersMarketplaceScreen(),
                  ),
                );
              },
              child: Image.asset(
                'assets/images/marketplace.png',
                height: 20,
                width: 20,
              ),
            ),
          ),*/
          Container(
            padding: const EdgeInsets.only(right: 30),
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            child: InkWell(
              onTap: () {
                showDialog<void>(
                  context: context,
                  builder: (context) {
                    return AdminWorkspaceDialog();
                  },
                );
              },
              child: Container(
                height: 30,
                margin: const EdgeInsets.only(right: 10),
                decoration: const BoxDecoration(
                  color: AppColors.createWorkspaceAppBarBtnColor,
                  borderRadius: BorderRadius.all(
                    Radius.circular(5),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Add Agent Flow',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 5),
                      Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(color: AppColors.textFieldBorderColor,height: 1,),
          const SizedBox(height: 30,),
          StreamBuilder<QuerySnapshot>(
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
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final doc = snapshot.data!.docs[index];
                  AgentFlowModel agentFlowModel =
                      AgentFlowModel.fromFirestore(doc);
                  return Container(
                    margin: const EdgeInsets.fromLTRB(40, 8, 40, 8),
                    decoration: const BoxDecoration(
                      color: AppColors.messageBgColor,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
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
                        padding: const EdgeInsets.all(10),
                        child: ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      style: DefaultTextStyle.of(context).style,
                                      children: [
                                        const TextSpan(
                                          text: 'Name: ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500),
                                        ),
                                        TextSpan(
                                          text: agentFlowModel.flowName,
                                        ),
                                      ],
                                    ),
                                  ),
                                  RichText(
                                    text: TextSpan(
                                      style: DefaultTextStyle.of(context).style,
                                      children: [
                                        const TextSpan(
                                          text: 'API Url: ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500),
                                        ),
                                        TextSpan(
                                          text: agentFlowModel.apiURL.length > 40
                                              ? '${agentFlowModel.apiURL.substring(0, 40)}...'
                                              : agentFlowModel.apiURL,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      _deleteAgentFlowDialog(doc.id);
                                    },
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                    ),
                                    onPressed: () {
                                      showDialog<void>(
                                        context: context,
                                        builder: (context) {
                                          return AdminWorkspaceDialog(
                                              agentFlowModel: agentFlowModel,
                                              flowDocumentId: doc.id);
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
