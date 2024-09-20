import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:lottie/lottie.dart';
import 'package:maslow_agents/utils/captalize_string.dart';
import 'package:maslow_agents/utils/progress_indictor_widget.dart';
import 'package:socket_io_client/socket_io_client.dart' as Io;
import 'package:http/http.dart' as http;
import '../../model/notification.dart';
import '../../model/user.dart';
import '../../service/shared_pref_service.dart';
import '../../service/user_service.dart';
import '../../utils/colors.dart';
import 'dart:convert';
import 'agent_flow_example.dart';
import 'agent_flow_model.dart';
import 'agents_data_response.dart';
import 'cache_agent_flows.dart';
import 'collapasable_agent_list.dart';

class AgentFlowScreen extends StatefulWidget {
  AgentFlowModel agentFlowModel;
  DocumentReference? marketplaceReference;

  AgentFlowScreen({super.key, required this.agentFlowModel, this.marketplaceReference});

  @override
  State<AgentFlowScreen> createState() => _AgentFlowScreenState();
}

class _AgentFlowScreenState extends State<AgentFlowScreen> {
  List<AgentReasoning> agentReasoningList = [];
  late Io.Socket socket;
  late String socketIOClientId;
  bool isLoading = false;
  bool isAgentLoading = false;
  String currentAgentName = "";
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _userInformationsController = TextEditingController();
  final FocusNode _textFieldFocusNode = FocusNode();
  UserModel? currentUser;

  List<AgentFlowExample> _examples = [];
  String? _selectedLabel;
  final Map<int, bool> _expandedItems = {};

  @override
  void initState() {
    super.initState();

    _getCurrentUser();
    _connectToSocket();
    _loadExamples();
  }

  Future<void> _loadExamples() async {
    List<AgentFlowExample> examples =
        await fetchExamples(widget.marketplaceReference!.id);
    setState(() async {
      bool isUserInMarketplace = widget.agentFlowModel.marketplaceUsers
          ?.any((ref) => ref.id == UserService().getUserReference()?.id) ?? false;

      if (!isUserInMarketplace) {
        _examples = examples;
        _userInformationsController.text = _examples.first.dummyQuestion!;
        for (final item in _examples.first.dummyAnswer!) {
          await Future.delayed(const Duration(seconds: 1));
          setState(() {
            agentReasoningList.add(item);
            _scrollToBottom();
          });

          if (_examples.isNotEmpty) {
            _selectedLabel = _examples[0].label;
          }
        }
        //expand last item of list
        _expandedItems[agentReasoningList.length - 1] = true;
      }
      // _connectToSocket();
    });
  }

  Future<void> _getCurrentUser() async {
    currentUser = await SessionManager.getUser();

    if (currentUser != null) {
      _textFieldFocusNode.addListener(() {
        if (_textFieldFocusNode.hasFocus &&
            _userInformationsController.text.isNotEmpty &&
            _examples.isNotEmpty &&
            currentUser?.authType != 'admin') {
          _textFieldFocusNode.unfocus();
          _showTrialDialog();
        }
      });
    }
  }

