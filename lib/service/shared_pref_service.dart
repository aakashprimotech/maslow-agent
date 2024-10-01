import 'package:shared_preferences/shared_preferences.dart';

import '../model/user.dart';

class SessionManager {
  static const String _keyUid = 'uid';
  static const String _keyName = 'name';
  static const String _keyEmail = 'email';
  static const String _keyAuthType = 'user';
  static const String _keyPrimaryWorkspace = 'primaryWorkspace';
  static const String _guestNotificationId= "guest_notification_id";
  static const String _signedAdminRole = "_signed_admin_role";

  static Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_keyUid, user.uid);
    prefs.setString(_keyName, user.name);
    prefs.setString(_keyEmail, user.email);
    prefs.setString(_keyAuthType, user.authType);
    prefs.setString(_keyPrimaryWorkspace, user.primaryWorkSpace ?? "");
  }

  static Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString(_keyUid);
    final name = prefs.getString(_keyName);
    final email = prefs.getString(_keyEmail);
    final userType = prefs.getString(_keyAuthType);
    final primaryWorkspaceId = prefs.getString(_keyPrimaryWorkspace);


    if (uid != null && name != null && email != null) {
      return UserModel(
          uid: uid,
          name: name,
          email: email,
          authType : userType ?? 'user',
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
          authType: user.authType,
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

  static Future<void> saveAdminRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_signedAdminRole, role);
  }

  static Future<String?> getAdminRole() async {
    final prefs = await SharedPreferences.getInstance();
    final adminRole = prefs.getString(_signedAdminRole);
    return (adminRole == null || adminRole.isEmpty) ? null : adminRole;
  }

  Future<void> clearGuestNotificationId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_guestNotificationId);
  }
}
