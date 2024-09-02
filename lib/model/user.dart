class UserModel {
  final String uid;
  final String name;
  final String email;
  final String authType;
  late final String? primaryWorkSpace;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.authType,
    this.primaryWorkSpace
  });
}
