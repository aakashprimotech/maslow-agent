import 'package:flutter/material.dart';
import 'package:maslow_agents/utils/captalize_string.dart';

import '../../model/user.dart';

class UserPopupMenu extends StatelessWidget {
  final UserModel? user;
  final VoidCallback onLogout;

  const UserPopupMenu({Key? key, this.user, required this.onLogout}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const CircleAvatar(
            backgroundImage: AssetImage('assets/images/user_placeholder.jpg'),
            radius: 18,
          ),
          title: Text(
            user?.name.capitalize() ?? "N/A",
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'Graphik',
              color: Colors.black87,
            ),
          ),
          subtitle: Text(
            user?.email ?? "N/A",
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
            ),
          ),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout,size: 22,),
          title: const Text('Logout',style: TextStyle( fontSize: 12,color: Colors.black87,),
          ),
          onTap: onLogout,
        ),
      ],
    );
  }
}