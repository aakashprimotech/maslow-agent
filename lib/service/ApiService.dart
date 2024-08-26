import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../model/slammie_bot_response.dart';

class ApiService {
  final String _defaultUrl =
      'https://fusionflow.maslow.ai/api/v1/prediction/4bddea5e-c392-4dbe-bd05-3ef2aa60942d';
  final Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer vWxybfzjsUPjB2i4+/uoLrC6BMxvfXUD71o8hZWnf9Y=',
  };

  Future<SlammieBotResponse> withAuthChatbot(String message,
      {String? url, dynamic authentication, String? sessionId}) async {
    Uri uri;

    if (url != null) {
      uri = Uri.parse(url);
    } else {
      uri = Uri.parse(_defaultUrl);
    }

    Map<String, String> headers;

    if (authentication != null) {
      headers = {
        'Content-Type': 'application/json',
        authentication['key']: "${authentication['type']} ${authentication['token']}",
      };
    } else {
      headers = _defaultHeaders;
    }

    Map<String, dynamic> jsonBody = {};
    if ( sessionId == null || sessionId == '') {
      jsonBody = {
        "question": message,
        "overrideConfig": {
          "disableFileDownload": true,
        }
      };
    }else {
      jsonBody = {
        "question": message,
        "overrideConfig": {
          "disableFileDownload": true,
          "sessionId": sessionId,
        }
      };
    }

    final response = await http.post(
      uri,
      headers: headers,
      body: json.encode(jsonBody),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return SlammieBotResponse.fromJson(responseData);
    } else {
      Exception(
          'Failed to send request: ${response.statusCode}\nResponse: ${response.body}');

      throw Exception(
          'Failed to send request: ${response.statusCode}\nResponse: ${response.body}');
    }
  }


  Future<SlammieBotResponse> withoutAuthChatbot(String message,
      {String? url, String? sessionId}) async {

    final Map<String, String> _defaultAstroHeaders = {
      'Content-Type': 'application/json',
    };

    Map<String, dynamic> jsonBody = {};
    if ( sessionId == null || sessionId == '') {
      jsonBody = {
        "question": message,
        "overrideConfig": {
          "disableFileDownload": true,
        }
      };
    }else {
      jsonBody = {
        "question": message,
        "overrideConfig": {
          "disableFileDownload": true,
          "sessionId": sessionId,
        }
      };
    }

    final response = await http.post(
      Uri.parse(url!),
      headers: _defaultAstroHeaders,
      body: json.encode(jsonBody),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return SlammieBotResponse.fromJson(responseData);
    } else {
      Exception(
          'Failed to send request: ${response.statusCode}\nResponse: ${response.body}');

      throw Exception(
          'Failed to send request: ${response.statusCode}\nResponse: ${response.body}');
    }
  }

}

// Slammie API Call
/*
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/slammie_bot_response.dart';

class ApiService {
  final String _defaultUrl = 'https://fusionflow.maslow.ai/api/v1/prediction/4bddea5e-c392-4dbe-bd05-3ef2aa60942d';
  final Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer vWxybfzjsUPjB2i4+/uoLrC6BMxvfXUD71o8hZWnf9Y=',
  };

  Future<SlammieBotResponse> slammieChatBot(String message, {String? url, dynamic authentication,String? sessionId}) async {
    Uri uri;

    if(url != null){
      uri = Uri.parse(url);
    }else{
      uri = Uri.parse(_defaultUrl);
    }

    Map<String, String> headers;

    if(authentication != null){
      headers = {
        'Content-Type': 'application/json',
        authentication['key']: "${authentication['type']} ${authentication['token']}",
      };
    }else{
      headers = _defaultHeaders;
    }

    final Map<String, dynamic> jsonBody = {
      "question": message,
      "overrideConfig": {
        "disableFileDownload": true,
        "sessionId" : sessionId,
      }
    };

    final response = await http.post(
      uri,
      headers: headers,
      body: json.encode(jsonBody),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return SlammieBotResponse.fromJson(responseData);
    } else {
      Exception('Failed to send request: ${response.statusCode}\nResponse: ${response.body}');

      throw Exception('Failed to send request: ${response.statusCode}\nResponse: ${response.body}');
    }
  }
}
*/
