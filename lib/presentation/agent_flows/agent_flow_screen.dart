import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:socket_io_client/socket_io_client.dart' as Io;
import 'package:http/http.dart' as http;
import '../../model/user.dart';
import '../../service/shared_pref_service.dart';
import '../../service/user_service.dart';
import '../../utils/colors.dart';
import 'dart:convert';
import 'agent_flow_model.dart';
import 'agents_data_response.dart';

class AgentFlowScreen extends StatefulWidget {
  AgentFlowModel agentFlowModel;
  DocumentReference? marketplaceReference;
  AgentFlowScreen({super.key,required this.agentFlowModel,this.marketplaceReference});

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

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _connectToSocket();

    if(widget.agentFlowModel.dummyQuestion!=null && widget.agentFlowModel.dummyAnswer!=null){
      _userInformationsController.text = widget.agentFlowModel.dummyQuestion!;
      agentReasoningList = widget.agentFlowModel.dummyAnswer ??[];
    }

    _textFieldFocusNode.addListener(() {
      if (_textFieldFocusNode.hasFocus && _userInformationsController.text.isNotEmpty) {
        _textFieldFocusNode.unfocus();
        _showTrialDialog();
      }
    });
  }

  Future<void> _getCurrentUser() async {
    currentUser = await SessionManager.getUser();
    if (currentUser != null) {
      setState(() {});
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
        _scrollToBottom(); // Scroll to bottom when new agent is added
      });
    });

    socket.on('agentReasoning', (agentReasoning) async {

      final encodingResult = jsonEncode(agentReasoning);
      final jsonResult = jsonDecode(encodingResult);

      await Future.delayed(const Duration(seconds: 1));

      if (jsonResult is Map<String, dynamic>) {
        final agent = AgentReasoning.fromJson(jsonResult);
        setState(() {
          agentReasoningList.add(agent);
          // isAgentLoading = false;
        });
      } else if (jsonResult is List<dynamic>) {
        final newAgents = jsonResult.map((e) => AgentReasoning.fromJson(e)).toList();
        setState(() {
          agentReasoningList = newAgents;
          isAgentLoading = false;
          _scrollToBottom(); // Scroll to bottom when new agent is added
        });
      }
    });

    socket.on('event', (data) {
      debugPrint('Event received: ${data.toString()}');
    });
  }

  @override
  void dispose() {
    socket.disconnect();
    _textFieldFocusNode.dispose();
    _userInformationsController.dispose();

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
          title: const Text('Trial Version'),
          content: const Text(
            'This is just a trial version of the agent flow. To use this agent flow, please contact the administrator.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            InkWell(
              onTap: (){
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
    final TextEditingController _queryController = TextEditingController(); // Controller for query input
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          title: const Text('Add Information'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please provide additional information for the admin.'),
              const SizedBox(height: 20),
              TextFormField(
                maxLines: 3,
                controller: _queryController,
                decoration: const InputDecoration(
                  labelText: 'Enter your query',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(
                    fontSize: 12.0, // Adjust the font size of the label text
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
                if(_queryController.text.isNotEmpty){
                  await _saveInformation(_queryController.text);
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
      final firestore = FirebaseFirestore.instance;

      await firestore.collection('notification').add({
        'userRef': UserService().getUserReference(), // Replace with actual user reference
        'query': query,
        'email': currentUser?.email,
        'agentFlowRef': widget.marketplaceReference, // Replace with actual agent flow reference
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission request sent successfully. We\'ll get back to you soon.')),
      );
    } catch (e) {
      print('Error saving information: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save information.')),
      );
    }
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
            Image.asset('assets/images/maslow_icon.png', height: 22, width: 22),
            const SizedBox(width: 10),
            Text(
              widget.agentFlowModel.flowName,
              style: const TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: Container(
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
              onTap: (){
                if (_userInformationsController.text.isNotEmpty) {
                  _textFieldFocusNode.unfocus();
                  _showTrialDialog();
                }
              },
              child: TextFormField(
                focusNode: _textFieldFocusNode,
                controller: _userInformationsController,
                decoration: InputDecoration(
                  hintText: "Enter your query here...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.grey, width: 1.0),
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
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () async {
                  if(widget.agentFlowModel.dummyQuestion!=null && widget.agentFlowModel.dummyAnswer!=null){
                    _showTrialDialog();
                  }else{
                    if(_userInformationsController.text.isNotEmpty){
                      sendQuery();
                    }
                  }
                },
                child: Container(
                  height: 50,
                  margin: const EdgeInsets.only(top: 15,bottom: 15),
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
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                  padding: const EdgeInsets.all(5),
                  child: !isLoading
                      ? const Text(
                    'Submit',
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  )
                      : const CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController, // Attach the ScrollController
                itemCount: agentReasoningList.length + (isAgentLoading ? 1 : 0), // Add 1 more for the loading indicator
                itemBuilder: (context, index) {
                  if (index < agentReasoningList.length) {
                    var reasoning = agentReasoningList[index];
                    return _subtasks(reasoning);
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
          Lottie.asset('assets/animations/next_agent_lottie.json',height: 35,width: 35),
          const SizedBox(width: 10),
          Text(
            'Loading details for $currentAgentName...',
            style: const TextStyle(color: Colors.black87, fontSize: 16),
          ),
        ],
      ),
    );
  }


  Widget _subtasks(AgentReasoning reasoning) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.grey.withAlpha(50),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            reasoning.agentName,
            style: const TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Divider(color: Colors.grey.withAlpha(150)),
          const SizedBox(height: 10),
          reasoning.messages?.isNotEmpty == true
              ? Column(
            children: List.generate(reasoning.messages?.length ?? 0, (index) {
              return Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  reasoning.messages![index],
                  style: const TextStyle(color: Colors.black87, fontSize: 16),
                ),
              );
            }),
          )
              : Text(
            reasoning.instructions?.isEmpty == true ? "Finished" : reasoning.instructions!,
            style: const TextStyle(color: Colors.black87, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Future<void> sendQuery() async {
    setState(() {
      isLoading = true; // Start loading
      agentReasoningList.clear(); // Clear previous answers
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

        await FirebaseFirestore.instance
            .collection('marketplace')
            .doc(widget.marketplaceReference?.id)
            .update({
          'dummyQuestion': _userInformationsController.text,
          'dummyAnswer': agentReasoningList.map((e) => e.toJson()).toList(),
          // Convert to JSON

        } );}
    } catch (e) {
      debugPrint('Error sending query: $e');
    } finally {
      setState(() {
        isLoading = false; // Stop loading
      });
    }
  }
}