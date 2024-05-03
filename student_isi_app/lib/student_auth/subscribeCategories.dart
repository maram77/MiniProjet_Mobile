import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SubscriptionPage extends StatefulWidget {
  final DocumentReference userRef;

  const SubscriptionPage({Key? key, required this.userRef}) : super(key: key);

  @override
  _SubscriptionPageState createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<String> _selectedCategories = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Select categories",
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0D47A1),
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('categories').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              List<DocumentSnapshot> documents = snapshot.data!.docs;
              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  String category = documents[index]['name'];
                  bool isSelected = _selectedCategories.contains(category);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedCategories.remove(category);
                        } else {
                          _selectedCategories.add(category);
                        }
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: 8.0),
                      decoration: BoxDecoration(
                        color: Color(0xE8E2E2FF), // Background color
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: ListTile(
                        title: Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: Text(
                            category,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        trailing: isSelected ? Icon(Icons.check) : null,
                      ),
                    ),
                  );
                },
              );
            },
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: Image.asset(
              'assets/category.jpg',
              width: 400,
              height: 400,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _saveCategories();
        },
        label: Text('Subscribe'),
        icon: Icon(Icons.check),
      ),
    );
  }

  Future<void> _saveCategories() async {
    try {
      await widget.userRef.update({'categories': _selectedCategories});
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      print("Error saving categories: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving categories: $e'),
        ),
      );
    }
  }
}
