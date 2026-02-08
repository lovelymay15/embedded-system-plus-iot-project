import 'package:flutter/material.dart';
import 'dart:async';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoAnimation;

  late AnimationController _textController;
  late Animation<double> _textAnimation;

  late AnimationController _buttonController;
  late Animation<double> _buttonAnimation;

  @override
  void initState() {
    super.initState();

    // Logo animation
    _logoController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _logoAnimation =
        Tween<double>(begin: 0.8, end: 1.0).animate(_logoController);

    // Text animation
    _textController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _textAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_textController);

    // Button animation
    _buttonController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _buttonAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_buttonController);

    // Start the animations
    _logoController.forward();
    _textController.forward();
    _buttonController.forward();

    // Delay to simulate splash screen and ensure Firebase is ready
    Timer(Duration(seconds: 3), _showButton);
  }

  Future<void> _showButton() async {
    setState(() {
      _buttonController.forward();
    });
  }

  Future<void> _navigateToLogin() async {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _textAnimation,
              child: Text(
                'THE LONG WAIT IS OVER',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF7F8C8D),
                ),
              ),
            ),
            SizedBox(height: 50),
            ScaleTransition(
              scale: _logoAnimation,
              child: Image.asset('assets/logo.png', width: 250),
            ),
            SizedBox(height: 16),
            FadeTransition(
              opacity: _textAnimation,
              child: Text(
                '- PURESENSE -',
                style: GoogleFonts.montserrat(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ),
            SizedBox(height: 8),
            FadeTransition(
              opacity: _textAnimation,
              child: Text(
                'BY 3MW',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Georgia Pro',
                  color: Color(0xFF7F8C8D),
                ),
              ),
            ),
            SizedBox(height: 50),
            FadeTransition(
              opacity: _textAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'ELEVATING HYGIENE',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  Text(
                    'THROUGH INNOVATION',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 50),
            FadeTransition(
              opacity: _buttonAnimation,
              child: ElevatedButton(
                onPressed: _navigateToLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2C3E50),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'PROCEED',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
