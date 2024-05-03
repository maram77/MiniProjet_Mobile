import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_isi_app/Announcements.dart';
import 'package:student_isi_app/Forms.dart';
import 'package:student_isi_app/global/toast.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<Home> {
  int _selectedIndex = 0;
  late String _displayName = '';
  late String _email = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  late String _profileImageUrl = '';

  void _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _displayName = prefs.getString('username') ?? 'User Name';
      _email = prefs.getString('email') ?? 'user@example.com';
      _profileImageUrl = prefs.getString('profileImage') ?? '';
    });
    print("Loaded profile image URL: $_profileImageUrl");
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Students",
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0D47A1),
          ),
        ),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xE8E2E2FF),
              ),
              accountName: Text(
                _displayName,
                style: const TextStyle(
                  color:  Color(0xFF0D47A1),
                  fontWeight: FontWeight.bold,
                ),
              ),
              accountEmail: Text(
                _email,
                style: const TextStyle(
                  color:  Color(0xFF0D47A1),
                  fontWeight: FontWeight.bold,
                ),
              ),
              currentAccountPicture: _profileImageUrl.isNotEmpty
                  ? CircleAvatar(
                backgroundImage: NetworkImage(_profileImageUrl),
              )
                  : const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  color: Colors.blue,
                ),
              ),
            ),
            SizedBox(height: 20), // Adding space
            ListTile(
              title: const Text('Announcements'),
              leading: const Icon(Icons.local_post_office, color: Color(0xFF0D47A1)),
              tileColor: Color(0xE8E2E2FF),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(0);
              },
            ),
            SizedBox(height: 10),
            ListTile(
              title: const Text('Forms'),
              leading: const Icon(Icons.assignment, color: Color(0xFF0D47A1)),
              tileColor: Color(0xE8E2E2FF),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(1);
              },
            ),
            SizedBox(height: 10),
            ListTile(
              title: const Text('Request Access'),
              leading: const Icon(Icons.request_page, color: Color(0xFF0D47A1)),
              tileColor: Color(0xE8E2E2FF),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(2);
              },
            ),
            SizedBox(height: 10),
            ListTile(
              title: const Text('Sign Out'),
              leading: const Icon(Icons.exit_to_app, color: Color(0xFF0D47A1)),
              tileColor: Color(0xE8E2E2FF),
              onTap: () {
                _signOut();
              },
            ),
          ],
        ),
      ),
      body: _buildPage(),
    );
  }

  Widget _buildPage() {
    switch (_selectedIndex) {
      case 0:
        return AnnouncementsPage();
      case 1:
        return FormListPage();
      case 2:
        return RequestAccessPage();
      default:
        throw UnimplementedError('no widget for $_selectedIndex');
    }
  }

  void showToast(BuildContext context, String message) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.5,
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.blue,
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      ),
    );
  }

  void _signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    showToast(context, "Successfully signed out");
    Navigator.pushNamed(context, "/login");
   // showToast(message: "Successfully signed out");
  }
}



class RequestAccessPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: const Center(
        child: Text('Request Access Page'),
      ),
    );
  }
}
