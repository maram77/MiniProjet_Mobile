import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnnouncementsPage extends StatefulWidget {
  @override
  _AnnouncementsPageState createState() => _AnnouncementsPageState();
}

class _AnnouncementsPageState extends State<AnnouncementsPage> {
  late List<Map<String, dynamic>> _announcements = [];
  late List<Map<String, dynamic>> _filteredAnnouncements = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _fetchUserCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserCategories() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String userEmail = prefs.getString('email') ?? '';

      // Query Firestore to find user document using the email
      QuerySnapshot userSnapshot = await _firestore
          .collection('students')
          .where('email', isEqualTo: userEmail)
          .get();

      // Extract the categories list from the user document
      if (userSnapshot.docs.isNotEmpty) {
        List<dynamic> userCategories = userSnapshot.docs.first['categories'];
        await _fetchAnnouncements(userCategories);
      }
    } catch (error) {
      print('Error fetching user categories: $error');
    }
  }

  Future<void> _fetchAnnouncements(List<dynamic> userCategories) async {
    try {
      QuerySnapshot announcementsSnapshot = await _firestore
          .collection('posts')
          .where('categories', arrayContainsAny: userCategories)
          .get();

      _announcements = announcementsSnapshot.docs.map((doc) {
        return doc.data() as Map<String, dynamic>;
      }).toList();

      _filteredAnnouncements = List.from(_announcements);

      setState(() {});

    } catch (error) {
      print('Error fetching announcements: $error');
    }
  }

  void _filterAnnouncements(String query) {
    setState(() {
      if (query.isNotEmpty) {
        _filteredAnnouncements = _announcements.where((announcement) {
          return announcement['title'].toString().toLowerCase().contains(query.toLowerCase()) ||
              announcement['description'].toString().toLowerCase().contains(query.toLowerCase());
        }).toList();
      } else {
        _filteredAnnouncements = List.from(_announcements);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(color: Colors.black87),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        hintText: 'Search...',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                      ),
                      onChanged: _filterAnnouncements,
                    ),
                  ),
                ),
                Expanded(
                  child: _buildAnnouncementsList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementsList() {
    if (_filteredAnnouncements.isEmpty) {
      return const Center(child: Text('No announcements available.'));
    } else {
      return ListView.builder(
        itemCount: _filteredAnnouncements.length,
        itemBuilder: (context, index) {
          Map<String, dynamic> announcement = _filteredAnnouncements[index];

          return GestureDetector(
            onTap: () => _showAnnouncementDetailsDialog(context, announcement),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Card(
                elevation: 2.0,
                child: ListTile(
                  title: Text(announcement['title'] as String),
                  subtitle: Text(announcement['description'] as String),
                ),
              ),
            ),
          );
        },
      );
    }
  }

  void _showAnnouncementDetailsDialog(BuildContext context, Map<String, dynamic> announcement) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(announcement['title'] as String),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                (announcement['image'] as String?)?.isNotEmpty ?? false
                    ? Image.network(
                  announcement['image'] as String,
                  fit: BoxFit.cover,
                )
                    : Text('No image available'),
                const SizedBox(height: 10),
                Text('Description: ${announcement['description']}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
