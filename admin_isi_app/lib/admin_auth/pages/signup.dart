import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:namer_app/admin_auth/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:namer_app/admin_auth/pages/login.dart';
import 'package:namer_app/global/toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;


class SignUp extends StatefulWidget {
  const SignUp({Key? key});

  @override
  State<SignUp> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUp> {
  final FirebaseAuthService _auth = FirebaseAuthService();

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  bool isSigningUp = false;
  File? _imageFile;
  bool _isObscure = true;




  Future<void> _pickImage() async {
    final  pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);;
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);;
      });
    }
  }


  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Register",
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text(
                        "Create admin account!",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D47A1),
                        ),
                      ),
                      Image.asset(
                        'assets/admin.png',
                        height: 200,
                        width: 200,
                        fit: BoxFit.cover,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: _pickImage,
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: Color(0xE8E2E2FF),
                              backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                              child: _imageFile == null ? Icon(Icons.add_a_photo, color: Color(0xFF0D47A1), size: 50) : null,
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            prefixIcon: Icon(
                                Icons.person, color: Color(0xFF0D47A1)),
                            border: InputBorder.none,
                          ),
                          style: TextStyle(color: Colors.black87),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Email Input Field
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(
                                Icons.mail, color: Color(0xFF0D47A1)),
                            border: InputBorder.none,
                          ),
                          style: TextStyle(color: Colors.black87),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Password Input Field
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: _passwordController,
                          obscureText: _isObscure,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(
                                Icons.lock, color: Color(0xFF0D47A1)),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _isObscure = !_isObscure;
                                });
                              },
                              icon: Icon(
                                _isObscure ? Icons.visibility : Icons
                                    .visibility_off,
                              ),
                            ),
                            border: InputBorder.none,
                          ),
                          style: TextStyle(color: Colors.black87),
                        ),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: 200,
                        child: GestureDetector(
                          onTap: () {
                            _signUp();
                          },
                          child: Container(
                            height: 45,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0D47A1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: isSigningUp
                                  ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                                  : const Text(
                                "Sign up",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Have an account?"),
                          const SizedBox(width: 5),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const Login()),
                              );
                            },
                            child: const Text(
                              "Login",
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                ),
            ),
        ),
    );
  }







  void _signUp() async {
    setState(() {
      isSigningUp = true;
    });

    String username = _usernameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    User? user =
    await _auth.signUpWithEmailAndPassword(email, password);

    if (user != null) {
      String? imageUrl;
      if (_imageFile != null) {
        final ref = firebase_storage.FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child(user.uid + '.jpg');
        await ref.putFile(_imageFile!);
        imageUrl = await ref.getDownloadURL();
      }

      await user.updateDisplayName(username);
      await user.updatePhotoURL(imageUrl);
    }
    setState(() {
      isSigningUp = false;
    });
    if (user != null) {
      showToast(message: "User is successfully created");
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
      );
    } else {
      showToast(message: "Missing auth credentials");
    }
  }
}
