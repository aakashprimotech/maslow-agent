import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as Io;
import 'package:http/http.dart' as http;
import 'dart:convert';

class SocketsTesting extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<SocketsTesting> {
  late Io.Socket socket;
  late String socketIOClientId;
  TextEditingController messageController = TextEditingController();
  List<String> messages = [];


  @override
  void initState() {
    super.initState();
    _connectToSocket();
  }

  void _connectToSocket() {
    socket = Io.io('http://192.168.75.206:3000/', <String, dynamic>{
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
    //
    socket.onConnectError((data) {
      debugPrint('Connection Error: ${data.toString()}');
    });
    //
    socket.onError((data) {
      debugPrint('Socket Error: ${data.toString()}');
    });

    socket.onDisconnect((_) {
      debugPrint('Disconnected from the socket server');
    });

    // The next agent in line
    socket.on('nextAgent', (nextAgent) {
      debugPrint('nextAgent: $nextAgent');
    });

    socket.on('agentReasoning', (agentReasoning) {
      debugPrint('agentReasoning: $agentReasoning');
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Socket.IO Client')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Socket.IO Client ID: $socketIOClientId'),
              const SizedBox(height: 25,),
              ElevatedButton(
                onPressed: ()=> sendQuery("Full Name: Rahul Sharma, mailto:email:rahual121@gmail.com, Phone Number: 9512112121, Position Applied For: Senior Software Engineer, Experience: 5 years., Position: Senior Software Engineer, Skills: Team Lead, Computer Programming (React and Veu.js)., Start Date (if Selected): 25/07/2024, Is the candidate Selected?: Yes"),
                child: const Text('Send Query'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> sendQuery(String question) async {
    const url = "http://192.168.75.206:3000/api/v1/prediction/1fd71962-b3e4-45e8-bdb6-f14bd88e46ac";
    final response = await http.post(
      Uri.parse(url),
      body: jsonEncode({
        "question": question,
        "socketIOClientId": socketIOClientId,
      }),
      headers: {
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      debugPrint("Response: API Call done");
    } else {
      debugPrint("Error: ${response.statusCode}");
    }
  }
}
