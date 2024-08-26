import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/user.dart';


class SessionManager {
  static const String _keyUid = 'uid';
  static const String _keyName = 'name';
  static const String _keyEmail = 'email';
  static const String _keyPrimaryWorkspace = 'primaryWorkspace';

  static const String _guestNotificationId= "guest_notification_id";

  static Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_keyUid, user.uid);
    prefs.setString(_keyName, user.name);
    prefs.setString(_keyEmail, user.email);
    prefs.setString(_keyPrimaryWorkspace, user.primaryWorkSpace ?? "");
  }

  static Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString(_keyUid);
    final name = prefs.getString(_keyName);
    final email = prefs.getString(_keyEmail);
    final primaryWorkspaceId = prefs.getString(_keyPrimaryWorkspace);


    if (uid != null && name != null && email != null) {
      return UserModel(
          uid: uid,
          name: name,
          email: email,
          primaryWorkSpace: primaryWorkspaceId);
    }
    return null;
  }

  static Future<void> updateUserWorkSpace(
      {required String workSpaceReferance}) async {
    final user = await getUser();
    if (user != null) {
      saveUser(UserModel(
          uid: user.uid,
          name: user.name,
          email: user.email,
          primaryWorkSpace: workSpaceReferance));
    }
  }

  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<void> saveNotificationId(String reference) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_guestNotificationId, reference);
  }

  Future<String?> getNotificationId() async {
    final prefs = await SharedPreferences.getInstance();
    final reference = prefs.getString(_guestNotificationId);
    return (reference == null || reference.isEmpty) ? null : reference;
  }

  Future<void> clearGuestNotificationId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_guestNotificationId);
  }
}
