import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:html' as html;



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

      if (!isUserInMarketplace && examples.isNotEmpty) {
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

        _expandedItems[agentReasoningList.length - 1] = true;

        if(agentReasoningList.isNotEmpty){
          final AgentReasoning? agentToShowINPopup = agentReasoningList.where((agent) => agent.messages?.isNotEmpty == true && agent.instructions?.isEmpty == true).lastOrNull;
          if(agentToShowINPopup != null){
            _showLastItemDialog(agentToShowINPopup);
          }
        }
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
                                _userInformationsController.text = dummyQuestion;
                                agentReasoningList.clear();
                                _addItemsWithDelay(dummyAnswer);
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
                              clickedStep: (value) {
                              setState(() {
                                if(_expandedItems[value]==true){
                                  _expandedItems[value] =false;
                                }else{
                                  _expandedItems[value] =true;
                                }
                                double itemHeight = 100;
                                _scrollController.animateTo(
                                  value * itemHeight,
                                  duration: const Duration(milliseconds: 300),
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
                                debugPrint("check list length: ${agentReasoningList.length - 1}");
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

  // Method to add items with delay
  Future<void> _addItemsWithDelay(List<dynamic> dummyAnswer) async {

    for (var item in dummyAnswer) {
      // Wait for 1 second
      await Future.delayed(const Duration(seconds: 1));

      // Update the list and call setState
      final agentReasoning = AgentReasoning.fromJson(item as Map<String, dynamic>);

      setState(() {
        agentReasoningList.add(agentReasoning);
      });
    }

    if(agentReasoningList.isNotEmpty){
      final AgentReasoning? agentToShowINPopup = agentReasoningList.where((agent) => agent.messages?.isNotEmpty == true && agent.instructions?.isEmpty == true).lastOrNull;
      if(agentToShowINPopup != null){
        _showLastItemDialog(agentToShowINPopup);
      }
    }
  }

  Widget _subtasks(AgentReasoning reasoning, int index) {
    final isExpanded = _expandedItems[index] ?? (index == agentReasoningList.length - 1 ? true : false);

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
                  /// Open dialog if this is the last item and it's being expanded
                  if (index == agentReasoningList.length - 1 && !isExpanded) {
                    Future.delayed(const Duration(milliseconds: 100), () {
                      _showLastItemDialog(reasoning);
                    });
                  }
                },
              ),
            ],
          ),
          // if(index == agentReasoningList.length - 1 && !isExpanded)...[
          //   _showLastItemDialog(reasoning)
          // ],
          // Visibility(
          //   visible: (index == agentReasoningList.length - 1 && !isExpanded),
          //     child: _showLastItemDialog(reasoning)
          //     ),
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
            )
                : Text(
              reasoning.instructions?.isEmpty == true ? "Finished" : reasoning.instructions!,
              style: const TextStyle(color: Colors.black87, fontSize: 16),
            ),
          ] else
            const SizedBox.shrink(),
        ],
      ),
    );
  }

  String sanitizeMarkdown(String text) {
    return text
        .replaceAll(RegExp(r'\*'), '')  // Remove asterisks
        .replaceAll(RegExp(r'\#'), '')  // Remove hashes
        .replaceAllMapped(RegExp(r'_(.*?)_'), (match) => match[1] ?? '')  // Remove italics (underscores)
        .replaceAllMapped(RegExp(r'\~(.*?)\~'), (match) => match[1] ?? '')  // Remove strikethrough (tildes)
        .replaceAllMapped(RegExp(r'\[(.*?)\]\((.*?)\)'), (match) => match[1] ?? '')  // Remove links
        .trim();  // Trim any leading or trailing whitespace
  }

  _showLastItemDialog(AgentReasoning reasoning) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Set border radius here
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8,
                maxHeight: MediaQuery.of(context).size.height * 0.8 // Set a reasonable max width for the dialog
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10), // Apply the same border radius
              child: AlertDialog(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(reasoning.agentName, overflow: TextOverflow.ellipsis),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(
                        Icons.close,
                        color: Colors.grey,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      reasoning.messages?.isNotEmpty == true
                          ? Column(
                        children: List.generate(
                            reasoning.messages?.length ?? 0, (msgIndex) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: MarkdownBody(data : reasoning.messages![msgIndex] ?? ""),
                          );
                        }),
                      )
                          : Text(
                        reasoning.instructions?.isEmpty == true
                            ? "Finished"
                            : reasoning.instructions!,
                        style: const TextStyle(color: Colors.black87, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      String contentToCopy = reasoning.messages?.isNotEmpty == true
                          ? reasoning.messages!.join('\n')
                          : (reasoning.instructions?.isEmpty == true ? "Finished" : reasoning.instructions!);

                      Clipboard.setData(ClipboardData(text: sanitizeMarkdown(contentToCopy)));

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Text copied to clipboard')),
                      );
                    },
                    child: const Icon(Icons.copy, color: Colors.grey, size: 20),
                  ),
                  TextButton(
                    onPressed: () async {
                      String contentToDownload = reasoning.messages?.isNotEmpty == true
                          ? reasoning.messages!.join('\n')
                          : (reasoning.instructions?.isEmpty == true ? "Finished" : reasoning.instructions!);

                      await _downloadAsPdf(sanitizeMarkdown(contentToDownload));
                    },
                    child: const Icon(Icons.download, color: Colors.grey, size: 20),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _downloadAsPdf(String content) async {
    final pdf = pw.Document();

    // Convert the Markdown content to PDF widgets
    List<pw.Widget> markdownWidgets = _convertMarkdownToWidgets(content);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start, // Align text to the left
          children: markdownWidgets,
        ),
      ),
    );

    try {
      final Uint8List pdfData = await pdf.save();
      final blob = html.Blob([pdfData], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);

      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'Agent Result.pdf')
        ..click();

      html.Url.revokeObjectUrl(url);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF downloaded successfully')),
      );
    } catch (e) {
      print("Error saving PDF: ${e.toString()}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save PDF: $e')),
      );
    }
  }

  List<pw.Widget> _convertMarkdownToWidgets(String content) {
    final List<pw.Widget> widgets = [];

    // Split content into lines
    final lines = content.split('\n');

    for (String line in lines) {
      // Handle headers
      if (line.startsWith('# ')) {
        widgets.add(pw.Text(line.substring(2), style: pw.TextStyle(fontSize: 30, fontWeight: pw.FontWeight.bold)));
      } else if (line.startsWith('## ')) {
        widgets.add(pw.Text(line.substring(3), style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)));
      } else if (line.startsWith('### ')) {
        widgets.add(pw.Text(line.substring(4), style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)));
      } else if (line.startsWith('*') || line.startsWith('_')) {
        // Handle italics
        widgets.add(pw.Text(line.replaceAll(RegExp(r'[\*_]+'), ''), style: pw.TextStyle(fontStyle: pw.FontStyle.italic)));
      } else if (line.startsWith('**') || line.startsWith('__')) {
        // Handle bold
        widgets.add(pw.Text(line.replaceAll(RegExp(r'[\*\_]+'), ''), style: pw.TextStyle(fontWeight: pw.FontWeight.bold)));
      } else if (line.isNotEmpty) {
        // Handle normal text
        widgets.add(pw.Text(line));
      }

      // Add spacing between lines for readability
      widgets.add(pw.SizedBox(height: 8)); // Increase spacing for better readability
    }

    return widgets;
  }
