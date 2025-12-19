import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB71C1C), // Dark red matching design
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Dapur Mamma',
              style: GoogleFonts.lobster(
                fontSize: 48,
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
