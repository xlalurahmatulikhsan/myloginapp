import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:loginapp/screens/auth.dart';
import 'package:loginapp/screens/home.dart';
import 'package:lottie/lottie.dart';
import '../Helper/Main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  final storage = LocalStorage('my_data.json');
  Widget forward = AuthScreen();
  String? token;

  initStateAsyc() async {
    String? a = await getToken();
    if (a != null) {
      setState(() {
        token = a;
        forward = HomeScreen();
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initStateAsyc();
    });
    _animationController = AnimationController(
      duration: Duration(seconds: 10),
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    print("Token: $token");

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/lottie/splash.json',
            controller: _animationController,
            height: MediaQuery.of(context).size.height * 0.7,
            alignment: Alignment.center,
            animate: true,
            onLoaded: (composition) {
              _animationController
                ..duration = composition.duration
                ..forward().whenComplete(
                  () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => forward,
                    ),
                  ),
                );
            },
          ),
          Text(
            "My Login App",
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
