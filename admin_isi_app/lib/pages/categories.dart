import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CategoriesPage extends StatefulWidget {
  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  late TextEditingController _searchController;
  late Stream<QuerySnapshot> _categoriesStream;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _categoriesStream =
        FirebaseFirestore.instance.collection("categories").snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        title: TextField(
          controller: _searchController,
          style: TextStyle(color: Colors.black87),
          decoration: InputDecoration(
            icon: Icon(Icons.search),
            hintText: 'Search...',
            hintStyle: TextStyle(color: Colors.grey),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
          ),
          onChanged: _onSearchTextChanged,
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              _onSearchTextChanged('');
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _categoriesStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          User? user = FirebaseAuth.instance.currentUser;

          if (user == null) {
            return Center(
              child: Text('User not authenticated'),
            );
          }

          List<DocumentSnapshot> categories = snapshot.data!.docs;

          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (BuildContext context, int index) {
              var category = categories[index];

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: ListTile(
                    leading:
                        Icon(Icons.school),
                    title: Text(
                      category['name'],
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        _showDeleteConfirmationDialog(context, category);
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddCategoryDialog(context);
        },
        backgroundColor: Color(0xFF0D47A1),
        child: Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(),
    );
  }

  void _onSearchTextChanged(String text) {
    setState(() {
      _categoriesStream = FirebaseFirestore.instance
          .collection("categories")
          .where('name', isGreaterThanOrEqualTo: text)
          .where('name', isLessThan: text + 'z')
          .snapshots();
    });
  }

  void _showAddCategoryDialog(BuildContext context) {
    TextEditingController _categoryNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Add category',
            style: TextStyle(color: Color(0xFF0D47A1)),
          ),
          content: TextField(
            controller: _categoryNameController,
            decoration: InputDecoration(labelText: 'Category Name'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel',style: TextStyle(color: Color(0xFF0D47A1))),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add',style: TextStyle(color: Color(0xFF0D47A1))),
              onPressed: () {
                String categoryName = _categoryNameController.text;
                if (categoryName.isNotEmpty) {
                  FirebaseFirestore.instance.collection('categories').add({
                    'name': categoryName,
                  }).then((value) {
                    Navigator.of(context).pop();
                  }).catchError((error) {
                    print("Error adding category: $error");
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, DocumentSnapshot category) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirm delete',
            style: TextStyle(color: Color(0xFF0D47A1)),
          ),
          content: Text('Are you sure you want to delete ${category['name']}?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel',style: TextStyle(color: Color(0xFF0D47A1))),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete',style: TextStyle(color: Color(0xFF0D47A1))),
              onPressed: () {
                _deleteCategory(context, category);
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteCategory(BuildContext context, DocumentSnapshot category) {
    FirebaseFirestore.instance
        .collection("categories")
        .doc(category.id)
        .delete()
        .then((value) {
      Navigator.of(context).pop();
    }).catchError((error) {
      print("Error deleting category: $error");

    });
  }
}
