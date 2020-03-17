import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/models/user_model.dart';
import 'package:instagram_clone/services/database_service.dart';
import 'package:instagram_clone/services/storage_service.dart';

class EditProfileScreen extends StatefulWidget {
  final User user;

  EditProfileScreen({this.user});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  File _profileImage;
  String _name;
  String _bio;
  bool _isLoading = false;

  _handleImageFromGallery() async {
    File imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (imageFile != null) {
      setState(() {
        _profileImage = imageFile;
      });
    }
  }

  _displayProfileImage() {
    //No new profile image
    if (_profileImage == null) {
      if (widget.user.profileImageUrl.isEmpty) {
        //no profile image exist
        return AssetImage('assets/images/user_placeholder.jpg');
      } else {
        return CachedNetworkImageProvider(widget.user.profileImageUrl);
      }
    } else {
      // new profile image selected
      return FileImage(_profileImage);
    }
  }

  _submit() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      setState(() {
        _isLoading = true;
      });

      String _profileImageUrl = '';

      if (_profileImage == null) {
        _profileImageUrl = widget.user.profileImageUrl;
      } else {
        _profileImageUrl = await StorageService.uploadUserProfileImage(
          widget.user.profileImageUrl,
          _profileImage,
        );
      }

      // Logging in the user w/ Firebase
      //AuthService.signUpUser(context, _name, _email, _password);
      User user = User(
        id: widget.user.id,
        name: _name,
        profileImageUrl: _profileImageUrl,
        bio: _bio,
      );
      // Update DB
      DatabaseService.updateUser(user);

      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _name = widget.user.name;
    _bio = widget.user.bio;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Center(
          child: Text(
            'Edit Profile',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: ListView(
          children: <Widget>[
            _isLoading
                ? LinearProgressIndicator(
                    backgroundColor: Colors.blue[200],
                    valueColor: AlwaysStoppedAnimation(Colors.blue),
                  )
                : SizedBox.shrink(),
                
                Padding(
                    padding: EdgeInsets.all(30.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          CircleAvatar(
                            radius: 60.0,
                            backgroundColor: Colors.grey,
                            backgroundImage: _displayProfileImage(),
                          ),
                          FlatButton(
                            onPressed: _handleImageFromGallery,
                            color: Colors.blue,
                            textColor: Colors.white,
                            child: Text(
                              'Change Profile Image',
                              style: TextStyle(
                                fontSize: 18.0,
                              ),
                            ),
                          ),
                          TextFormField(
                            initialValue: _name,
                            style: TextStyle(fontSize: 16.0),
                            decoration: InputDecoration(
                              icon: Icon(
                                Icons.person,
                                size: 30.0,
                              ),
                              labelText: 'Name',
                            ),
                            validator: (input) => input.trim().length < 1
                                ? 'Please enter a valid name'
                                : null,
                            onSaved: (input) => _name = input,
                          ),
                          TextFormField(
                            initialValue: _bio,
                            style: TextStyle(fontSize: 16.0),
                            decoration: InputDecoration(
                              icon: Icon(
                                Icons.book,
                                size: 30.0,
                              ),
                              labelText: 'Bio',
                            ),
                            validator: (input) => input.trim().length > 150
                                ? 'Please enter a less bio'
                                : null,
                            onSaved: (input) => _bio = input,
                          ),
                          Container(
                            margin: EdgeInsets.all(40.0),
                            height: 40.0,
                            width: 250.0,
                            child: FlatButton(
                              onPressed: _submit,
                              color: Colors.blue,
                              textColor: Colors.white,
                              child: Text(
                                'Save changes',
                                style: TextStyle(
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
