import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppLogoHorizontal extends StatelessWidget {
  const AppLogoHorizontal({
    super.key,
    this.fontSize = 40,
    this.fontWeight = FontWeight.w600,
    this.gradientColors = const [Color(0xFFF53A9F), Color(0xFF18AF9E)],
  });

  final double fontSize;
  final FontWeight fontWeight;
  final List<Color> gradientColors;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: gradientColors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.bug_report, size: 50, color: Colors.white),
          Text(
            'MaslowAgents',
            style: GoogleFonts.playball(
              color: Colors.white,
              fontSize: fontSize,
              fontWeight: fontWeight,
            ),
          )
        ],
      ),
    );
  }
}
