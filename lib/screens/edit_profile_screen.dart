import 'package:flutter/material.dart';
import 'package:instagram_clone/models/user_model.dart';
import 'package:instagram_clone/services/database_service.dart';

class EditProfileScreen extends StatefulWidget {
  final User user;

  EditProfileScreen({this.user});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name;
  String _bio;

  _submit() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      String _profileImageUrl = '';
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
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: EdgeInsets.all(30.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  CircleAvatar(
                    radius: 60.0,
                  ),
                  FlatButton(
                    onPressed: () => print('Edit Profile Image'),
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
        ),
      ),
    );
  }
}
