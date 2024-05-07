import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:loginapp/models/Users.dart';
import 'package:loginapp/screens/auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:loginapp/screens/profiledit.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Profile _profile;
  var baseurl = 'https://2fbf7z4v-80.asse.devtunnels.ms/myloginapp-api';
  final storage = new LocalStorage('my_data.json');
  String? token;
  String? username;
  bool _isEditing = false;

  Future<Profile> fetchProfile() async {
    final response = await http.post(
      Uri.parse('${baseurl}/user/profile/$username'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${token}'
      },
    );
    Map<String, dynamic> responseJson = jsonDecode(response.body);
    print(responseJson);
    if (responseJson['type'] == 'Error') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseJson['message'])),
      );
      return new Profile(
        username: '',
        email: '',
        nama: '',
        alamat: '',
        kelamin: '',
        nohp: '',
        photo: 'default.jpg',
      );
    } else {
      return Profile.fromJson(responseJson);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    token = storage.getItem('token');
    username = storage.getItem('username');
    print('token $token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Anda harus login terlebih dahulu')),
      );

      // Redirect ke halaman login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AuthScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: fetchProfile(),
        builder: (context, snapshot) {
          print("STATE: ${snapshot.connectionState} ");
          print(snapshot.data);
          return snapshot.connectionState == ConnectionState.done
              ? ProfileComponent(baseurl: baseurl, profile: snapshot.data)
              : Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                );
        });
  }
}

class ProfileComponent extends StatelessWidget {
  const ProfileComponent({
    super.key,
    required this.baseurl,
    required Profile? profile,
  }) : _profile = profile;

  final String baseurl;
  final Profile? _profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 30,
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(bottom: 20),
              child: CircleAvatar(
                radius: 70,
                backgroundColor: Colors.grey,
                foregroundImage:
                    NetworkImage("$baseurl/user/photo/${_profile?.photo}"),
              ),
            ),
            Positioned(
              top: 110,
              child: IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              EditProfileScreen(profile: _profile!)));
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                      Color.fromARGB(255, 160, 214, 239)),
                ),
                icon: Icon(
                  Icons.edit,
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
        Container(
          margin: EdgeInsets.only(top: 20, bottom: 10),
          child: Column(
            children: [
              Text(
                _profile!.nama,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "@${_profile!.username}",
                style: TextStyle(
                  color: Color.fromARGB(255, 170, 151, 216),
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
        Container(
          alignment: Alignment.center,
          margin: EdgeInsets.all(20),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(255, 63, 17, 177),
                spreadRadius: 2,
                blurRadius: 1,
                offset: Offset(2, 2), // changes position of shadow
              ),
            ],
          ),
          child: Column(
            children: [
              InputWidget(
                label: "Email",
                value: _profile!.email,
              ),
              SizedBox(height: 5),
              InputWidget(
                label: "Nama Lengkap",
                value: _profile!.nama,
              ),
              SizedBox(height: 5),
              InputWidget(
                label: "Nomor Hp",
                value: _profile!.nohp,
              ),
              SizedBox(height: 5),
              InputWidget(
                label: "Jenis Kelamin",
                value: _profile!.kelamin.isEmpty
                    ? ''
                    : (_profile!.kelamin == 'L' ? "Laki-laki" : "Perempuan"),
              ),
              SizedBox(height: 5),
              InputWidget(
                value: _profile!.alamat,
                label: "Alamat",
                maxline: 5,
                align: TextAlign.left,
              ),
            ],
          ),
        )
      ],
    );
  }
}

class InputWidget extends StatelessWidget {
  const InputWidget({
    super.key,
    this.value = '',
    required this.label,
    this.maxline = 1,
    this.align = TextAlign.center,
  });

  final String label;
  final String value;
  final int maxline;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: TextEditingController(text: value),
      textAlign: align,
      maxLines: maxline,
      enabled: false,
      style: TextStyle(color: Color.fromARGB(255, 211, 184, 247), fontSize: 20),
      decoration: InputDecoration(
        fillColor: Colors.white,
        alignLabelWithHint: true,
        focusColor: Colors.white,
        hoverColor: Colors.white,
        labelStyle: TextStyle(fontSize: 18),
        label: Center(
          child: Text(
            this.label,
            style: TextStyle(color: Colors.white),
          ),
        ),
        border: InputBorder.none,
      ),
    );
  }
}

class ProfileNoData extends StatelessWidget {
  const ProfileNoData({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Center(
        child: Text(
          "No Data",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
