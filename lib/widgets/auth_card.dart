import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:go_park/provider/authentication_provider.dart';
import 'package:provider/provider.dart';

enum AuthMode { Signup, Signin }

class AuthCard extends StatefulWidget {
  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Signin;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
    'first_name': '',
    'last_name': '',
    'address': '',
    'credit_card_number': '',
    'security_code': '',
    'expiration_date': '',
    'card_holder': ''
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();

  void showErrorDialog(String errorMessage) {
    showDialog(
      barrierColor: Colors.white10,
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Color.fromRGBO(44, 62, 80, 1).withOpacity(1),
        title: const Text('An Error Occurred!'),
        titleTextStyle: TextStyle(color: Theme.of(context).primaryColor),
        content: Text(
          errorMessage,
          style: TextStyle(color: Color.fromRGBO(23, 32, 42, 1).withOpacity(1)),
        ),
        actions: [
          FlatButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Okay',
                  style: TextStyle(color: Theme.of(context).primaryColor)))
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });

    try {
      // Sign user in
      if (_authMode == AuthMode.Signin) {
        await Provider.of<AuthenticationProvider>(context, listen: false)
            .signIn(
          _authData['email'],
          _authData['password'],
        );
        // Sign user up
      } else {
        await Provider.of<AuthenticationProvider>(context, listen: false)
            .signUp(
          _authData['email'],
          _authData['password'],
          _authData['first_name'],
          _authData['last_name'],
          _authData['address'],
          _authData['card_holder'],
          _authData['security_code'],
          _authData['credit_card_number'],
          _authData['expiration_date'],
        );
      }
    } on HttpException catch (error) {
      var errorMessage = 'Authentication failed';
      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'This email address is already in use.';
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errorMessage = 'This is not a valid email address';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'This password is too weak.';
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'Could not find a user with that email.';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'Invalid password.';
      }
      showErrorDialog(errorMessage);
    } catch (error) {
      const errorMessage =
          'Could not authenticate you. Please try again later.';
      showErrorDialog(errorMessage);
    }
    setState(() {
      _isLoading = false;
    });
  }

//Submit Function>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