  void _connectToSocket() {
    socket = Io.io(widget.agentFlowModel.socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.onConnect((_) {
      debugPrint('Connected to the socket server');
      setState(() {
        socketIOClientId = socket.id ?? "";
      });
      debugPrint('Connected to ${socket.id}');
    });

    socket.onConnectError((data) {
      debugPrint('Connection Error: ${data.toString()}');
    });

    socket.onError((data) {
      debugPrint('Socket Error: ${data.toString()}');
    });

    socket.onDisconnect((_) {
      debugPrint('Disconnected from the socket server');
    });

    socket.on('nextAgent', (nextAgent) {
      debugPrint('nextAgent: $nextAgent');
      setState(() {
        isAgentLoading = true;
        currentAgentName = nextAgent.toString();
        _scrollToBottom();
      });
    });

    socket.on('agentReasoning', (agentReasoning) async {
      try {
        dynamic jsonResult;
        if (agentReasoning is String) {
          jsonResult = jsonDecode(agentReasoning);
        } else {
          jsonResult = agentReasoning;
        }

        await Future.delayed(const Duration(seconds: 1));

        final newAgents = (jsonResult as List<dynamic>)
            .map<AgentReasoning>((e) => AgentReasoning.fromJson(e))
            .toList();

        setState(() {
          agentReasoningList = newAgents;
          isAgentLoading = false;
          _scrollToBottom();
        });
      } catch (e) {
        setState(() {
          isAgentLoading = false;
        });
      }
    });


    /*   socket.on('agentReasoning', (agentReasoning) async {
      try {
        final jsonResult = jsonDecode(agentReasoning);
        await Future.delayed(const Duration(seconds: 1));
        final newAgents = (jsonResult as List<dynamic>)
            .map<AgentReasoning>((e) => AgentReasoning.fromJson(e))
            .toList();
        print(newAgents.toString() +"responseResponing 1");
        setState(() {
          agentReasoningList = newAgents;
          isAgentLoading = false;
          _scrollToBottom();
        });
      } catch (e) {
        print('parsingissuesareshowing'+e.toString());
        setState(() {
          isAgentLoading = false;
        });
      }
    });*/

    socket.on('event', (data) {
      debugPrint('Event received: ${data.toString()}');
    });
  }

  @override
  void dispose() {
    socket.disconnect();
    _textFieldFocusNode.dispose();
    _userInformationsController.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showTrialDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          title: const Text('Trial Version',
            style: TextStyle(
              color: Colors.black87,
              fontFamily: 'Graphik',
              fontSize: 20,
            ),),
          content: const Text(
            'This is just a trial version of the agent flow. To use this agent flow, please contact the administrator.',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 14,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).pop();
                _handleSubmit();
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
                      offset: const Offset(0, 1), // changes position of shadow
                    ),
                  ],
                  borderRadius: const BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                padding: const EdgeInsets.all(5),
                child: const Text(
                  'Submit',
                  style: TextStyle(fontSize: 13, color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleSubmit() {
    final TextEditingController queryController =
        TextEditingController(); // Controller for query input
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          title: const Text('Add Information',  style: TextStyle(
            color: Colors.black87,
            fontFamily: 'Graphik',
            fontSize: 20,
          ),),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                  'Please provide additional information for the admin.',  style: TextStyle(
                color: Colors.black87,
                fontSize: 14,
              ),),
              const SizedBox(height: 20),
              TextFormField(
                maxLines: 3,
                controller: queryController,
                decoration: const InputDecoration(
                  labelText: 'Enter your query',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(
                    fontSize: 12.0,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            InkWell(
              onTap: () async {
                Navigator.of(context).pop();
                if (queryController.text.isNotEmpty) {
                  await _saveInformation(queryController.text);
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
                      offset: const Offset(0, 1), // changes position of shadow
                    ),
                  ],
                  borderRadius: const BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                padding: const EdgeInsets.all(5),
                child: const Text(
                  'Save',
                  style: TextStyle(fontSize: 13, color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveInformation(String query) async {
    try {
      final notification = NotificationModel(
        userRef: UserService().getUserReference(),
        query: query,
        email: currentUser?.email,
        agentFlowRef: widget.marketplaceReference!,
        createdAt: Timestamp.now(),
        status: false,
        isAccepted: false,
      );

      FirebaseFirestore.instance
          .collection('notifications')
          .add(notification.toMap());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Permission request sent successfully. We\'ll get back to you soon.'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save information.'),
        ),
      );
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
        title: Image.asset('assets/images/maslow_logo.png', height: 22),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 30),
            child: Text(
              widget.agentFlowModel.flowName,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontFamily: 'Graphik',
              ),
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          (widget.agentFlowModel.marketplaceUsers!.contains(UserService().getUserReference()) &&
                  widget.agentFlowModel.marketplaceUsers != null)
              ? Container(
                  width: 250,
                  padding: const EdgeInsets.only(top: 10),
                  child: Column(
                    children: [
                      Container(
                        width: 250,
                        padding: const EdgeInsets.only(top: 10),
                        color: AppColors.messageBgColor.withAlpha(50),
                        child: Column(
                          children: [
                            CachedStreamBuilder(
                              marketplaceId: widget.marketplaceReference!.id,
                              onTap: (dummyQuestion, dummyAnswer) {
                                setState(() {
                                  _userInformationsController.text = dummyQuestion;
                                  agentReasoningList = dummyAnswer
                                      .map((item) => AgentReasoning.fromJson(
                                          item as Map<String, dynamic>))
                                      .toList();
                                });
                              },
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox(),
          Expanded(
            child: Column(
              children: [
                Container(
                  color: AppColors.textFieldBorderColor,
                  height: 1,
                ),
                Expanded(
                  child: Container(
                    color: AppColors.backgroundColor,
                    padding: const EdgeInsets.fromLTRB(100, 30, 100, 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Hello there, how can I help?",
                          style: TextStyle(color: Colors.black87, fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        InkWell(
                          onTap: () {},
                          child: TextFormField(
                            focusNode: _textFieldFocusNode,
                            controller: _userInformationsController,
                            decoration: InputDecoration(
                              hintText: "Enter your query here...",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(
                                    color: Colors.grey, width: 1.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(
                                    color: Colors.grey, width: 1.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(
                                    color: Colors.grey, width: 1.0),
                              ),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter your query';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.text,
                            minLines: 3,
                            maxLines: null,
                          ),
                        ),
                        if(agentReasoningList.isNotEmpty)
                        SizedBox(
                          height: 40,
                          child: ProgressIndicatorWidget(
                            steps: agentReasoningList
                                .map((e) => e.agentName)
                                .toList(),
                           /* clickedStep: (value) {
                              setState(() {
                                _expandedItems[value] = !_expandedItems[value]!;
                              });

                              // Calculate the scroll position
                              double itemHeight = 100; // Adjust this based on your item height
                              _scrollController.animateTo(
                                value * itemHeight,
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },*/

                              clickedStep: (value) {
                              setState(() {
                                if(_expandedItems[value]==true){
                                  _expandedItems[value] =false;
                                }else{
                                  _expandedItems[value] =true;
                                }
                                // _expandedItems[value] =true;
                                // _expandedItems[agentReasoningList.length - 1] = true;

                                double itemHeight = 100; // Adjust this based on your item height
                                _scrollController.animateTo(
                                  value * itemHeight,
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              });
                            },
                          ),
                        ),
                        (_examples.isNotEmpty && !widget.agentFlowModel.flowName.toLowerCase().contains('agent')) ?
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Text(
                              'Try out (${widget.agentFlowModel.flowName}) Agent Examples:',
                              style: const TextStyle(fontSize: 12, color: Colors.black87,fontWeight: FontWeight.w600),
                            ),
                          ) :const SizedBox(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (_examples.isNotEmpty)
                              SizedBox(
                                width : 400,
                                child: DropdownButtonFormField2<String>(
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  hint: Text(
                                    _examples.first.dummyQuestion ?? 'Select Any Example',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  items: _examples.map((example) {
                                    return DropdownMenuItem<String>(
                                      value: example.label,
                                      child: Text(
                                        example.label.capitalize() ?? "",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      )
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedLabel = newValue;
                                      var selectedExample = _examples.firstWhere((example) => example.label == newValue);
                                      _userInformationsController.text = selectedExample.dummyQuestion!;
                                      agentReasoningList = (selectedExample.dummyAnswer as List<dynamic>)
                                          .map((item) => item as AgentReasoning)
                                          .toList();
                                      _textFieldFocusNode.unfocus();
                                    });
                                  },
                                  onSaved: (value) {
                                    _selectedLabel = value.toString();
                                  },
                                  buttonStyleData: const ButtonStyleData(
                                    padding: EdgeInsets.only(right: 8),
                                  ),
                                  iconStyleData: const IconStyleData(
                                    icon: Icon(
                                      Icons.arrow_drop_down,
                                      color: Colors.black45,
                                    ),
                                    iconSize: 24,
                                  ),
                                  dropdownStyleData: DropdownStyleData(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  menuItemStyleData: const MenuItemStyleData(
                                    padding: EdgeInsets.symmetric(horizontal: 16),
                                  ),
                                ),
                              ) else const SizedBox(),
                            InkWell(
                              onTap: () async {
                                if (_examples.isNotEmpty &&
                                    currentUser?.authType != 'admin') {
                                  _showTrialDialog();
                                } else {
                                  if (_userInformationsController
                                      .text.isNotEmpty) {
                                    sendQuery();
                                  }
                                }
                              },
                              child: Container(
                                height: 50,
                                margin:
                                    const EdgeInsets.only(top: 15, bottom: 15),
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
                                      Radius.circular(10)),
                                ),
                                padding: const EdgeInsets.all(5),
                                child: !isLoading
                                    ? const Text(
                                        'Submit',
                                        style: TextStyle(
                                            fontSize: 15, color: Colors.white),
                                      )
                                    : const CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                            child: ListView.builder(
                            controller: _scrollController,
                            itemCount: agentReasoningList.length +
                                (isAgentLoading ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index < agentReasoningList.length) {
                                var reasoning = agentReasoningList[index];
                                return _subtasks(reasoning,index);
                              } else if (isAgentLoading) {
                                return _loadingIndicator();
                              } else {
                                return const SizedBox.shrink();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _loadingIndicator() {
    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey.withAlpha(50),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Lottie.asset('assets/animations/next_agent_lottie.json', height: 35,
              width: 35),
          const SizedBox(width: 10),
          Text(
            'Loading details for $currentAgentName...',
            style: const TextStyle(color: Colors.black87, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _subtasks(AgentReasoning reasoning,int index) {

    final isExpanded = _expandedItems[index] ?? (index == agentReasoningList.length - 1 ? true : false);

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.grey.withAlpha(50),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      padding: const EdgeInsets.all(15),
      child:  Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                reasoning.agentName,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              IconButton(
                icon: Icon(
                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  size: 20,
                  color: Colors.black87,
                ),
                onPressed: () {
                  setState(() {
                    _expandedItems[index] = !isExpanded;
                  });
                },
              ),
            ],
          ),
          if (isExpanded) ...[
            const SizedBox(height: 8),
            Divider(color: Colors.grey.withAlpha(150)),
            const SizedBox(height: 8),
            reasoning.messages?.isNotEmpty == true
                ? Column(
              children: List.generate(reasoning.messages?.length ?? 0, (msgIndex) {
                return Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: MarkdownBody(
                    data: reasoning.messages![msgIndex],
                  ),
                );
              }),
            ) : Text(reasoning.instructions?.isEmpty == true
                ? "Finished"
                : reasoning.instructions!,
              style: const TextStyle(color: Colors.black87, fontSize: 16),
            ),
          ] else
            const SizedBox.shrink(), // Optionally show a placeholder when collapsed
        ],
      ),
    );
  }

  Future<void> sendQuery() async {
    setState(() {
      isLoading = true;
      agentReasoningList.clear();
    });

    String url = widget.agentFlowModel.apiURL;

    try {
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode({
          "question": _userInformationsController.text,
          "socketIOClientId": socketIOClientId,
        }),
        headers: {
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        if (currentUser?.authType == 'admin') {
          updateOrCreateExamplesWithoutTransaction(
            widget.marketplaceReference!.id,
            AgentFlowExample(
              createdAt: Timestamp.now(),
              dummyQuestion: _userInformationsController.text,
              dummyAnswer: agentReasoningList.map((e) => e.toJson()).toList(),
              label: _userInformationsController.text,
            ),
          );
        } else {
          print({agentReasoningList.map((e) => e.toJson()).toList()}.toString() +"responseResponing4");
          await FirebaseFirestore.instance
              .collection('marketplace')
              .doc(widget.marketplaceReference?.id)
              .collection(UserService().getUserReference()!.id)
              .add({
            'dummyQuestion': _userInformationsController.text,
            'dummyAnswer': agentReasoningList.map((e) => e.toJson()).toList(),
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (e) {
      debugPrint('Error sending query: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateOrCreateExamplesWithoutTransaction(String marketplaceId, AgentFlowExample newExample) async {
    print(newExample.toString() +"responseResponing 3");
    DocumentReference marketplaceRef =
        FirebaseFirestore.instance.collection('marketplace').doc(marketplaceId);
    try {
      DocumentSnapshot snapshot = await marketplaceRef.get();

      if (!snapshot.exists) {
        await marketplaceRef.set({
          'examples': [newExample.toFirestore()],
        });
      } else {
        var data = snapshot.data() as Map<String, dynamic>?;

        if (data == null || !data.containsKey('examples')) {
          await marketplaceRef.update({
            'examples': [newExample.toFirestore()],
          });
        } else {
          await marketplaceRef.update({
            'examples': FieldValue.arrayUnion([newExample.toFirestore()]),
          });
        }
      }
      print("Operation successful!");
    } catch (e) {
      print("Error updating document: $e");
    }
  }

  Future<List<AgentFlowExample>> fetchExamples(String marketplaceId) async {
    DocumentReference marketplaceRef =
        FirebaseFirestore.instance.collection('marketplace').doc(marketplaceId);

    try {
      DocumentSnapshot snapshot = await marketplaceRef.get();

      if (!snapshot.exists) {
        print("Document doesn't exist.");
        return [];
      } else {
        var data = snapshot.data() as Map<String, dynamic>?;

        if (data == null || !data.containsKey('examples')) {
          print("No examples field found.");
          return [];
        } else {
          var examplesData = data['examples'] as List<dynamic>;
          List<AgentFlowExample> examples = examplesData
              .map((item) =>
                  AgentFlowExample.fromFirestore(item as Map<String, dynamic>))
              .toList();
          return examples;
        }
      }
    } catch (e, stackTrace) {
      print("Error fetching document: $e");
      print("Stack trace: $stackTrace");
      return [];
    }
  }
}