/*  Future<void> _downloadAsPdf(String content) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Center(
          child: pw.Text(content, style: pw.TextStyle(fontSize: 16)),
        ),
      ),
    );

    try {
      // Generate the PDF data
      final Uint8List pdfData = await pdf.save();

      // Create a blob from the data
      final blob = html.Blob([pdfData], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);

      // Create a link element and trigger the download
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'agent_reasoning.pdf')
        ..click();

      // Clean up
      html.Url.revokeObjectUrl(url);

      // Notify the user of successful download
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF downloaded successfully')),
      );
    } catch (e) {
      print("Error saving PDF: ${e.toString()}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save PDF: $e')),
      );
    }
  }*/

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



 /* Widget _subtasks(AgentReasoning reasoning,int index) {

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
            const SizedBox.shrink(),
        ],
      ),
    );
  }
*/
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
        if(!widget.agentFlowModel.marketplaceUsers!.contains(UserService().getUserReference())){
          updateOrCreateExamplesWithoutTransaction(
            widget.marketplaceReference!.id,
            AgentFlowExample(
              createdAt: Timestamp.now(),
              dummyQuestion: _userInformationsController.text,
              dummyAnswer: agentReasoningList.map((e) => e.toJson()).toList(),
              label: _userInformationsController.text,
            ),
          );
        }else{
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
      }
     catch (e) {
      debugPrint('Error sending query: $e');
    } finally {
      setState(() {
        isLoading = false;
      });

      if(agentReasoningList.isNotEmpty){
        final AgentReasoning? agentToShowINPopup = agentReasoningList.where((agent) => agent.messages?.isNotEmpty == true && agent.instructions?.isEmpty == true).lastOrNull;
        if(agentToShowINPopup != null){
          _showLastItemDialog(agentToShowINPopup);
        }
      }
    }
  }

  Future<void> updateOrCreateExamplesWithoutTransaction(String marketplaceId, AgentFlowExample newExample) async {
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