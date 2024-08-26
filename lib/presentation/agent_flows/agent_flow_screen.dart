import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:socket_io_client/socket_io_client.dart' as Io;
import 'package:http/http.dart' as http;
import '../../utils/colors.dart';
import 'dart:convert';

import 'agent_flow_model.dart';
import 'agents_data_response.dart';

class AgentFlowScreen extends StatefulWidget {
  AgentFlowModel agentFlowModel;
  AgentFlowScreen({super.key,required this.agentFlowModel});

  @override
  State<AgentFlowScreen> createState() => _AgentFlowScreenState();
}

class _AgentFlowScreenState extends State<AgentFlowScreen> {
  List<AgentReasoning> agentReasoningList = [];
  late Io.Socket socket;
  late String socketIOClientId;
  bool isLoading = false;
  bool isAgentLoading = false; // Track if an agent's details are loading
  String currentAgentName = ""; // Track the current agent's name
  final ScrollController _scrollController = ScrollController(); // Add this

  final TextEditingController _userInformationsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _connectToSocket();
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
      try {
        // Directly decode the incoming data since it appears to already be a JSON string
        final jsonResult = jsonDecode(agentReasoning);

        await Future.delayed(const Duration(seconds: 1));

        // Forcefully handle the jsonResult as a List
        final newAgents = (jsonResult as List<dynamic>)
            .map<AgentReasoning>((e) => AgentReasoning.fromJson(e))
            .toList();

        setState(() {
          agentReasoningList = newAgents;
          isAgentLoading = false;
          _scrollToBottom(); // Scroll to bottom when new agents are added
        });
      } catch (e) {
        // Handle any errors that occur during parsing
        setState(() {
          isAgentLoading = false;
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
      body: Column(
        children: [
          Container(color: AppColors.textFieldBorderColor,height: 1,),
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
                  TextFormField(
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
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () async {
                        sendQuery();
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
          ) : Text(
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
      agentReasoningList.clear();
    });

    String url =
        widget.agentFlowModel.apiURL;
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
      setState(() {
        isLoading = false; // Stop loading
      });
    } else {
      setState(() {
        isLoading = false; // Stop loading even if there is an error
      });
    }
  }
}
