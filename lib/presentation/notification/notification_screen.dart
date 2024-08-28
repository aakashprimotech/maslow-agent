import 'package:flutter/material.dart';
import 'package:maslow_agents/presentation/common/nothing_to_show.dart';

import '../../utils/colors.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            Image.asset(
              'assets/images/maslow_icon.png',
              height: 22,
              width: 22,
            ),
            const SizedBox(
              width: 10,
            ),
            const Text(
              'Notifications',
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(color: AppColors.textFieldBorderColor, height: 1,),
          Expanded(
            child: Container(
              alignment: Alignment.center,
              child: const NothingToShow(),
            ),
          ),
        ],
      ),
    );
  }
}
