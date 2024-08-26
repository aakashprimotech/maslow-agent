
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:maslow_agents/utils/custom_snackbar.dart';

import '../../model/user.dart';
import '../../service/user_service.dart';
import '../../utils/colors.dart';
import '../agent_flows/agent_flow_model.dart';
import '../common/key_value_list.dart';


class AdminWorkspaceDialog extends StatefulWidget {
  AgentFlowModel? agentFlowModel;
  String? flowDocumentId;

  AdminWorkspaceDialog({super.key, this.agentFlowModel, this.flowDocumentId});

  @override
  State<AdminWorkspaceDialog> createState() => _AdminWorkspaceDialogState();
}

class _AdminWorkspaceDialogState extends State<AdminWorkspaceDialog> {
  final TextEditingController _flowNameController = TextEditingController();
  final TextEditingController _socketsUrlController = TextEditingController();
  final TextEditingController _apiUrlController = TextEditingController();
  final TextEditingController _tokenHeader = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _showAuthSection = false;
  bool _isPublishedValue =false;
  final TextEditingController _authHeaderKeyController =
      TextEditingController();
  final TextEditingController _confirmDeleteController =
      TextEditingController();
  UserModel? currentUser;

  final List<String> _categories = [
    'Education',
    'Recruitment',
    'Technology',
    'Sports',
    'Uncategorized'
  ];
  String? _selectedCategory = 'uncategorized';

  @override
  void initState() {
    super.initState();

    _btnText = widget.flowDocumentId == null ? "Save" : "Update";
    if (widget.agentFlowModel != null) {
      _flowNameController.text = widget.agentFlowModel?.flowName ??"";
      _apiUrlController.text = widget.agentFlowModel?.apiURL ?? "";
      _socketsUrlController.text = widget.agentFlowModel?.socketUrl ?? "";
      _tokenHeader.text = widget.agentFlowModel?.authentication.token ?? "";
      _authHeaderKeyController.text = widget.agentFlowModel?.authentication.key ?? "";
      _descriptionController.text = widget.agentFlowModel?.description ?? "";
      _isPublishedValue = widget.agentFlowModel?.isPublished ?? false;
      _selectedCategory = widget.agentFlowModel?.category;
    }
  }

  var headerKeyValues = [
    const MapEntry('key1', 'value1'),
  ];

  String? selectedTokenType;

  final authTokenTypes = [
    "Bearer",
    "Basic",
    "Digest",
    "OAuth",
    "JWT",
    "API Key",
    "Hawk",
    "AWS4-HMAC-SHA256",
    "NTLM",
    "Negotiate",
    "Token",
    "SAML",
    "Access Token",
    "Client-ID",
    "Session ID"
  ];

  Color selectedWorkspaceColor = Colors.grey.withAlpha(100);
  String? _imageUrl;
  String? _btnText;
  String? workspaceText;
  String? dialogHeaderText;
  bool _showConfirmDeleteField = false;

  void addWorkspace() async {
    String socketUrl = _socketsUrlController.text.trim();
    String apiUrl = _apiUrlController.text.trim();
    String headerToken = _tokenHeader.text.trim();
    String authHeaderKey = _authHeaderKeyController.text.trim();
    String flowName = _flowNameController.text.trim();

    if (socketUrl.isEmpty || apiUrl.isEmpty) {
      context.showCustomSnackBar('Please provide both socket and API URL');
      return;
    }

    final userRef = UserService().getUserReference();

    if (userRef != null) {
      AgentFlowModel agentFlowModel = AgentFlowModel(
          createdBy: userRef,
          apiURL: apiUrl,
          socketUrl: socketUrl,
          createdAt: Timestamp.now(),
          updatedAt: Timestamp.now(),
          flowName: flowName,
          isPublished: _isPublishedValue,
          description: _descriptionController.text,
        category: _selectedCategory ?? 'Uncategorized', // Default value if no category selected
        authentication: Authentication(
              key: authHeaderKey,
              token: headerToken,
              type: selectedTokenType ?? ""), );

      await FirebaseFirestore.instance
          .collection('marketplace')
          .add(agentFlowModel.toFirestore());

      context.showCustomSnackBar('workspace added successfully');
    }

    Navigator.pop(context);
  }

