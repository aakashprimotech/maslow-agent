import 'package:flutter/material.dart';

class NothingToShow extends StatelessWidget {
  const NothingToShow({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        /*  Image.asset(
            "assets/images/nothing_to_show.jpg",
            width: 300,
            height: 200,
          ),*/
          const SizedBox(height: 10,),
          const Text(
            'Nothing to show',
            style: TextStyle(fontSize: 17, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