//Switch Authentication Function>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  void _switchAuthMode() {
    if (_authMode == AuthMode.Signin) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
    } else {
      setState(() {
        _authMode = AuthMode.Signin;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var colorProviderObj = Color.fromRGBO(44, 62, 80, 1).withOpacity(1);

    final isKeyboard = MediaQuery.of(context).viewInsets.bottom != 0;

    return Positioned(
      left: 0.0,
      right: 0.0,
      bottom: 0.0,
      child: Container(
        height: isKeyboard ? 670 : 530,
        decoration: BoxDecoration(
          color: Color.fromRGBO(44, 62, 80, 1).withOpacity(1),
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(50), topRight: Radius.circular(50)),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              blurRadius: 5.0,
              spreadRadius: 5,
              offset: Offset(0.7, 0.7),
            )
          ],
        ),
        child: ListView(
          scrollDirection: Axis.vertical,
          children: [
            Padding(
              padding: EdgeInsets.all(15),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  _authMode == AuthMode.Signin ? 'GoPark' : 'Get Started',
                  style: const TextStyle(
                      fontSize: 50,
                      color: Colors.white,
                      fontWeight: FontWeight.w900),
                ),
              ),
            ),

            // >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
            _authMode == AuthMode.Signin
                ?
                //SigIn....................................................................................................
                Container(
                    margin: EdgeInsets.all(12),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).primaryColor,
                                  blurRadius: 1.0,
                                  spreadRadius: 1,
                                  offset: const Offset(0.7, 0.7),
                                ),
                              ],
                              color:
                                  Color.fromRGBO(23, 32, 42, 1).withOpacity(1),
                              border: Border.all(
                                color: Theme.of(context).primaryColor,
                                width: 2,
                              ),
                              // color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(3.0),

                              //Signin Email TextField///////////////////////////////////////////////////////////

                              child: TextFormField(
                                validator: (value) {
                                  if (value.isEmpty || !value.contains('@')) {
                                    return 'Invalid email !';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _authData['email'] = value;
                                },
                                cursorColor: Theme.of(context).primaryColor,
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.only(
                                      left: 15, bottom: 11, top: 11, right: 15),
                                  hintText: 'Email:',
                                  hintStyle: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                keyboardType: TextInputType.emailAddress,
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 20,
                          ),
                          // Password>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

                          Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).primaryColor,
                                  blurRadius: 1.0,
                                  spreadRadius: 1,
                                  offset: const Offset(0.7, 0.7),
                                ),
                              ],
                              color:
                                  Color.fromRGBO(23, 32, 42, 1).withOpacity(1),
                              border: Border.all(
                                color: Theme.of(context).primaryColor,
                                width: 2,
                              ),
                              // color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: TextFormField(
                                validator: (value) {
                                  if (value.isEmpty || value.length < 5) {
                                    return 'Password  is too short!';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _authData['password'] = value;
                                },
                                cursorColor: Theme.of(context).primaryColor,
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.only(
                                      left: 15, bottom: 11, top: 11, right: 15),
                                  hintText: 'Password:',
                                  hintStyle: TextStyle(color: Colors.white),
                                ),
                                obscureText: true,
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 15,
                          ),

                          Align(
                            alignment: Alignment.topRight,
                            child: Text(
                              'Forgot password?',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                : //SignUp........................................................................................................
                Container(
                    margin: EdgeInsets.all(15),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          //First Name>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                          Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).primaryColor,
                                  blurRadius: 1.0,
                                  spreadRadius: 1,
                                  offset: const Offset(0.7, 0.7),
                                ),
                              ],
                              color:
                                  Color.fromRGBO(23, 32, 42, 1).withOpacity(1),
                              border: Border.all(
                                color: Theme.of(context).primaryColor,
                                width: 2,
                              ),
                              // color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: TextFormField(
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'The field is empty!';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _authData['first_name'] = value;
                                },
                                cursorColor: Theme.of(context).primaryColor,
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.only(
                                      left: 15, bottom: 11, top: 11, right: 15),
                                  hintText: 'First name:',
                                  hintStyle: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                keyboardType: TextInputType.emailAddress,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          //Last Name>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                          Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).primaryColor,
                                  blurRadius: 1.0,
                                  spreadRadius: 1,
                                  offset: const Offset(0.7, 0.7),
                                ),
                              ],
                              color:
                                  Color.fromRGBO(23, 32, 42, 1).withOpacity(1),
                              border: Border.all(
                                color: Theme.of(context).primaryColor,
                                width: 2,
                              ),
                              // color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: TextFormField(
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'The field is empty!';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _authData['last_name'] = value;
                                },
                                cursorColor: Theme.of(context).primaryColor,
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.only(
                                      left: 15, bottom: 11, top: 11, right: 15),
                                  hintText: 'Last name:',
                                  hintStyle: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),

                          //Emaill>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                          Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).primaryColor,
                                  blurRadius: 1.0,
                                  spreadRadius: 1,
                                  offset: const Offset(0.7, 0.7),
                                ),
                              ],
                              color: const Color.fromRGBO(23, 32, 42, 1)
                                  .withOpacity(1),
                              border: Border.all(
                                color: Theme.of(context).primaryColor,
                                width: 2,
                              ),
                              // color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: TextFormField(
                                validator: (value) {
                                  if (value.isEmpty || !value.contains('@')) {
                                    return 'Invalid email !';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _authData['email'] = value;
                                },
                                keyboardType: TextInputType.emailAddress,
                                cursorColor: Theme.of(context).primaryColor,
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.only(
                                      left: 15, bottom: 11, top: 11, right: 15),
                                  hintText: 'Email:',
                                  hintStyle: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          // Password>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                          Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).primaryColor,
                                  blurRadius: 1.0,
                                  spreadRadius: 1,
                                  offset: const Offset(0.7, 0.7),
                                ),
                              ],
                              color:
                                  Color.fromRGBO(23, 32, 42, 1).withOpacity(1),
                              border: Border.all(
                                color: Theme.of(context).primaryColor,
                                width: 2,
                              ),
                              // color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: TextFormField(
                                validator: (value) {
                                  if (value.isEmpty || value.length < 5) {
                                    return 'Password  is too short!';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _authData['password'] = value;
                                },
                                cursorColor: Theme.of(context).primaryColor,
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.only(
                                      left: 15, bottom: 11, top: 11, right: 15),
                                  hintText: 'Password:',
                                  hintStyle: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                obscureText: true,
                                controller: _passwordController,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          //Confirm Password>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                          Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).primaryColor,
                                  blurRadius: 1.0,
                                  spreadRadius: 1,
                                  offset: const Offset(0.7, 0.7),
                                ),
                              ],
                              color:
                                  Color.fromRGBO(23, 32, 42, 1).withOpacity(1),
                              border: Border.all(
                                color: Theme.of(context).primaryColor,
                                width: 2,
                              ),
                              // color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: TextFormField(
                                cursorColor: Theme.of(context).primaryColor,
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.only(
                                      left: 15, bottom: 11, top: 11, right: 15),
                                  hintText: 'Confirm password:',
                                  hintStyle: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                obscureText: true,
                                validator: (value) {
                                  if (value != _passwordController.text) {
                                    return 'Passwords do not match!';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),

                          //Address>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                          Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).primaryColor,
                                  blurRadius: 1.0,
                                  spreadRadius: 1,
                                  offset: const Offset(0.7, 0.7),
                                ),
                              ],
                              color:
                                  Color.fromRGBO(23, 32, 42, 1).withOpacity(1),
                              border: Border.all(
                                color: Theme.of(context).primaryColor,
                                width: 2,
                              ),
                              // color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: TextFormField(
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'The field is empty!';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _authData['address'] = value;
                                },
                                cursorColor: Theme.of(context).primaryColor,
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.only(
                                      left: 15, bottom: 11, top: 11, right: 15),
                                  hintText: 'Address:',
                                  hintStyle: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 50,
                          ),
                        ],

                        //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                      ),
                    ),
                  ),

            //Signin/Signup text and button ...............................................................
            Container(
              margin: EdgeInsets.all(15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Signin/Signup text>>>>>>>>>>>>>>>>
                  Text(
                    _authMode == AuthMode.Signin ? 'Sign In' : 'Sign Up',
                    style: TextStyle(
                        fontSize: 30,
                        color: Color.fromRGBO(44, 62, 80, 1).withOpacity(1),
                        fontWeight: FontWeight.w900),
                  ),

                  GestureDetector(
                    onTap: _submit,
                    child: _isLoading == false
                        ? CircleAvatar(
                            radius: 30.0,
                            backgroundImage:
                                const AssetImage('assets/images/right.png'),
                            backgroundColor: Theme.of(context).primaryColor,
                          )
                        : CircleAvatar(
                            radius: 30.0,
                            backgroundColor: Theme.of(context).primaryColor,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: const Color.fromRGBO(23, 32, 42, 1)
                                    .withOpacity(1),
                              ),
                            ),
                          ),
                  )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 0, bottom: 160),
              child: Row(children: [
                //The underlined Signup or Signin text

                FlatButton(
                  child: Text(
                    _authMode == AuthMode.Signin ? 'Sign Up' : 'Sign In',
                    style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Theme.of(context).primaryColor,
                        fontSize: 20),
                  ),
                  onPressed: _switchAuthMode,
                ),

                const SizedBox(
                  width: 0,
                ),
                Row(
                  children: [
                    //Facebook Image
                    FlatButton(
                        onPressed: ()async {

                          //validating the form and saving it


                          //url to send the post request to
                          final url = 'http://10.0.2.2:5000/name';

                          //sending a post request to the url
                          final response = await http.post(Uri.parse("http://10.0.2.2:5000/name"), body: json.encode({'name' : '10,7'}));

                        },
                    child:Container(
                        width: 45,
                        height: 45,



                        child: Image.asset('assets/images/facebook.png'))),
                    const SizedBox(
                      width: 25,
                    ),
                    // Google Image

                    FlatButton(

                      onPressed: ()async{ //url to send the get request to
                        final url = 'http://10.0.2.2:5000/name';

                        //getting data from the python server script and assigning it to response
                        final response = await http.get(Uri.parse('http://10.0.2.2:5000/name'));

                        //converting the fetched data from json to key value pair that can be displayed on the screen
                        final decoded = json.decode(response.body) as Map<String, dynamic>;

                        //changing the UI be reassigning the fetched data to final response


                        print(decoded['name']);},
                      child:
                    Container(

                        width: 45,
                        height: 45,
                        child: Image.asset('assets/images/google.png'))),
                  ],
                ),

                // const SizedBox(
                //     height: 250,
                //   ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
