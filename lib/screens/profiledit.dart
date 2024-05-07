import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

import 'package:loginapp/models/Users.dart';
import 'package:localstorage/localstorage.dart';
import 'package:loginapp/screens/home.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.profile});
  final Profile profile;
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  bool is_obscure = true;
  bool is_obscure2 = true; //untuk repassword
  final _formKey = GlobalKey<FormState>();
  final storage = new LocalStorage('my_data.json');
  var tempPass = '';
  var _enteredEmail = '';
  var _enteredPassword = '';
  var _enteredOldPassword = '';
  var _enteredName = '';
  var _enteredAddress = '';
  var _enteredPhone = '';
  var _enteredGender = '';
  var baseurl = 'https://2fbf7z4v-80.asse.devtunnels.ms/myloginapp-api';
  var host = '2fbf7z4v-80.asse.devtunnels.ms';
  File? _pickedImage;
  String? token;
  bool _isSending = false;
  FocusNode nameFocusNode = FocusNode();
  FocusNode phoneFocusNode = FocusNode();
  FocusNode addressFocusNode = FocusNode();

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _enteredGender = widget.profile.kelamin;
    token = storage.getItem('token');

    nameFocusNode.addListener(() {
      print('IS Name FOCUS: ${nameFocusNode.hasFocus}');

      if (!nameFocusNode.hasFocus)
        _enteredName = nameController.text.toString();
    });
    nameController.text = widget.profile.nama;

    phoneFocusNode.addListener(() {
      print('IS Phone FOCUS: ${phoneFocusNode.hasFocus}');
      if (!phoneFocusNode.hasFocus)
        _enteredPhone = phoneController.text.toString();
    });
    phoneController.text = widget.profile.nohp;

    addressFocusNode.addListener(() {
      print('IS Address FOCUS: ${addressFocusNode.hasFocus}');
      if (!addressFocusNode.hasFocus)
        _enteredAddress = addressController.text.toString();
    });
    addressController.text = widget.profile.alamat;
  }

  void _pickImage() async {
    print("pick image");
    final pickedImage = await ImagePicker().pickImage(
        source: ImageSource.gallery, imageQuality: 80, maxWidth: 200);
    if (pickedImage == null) return;
    setState(() {
      _pickedImage = File(pickedImage.path);
    });
  }

  void _submit() async {
    final _isValid = _formKey.currentState!.validate();
    if (!_isValid) return;
    _formKey.currentState!.save();

    ScaffoldMessenger.of(context).clearSnackBars();
    setState(() {
      _isSending = true;
    });
    Uri url = Uri.https(
        host, '/myloginapp-api/user/saveprofile/${widget.profile.username}');
    var request = http.MultipartRequest("POST", url);
    request.fields['nama_lengkap'] = _enteredName;
    request.fields['nohp'] = _enteredPhone;
    request.fields['alamat'] = _enteredAddress;
    request.fields['jenis_kelamin'] = _enteredGender;
    request.headers['Authorization'] = "Bearer ${token}";

    if (_enteredPassword.isNotEmpty && _enteredOldPassword.isNotEmpty) {
      request.fields['password'] = _enteredPassword;
      request.fields['oldpassword'] = _enteredOldPassword;
    }
    if (_pickedImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath('photo', _pickedImage!.path),
      );
    }

    var response = await request.send();
    final respStr = await response.stream.bytesToString();
    print("RESPONSE: $respStr");
    Map<String, dynamic> respJson = jsonDecode(respStr);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(respJson['message']),
      ),
    );
    if (respJson['type'] != 'Error') {
      Navigator.pop(context);
    }
    setState(() {
      _isSending = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    print("Kelamin ${_enteredGender}");
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 50,
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(
                        top: 30, bottom: 20, right: 20, left: 20),
                    child: _pickedImage != null
                        ? CircleAvatar(
                            radius: 70,
                            backgroundColor: Colors.grey,
                            foregroundImage: FileImage(_pickedImage!),
                          )
                        : CircleAvatar(
                            radius: 70,
                            backgroundColor: Colors.grey,
                            foregroundImage: NetworkImage(
                                "$baseurl/user/photo/${widget.profile?.photo}"),
                          ),
                  ),
                  Positioned(
                    top: 140,
                    child: IconButton(
                      onPressed: _pickImage,
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            Color.fromARGB(255, 160, 214, 239)),
                      ),
                      icon: Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
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
                          TextFormField(
                            controller: TextEditingController(
                                text: widget.profile.email),
                            decoration:
                                InputDecoration(labelText: 'Email Adress'),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            enabled: false,
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
                            focusNode: nameFocusNode,
                            decoration:
                                InputDecoration(labelText: 'Nama Lengkap'),
                            controller: nameController,
                            enableSuggestions: false,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (val) {
                              var err = null;
                              if (val == null ||
                                  val.isEmpty ||
                                  val.trim().length < 4) {
                                err =
                                    'Please enter a valid Name, at least 4 characters';
                              }

                              return err;
                            },
                            onChanged: (val) =>
                                _formKey.currentState!.validate(),
                            onSaved: (val) => _enteredName = val!,
                          ),
                          TextFormField(
                            decoration: InputDecoration(labelText: 'Nomor Hp'),
                            controller: phoneController,
                            focusNode: phoneFocusNode,
                            enableSuggestions: false,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            keyboardType: TextInputType.phone,
                            validator: (val) {
                              var err = null;
                              if (val == null ||
                                  val.isEmpty ||
                                  val.trim().length < 10) {
                                err =
                                    'Please enter a valid Phone Number, at least 10 characters';
                              }

                              return err;
                            },
                            onChanged: (val) =>
                                _formKey.currentState!.validate(),
                            onSaved: (val) => _enteredPhone = val!,
                          ),
                          TextFormField(
                            decoration: InputDecoration(labelText: 'Alamat'),
                            controller: addressController,
                            focusNode: addressFocusNode,
                            enableSuggestions: false,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            maxLines: 3,
                            validator: (val) {
                              var err = null;
                              if (val == null ||
                                  val.isEmpty ||
                                  val.trim().length < 10) {
                                err =
                                    'Please enter a valid Address, at least 10 characters';
                              }

                              return err;
                            },
                            onChanged: (val) =>
                                _formKey.currentState!.validate(),
                            onSaved: (val) => _enteredAddress = val!,
                          ),
                          Column(
                            children: [
                              Text("Jenis Kelamin"),
                              RadioListTile(
                                title: Text('Laki-laki'),
                                value: "L",
                                onChanged: (value) {
                                  setState(() {
                                    _enteredGender = value.toString();
                                  });
                                },
                                groupValue: _enteredGender,
                              ),
                              RadioListTile(
                                title: Text('Perempuan'),
                                value: "P",
                                onChanged: (value) {
                                  setState(() {
                                    _enteredGender = value.toString();
                                  });
                                },
                                groupValue: _enteredGender,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 50,
                          ),
                          Text(
                            "Isi dibawah ini hanya jika ingin mengganti password",
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                                labelText: 'Current Password',
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
                              if (val != null &&
                                  val.isNotEmpty &&
                                  val.trim().length < 6) {
                                err =
                                    'Password must be at least 6 characters long';
                              }

                              return err;
                            },
                            onChanged: (val) =>
                                _formKey.currentState!.validate(),
                            onSaved: (val) => _enteredOldPassword = val!,
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
                              if (val != null &&
                                  val.isNotEmpty &&
                                  val.trim().length < 6) {
                                err =
                                    'Password must be at least 6 characters long';
                              }
                              return err;
                            },
                            onChanged: (val) =>
                                _formKey.currentState!.validate(),
                            onSaved: (val) => _enteredPassword = val!,
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          if (_isSending) CircularProgressIndicator(),
                          ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                            ),
                            child: Text('Save'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Cancel'),
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
