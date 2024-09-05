import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppLogoHorizontal extends StatelessWidget {
  const AppLogoHorizontal({
    super.key,
    this.fontSize = 30,
    this.fontWeight = FontWeight.w600,
    this.gradientColors = const [
      Color(0xC5F53A9F)
      ,Color(0xFF18AF9E)],
  });

  final double fontSize;
  final FontWeight fontWeight;
  final List<Color> gradientColors;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
      Image.asset('assets/images/maslow_icon.png',height: 40,width: 40,),
      const SizedBox(width: 10,),
      ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: gradientColors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child:
          Text(
            'MaslowAgents',
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
              fontFamily: 'Graphik',
            ),
          )
    ),
    ]
      );
  }
}