  void updateWorkspace() async {
    String socketUrl = _socketsUrlController.text.trim();
    String apiUrl = _apiUrlController.text.trim();
    String headerToken = _tokenHeader.text.trim();
    String authHeaderKey = _authHeaderKeyController.text.trim();
    String flowName = _flowNameController.text.trim();

    if (socketUrl.isEmpty ||
        apiUrl.isEmpty ||
        flowName.isEmpty) {
      return;
    }

    final userRef = UserService().getUserReference();

    if(userRef != null) {
      AgentFlowModel agentFlowModel = AgentFlowModel(
        createdBy: userRef,
        apiURL: apiUrl,
        socketUrl: socketUrl,
        updatedAt: Timestamp.now(),
        flowName: flowName,
        createdAt: Timestamp.now(),
        isPublished: _isPublishedValue,
        description: _descriptionController.text,
        category: _selectedCategory ?? 'Uncategorized', // Default value if no category selected
        authentication: Authentication(
          key: authHeaderKey,
          token: headerToken,
          type: selectedTokenType ?? "",
        ),
      );

      await FirebaseFirestore.instance
          .collection('marketplace')
          .doc(widget.flowDocumentId) // Specify the document ID
          .update(agentFlowModel.toFirestore());

      context.showCustomSnackBar('workspace updated successfully');
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      title: Text(widget.agentFlowModel!=null ? 'Update Agent Flow' : 'Create Agent Flow'),
      contentPadding: const EdgeInsets.all(20.0),
      content: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width / 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _flowNameController,
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _apiUrlController,
                          decoration: const InputDecoration(
                            labelText: 'API URL',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _socketsUrlController,
                          decoration: const InputDecoration(
                            labelText: 'Socket URL',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Category',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _categories.map((category) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedCategory = category;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: _selectedCategory == category
                                        ? AppColors.primaryColor
                                        : Colors.grey,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  color: _selectedCategory == category
                                      ? AppColors.primaryColor.withOpacity(0.1)
                                      : Colors.transparent,
                                ),
                                child: Text(
                                  category,
                                  style: TextStyle(
                                    color: _selectedCategory == category
                                        ? AppColors.primaryColor
                                        : Colors.black,
                                    fontSize: 12
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 25),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 50,
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      height: 150,
                      width: 150,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(75),
                          border:
                              Border.all(color: Colors.grey.withAlpha(100))),
                      child: _imageUrl != null
                          ? Image.network(_imageUrl!,
                              height: double.infinity,
                              width: double.infinity,
                              fit: BoxFit.cover)
                          : const Icon(
                              Icons.star,
                              size: 80,
                            ),
                    ),
                  )
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: _isPublishedValue,
                    onChanged: (bool? value) {
                      setState(() {
                        _isPublishedValue = value ?? false;
                      });
                    },
                  ),
                  const Text('Publish'),
                ],
              ),
              const SizedBox(height: 10,),
              Row(
                children: [
                  Checkbox(
                    value: _showAuthSection,
                    onChanged: (bool? value) {
                      setState(() {
                        _showAuthSection = value ?? false;
                      });
                    },
                  ),
                  const Text('Show Advance Settings'),
                ],
              ),
              _showAuthSection
                  ? Column(
                      children: [
                        const SizedBox(height: 20),
                        Container(
                          decoration: BoxDecoration(
                              // color: Colors.grey.withAlpha(50),
                              color: AppColors.messageBgColor,
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.security),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    "Authorization",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 120,
                                    child: TextFormField(
                                      controller: _authHeaderKeyController,
                                      decoration: const InputDecoration(
                                          labelText: 'Key',
                                          border: OutlineInputBorder()),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  SizedBox(
                                    width: 150,
                                    child: InputDecorator(
                                      decoration: const InputDecoration(
                                        labelText: 'Token Type',
                                        contentPadding: EdgeInsets.symmetric(vertical: 0),
                                        border: OutlineInputBorder(),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: selectedTokenType,
                                          isExpanded: true,
                                          hint: const Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 8),
                                            child: Text('Token Type', overflow: TextOverflow.ellipsis),
                                          ),
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              selectedTokenType = newValue;
                                            });
                                          },
                                          items: authTokenTypes.map<DropdownMenuItem<String>>((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                                child: Text(value, overflow: TextOverflow.ellipsis),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _tokenHeader,
                                      decoration: const InputDecoration(
                                        labelText: 'Header Token',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Header Values",
                              style: TextStyle(fontSize: 16),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            KeyValueList(
                              initialPairs: headerKeyValues,
                              onChanged: (pairs) {
                                setState(() {
                                  headerKeyValues = pairs;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    )
               : const SizedBox()
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.black87),
          ),
        ),
        InkWell(
          onTap: (widget.flowDocumentId == null ||
                  widget.flowDocumentId!.isEmpty == true)
              ? addWorkspace
              : updateWorkspace,
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
                  offset: const Offset(0, 1), // changes position of shadow
                ),
              ],
              borderRadius: const BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            padding: const EdgeInsets.all(5),
            child: Text(
              _btnText!,
              style: const TextStyle(fontSize: 15, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
