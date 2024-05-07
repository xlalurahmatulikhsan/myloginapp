import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:loginapp/models/Users.dart';
import 'package:localstorage/localstorage.dart';
import 'package:loginapp/screens/home.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool is_obscure = true;
  bool is_obscure2 = true; //untuk repassword
  final _formKey = GlobalKey<FormState>();
  final storage = new LocalStorage('my_data.json');
  var _is_login = true;

  var tempPass = '';
  var _enteredEmail = '';
  var _enteredPassword = '';
  var _enteredRePassword = '';
  var _enteredUsername = '';
  var baseurl = 'https://2fbf7z4v-80.asse.devtunnels.ms/myloginapp-api';
  File? _selectedImage;
  bool _isAuthenticating = false;

  void _submit() async {
    final _isValid = _formKey.currentState!.validate();
    if (!_isValid) return;

    _formKey.currentState!.save();

    var userCredential;
    ScaffoldMessenger.of(context).clearSnackBars();
    setState(() {
      _isAuthenticating = true;
    });

    if (_is_login) {
      final response = await http.post(
        Uri.parse('${baseurl}/auth/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': _enteredUsername,
          'password': _enteredPassword
        }),
      );
      Map<String, dynamic> responseJson = jsonDecode(response.body);
      setState(() {
        _isAuthenticating = false;
      });
      print(responseJson);
      if (responseJson['type'] == 'Error') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login Failed: ${responseJson['message']}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login Success')),
        );

        // Simpan Token dan Username di local storage
        storage.setItem('token', responseJson['token']);
        storage.setItem('username', _enteredUsername);
        // Buka Halaman Utama
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    } else {
      final response = await http.post(
        Uri.parse('${baseurl}/auth/register'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': _enteredUsername,
          'password': _enteredPassword,
          'repassword': _enteredRePassword,
          'email': _enteredEmail
        }),
      );
      Map<String, dynamic> responseJson = jsonDecode(response.body);
      setState(() {
        _isAuthenticating = false;
      });
      print(responseJson);
      if (responseJson['type'] == 'Error') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Register Failed: ${responseJson['message']}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Register Success')),
        );
        setState(() {
          _is_login = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin:
                    EdgeInsets.only(top: 30, bottom: 20, right: 20, left: 20),
                width: 200,
                child: Image.asset('assets/images/logo.png', fit: BoxFit.cover),
              ),
              Card(
                margin: EdgeInsets.only(left: 20, right: 20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!_is_login)
                            TextFormField(
                              decoration:
                                  InputDecoration(labelText: 'Email Adress'),
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                              textCapitalization: TextCapitalization.none,
                              validator: (val) {
                                var err = null;
                                if (val == null ||
                                    val.isEmpty ||
                                    !val.contains('@')) {
                                  err = 'Please enter a valid email address';
                                }

                                return err;
                              },
                              onChanged: (val) =>
                                  _formKey.currentState!.validate(),
                              onSaved: (val) => _enteredEmail = val!,
                            ),
                          TextFormField(
                            decoration: InputDecoration(labelText: 'Username'),
                            enableSuggestions: false,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (val) {
                              var err = null;
                              if (val == null ||
                                  val.isEmpty ||
                                  val.trim().length < 4) {
                                err =
                                    'Please enter a valid username, at least 4 characters';
                              }

                              return err;
                            },
                            onChanged: (val) =>
                                _formKey.currentState!.validate(),
                            onSaved: (val) => _enteredUsername = val!,
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                                labelText: 'Password',
                                suffixIcon: IconButton(
                                  icon: Icon(is_obscure
                                      ? Icons.remove_red_eye
                                      : Icons.visibility_off),
                                  onPressed: () {
                                    setState(() {
                                      is_obscure = !is_obscure;
                                    });
                                  },
                                )),
                            obscureText: is_obscure,
                            validator: (val) {
                              var err = null;
                              if (val == null ||
                                  val.isEmpty ||
                                  val.trim().length < 6) {
                                err =
                                    'Password must be at least 6 characters long';
                              }
                              return err;
                            },
                            onChanged: (val) {
                              _formKey.currentState!.validate();
                              setState(() {
                                tempPass = val;
                              });
                            },
                            onSaved: (val) => _enteredPassword = val!,
                          ),
                          if (!_is_login)
                            TextFormField(
                              decoration: InputDecoration(
                                  labelText: 'Type password again',
                                  suffixIcon: IconButton(
                                    icon: Icon(is_obscure2
                                        ? Icons.remove_red_eye
                                        : Icons.visibility_off),
                                    onPressed: () {
                                      setState(() {
                                        is_obscure2 = !is_obscure2;
                                      });
                                    },
                                  )),
                              obscureText: is_obscure2,
                              validator: (val) {
                                var err = null;
                                print(tempPass);
                                if (val == null ||
                                    val.isEmpty ||
                                    val.trim().length < 6) {
                                  err =
                                      'Password must be at least 6 characters long';
                                } else if (val != tempPass) {
                                  err = "same as password field";
                                }

                                return err;
                              },
                              onChanged: (val) =>
                                  _formKey.currentState!.validate(),
                              onSaved: (val) => _enteredRePassword = val!,
                            ),
                          SizedBox(
                            height: 12,
                          ),
                          if (_isAuthenticating) CircularProgressIndicator(),
                          ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                            ),
                            child: Text(_is_login ? 'Login' : 'Signup'),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _is_login = !_is_login;
                              });
                            },
                            child: Text(_is_login
                                ? 'Create an account'
                                : 'I already have an account. Login'),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
