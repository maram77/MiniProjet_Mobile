import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:student_isi_app/student_auth/login.dart';
import 'package:student_isi_app/student_auth/subscribeCategories.dart';
import 'package:image_picker/image_picker.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isSigningUp = false;
  bool _isObscure = true;
  File? _selectedImage;

  Future<void> _selectImage() async {
    final pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
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
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text(
                "Create your account",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D47A1),
                ),
              ),
              // Displaying Home Image
              Image.asset(
                'assets/home.jpg',
                height: 250,
                width: 300,
                fit: BoxFit.cover,
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _selectImage,
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: Color(0xE8E2E2FF),
                      backgroundImage: _selectedImage != null ? FileImage(_selectedImage!) : null,
                      child: _selectedImage == null ? const Icon(Icons.camera_alt, size: 30) : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
              const SizedBox(height: 30),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.person, color: Color(0xFF0D47A1)),
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
                    prefixIcon: Icon(Icons.mail, color: Color(0xFF0D47A1)),
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
                    prefixIcon: Icon(Icons.lock, color: Color(0xFF0D47A1)),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _isObscure = !_isObscure;
                        });
                      },
                      icon: Icon(
                        _isObscure ? Icons.visibility : Icons.visibility_off,
                      ),
                    ),
                    border: InputBorder.none,
                  ),
                  style: TextStyle(color: Colors.black87),
                ),
              ),
              const SizedBox(height: 30),
              // Sign Up Button
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
                      child: _isSigningUp
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
              // Navigation to Login Page
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Have an account?"),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Login()),
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

  Future<void> _signUp() async {
    setState(() {
      _isSigningUp = true;
    });

    String username = _usernameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please fill out all the fields.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red),
          ),
          backgroundColor: Colors.white,
        ),
      );
      setState(() {
        _isSigningUp = false;
      });
      return;
    }

    try {
      String imageUrl = '';
      if (_selectedImage != null) {
        final storageRef = firebase_storage.FirebaseStorage.instance.ref().child('profile_images').child(username);
        await storageRef.putFile(_selectedImage!);
        imageUrl = await storageRef.getDownloadURL();
      }

      // Store user data in Firestore
      DocumentReference newUserRef = await _firestore.collection('students').add({
        'username': username,
        'email': email,
        'password': password,
        'categories': [],
        'profileImage': imageUrl,
      });

      // Navigate to subscription page to select categories
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SubscriptionPage(userRef: newUserRef)),
      );
    } catch (e) {
      print("Error signing up: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error signing up: $e'),
        ),
      );
    } finally {
      setState(() {
        _isSigningUp = false;
      });
    }
  }
}
