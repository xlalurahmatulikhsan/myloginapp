import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:loginapp/screens/auth.dart';
import 'package:loginapp/screens/profile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.index});
  final int? index;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _index;
  final List<String> labels = ['Home', 'Profile'];
  final List<Widget> _pages = <Widget>[Container(), ProfileScreen()];
  final storage = new LocalStorage('my_data.json');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _index = widget.index ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
              onPressed: () {
                storage.clear();

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AuthScreen(),
                  ),
                );
              },
              icon: Icon(
                Icons.logout,
                color: Theme.of(context).colorScheme.background,
              ))
        ],
        centerTitle: true,
        title: Text(
          labels[_index],
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
          ),
        ),
      ),
      body: SingleChildScrollView(child: _pages[_index]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (index) {
          setState(() {
            _index = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          )
        ],
      ),
    );
  }
}
