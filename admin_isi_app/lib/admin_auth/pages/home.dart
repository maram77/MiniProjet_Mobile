import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:namer_app/pages/categories.dart';
import 'package:namer_app/global/toast.dart';
import 'package:namer_app/pages/formList.dart';
import 'package:namer_app/pages/posts.dart';
import '../../pages/Forms.dart';



class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomePageState();
}

class _HomePageState extends State<Home> {
  int _selectedIndex = 0;
  late User _user;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser!;
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
          "Admin",
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0D47A1),
          ),
        ),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: FutureBuilder<User?>(
          future: FirebaseAuth.instance.authStateChanges().first,
          builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Center(child: Text('Error loading user data'));
            } else if (snapshot.hasData && snapshot.data != null) {
              User user = snapshot.data!;
              String displayName = user.displayName ?? "User Name";
              String email = user.email ?? "user@example.com";
              String? photoURL = user.photoURL;

              return ListView(
                children: <Widget>[
                  UserAccountsDrawerHeader(
                    accountName: Text(
                      displayName,
                      style: TextStyle(color: Colors.white),
                    ),
                    accountEmail: Text(
                      email,
                      style: TextStyle(color: Colors.white),
                    ),
                    decoration: BoxDecoration(
                      color: Color(0xFF0D47A1)
                    ),
                    currentAccountPicture: CircleAvatar(
                      backgroundColor: Colors.white,
                      backgroundImage: photoURL != null ? NetworkImage(photoURL) : null,
                      child: photoURL == null ? Icon(Icons.person, color: Colors.blue) : null,
                    ),
                  ),
                  ListTile(
                    title: Text('Categories'),
                    leading: Icon(Icons.category, color: Color(0xFF0D47A1)),
                    onTap: () {
                      Navigator.pop(context);
                       _onItemTapped(0);
                    },
                  ),
                  ListTile(
                    title: Text('Posts'),
                    leading: Icon(Icons.message, color: Color(0xFF0D47A1)),
                    onTap: () {
                      Navigator.pop(context);
                      _onItemTapped(1);
                    },
                  ),
                  ListTile(
                    title: Text('Forms'),
                    leading: Icon(Icons.inbox, color: Color(0xFF0D47A1)),
                    onTap: () {
                      Navigator.pop(context);
                      _onItemTapped(2);
                    },
                  ),
                  ListTile(
                    title: Text('Form list'),
                    leading: Icon(Icons.inbox, color:  Color(0xFF0D47A1)),
                    onTap: () {
                      Navigator.pop(context);
                      _onItemTapped(3);
                    },
                  ),
                  ListTile(
                    title: Text('Sign Out'),
                    leading: Icon(Icons.exit_to_app, color:  Color(0xFF0D47A1)),
                    onTap: () {
                      FirebaseAuth.instance.signOut();
                      Navigator.pushNamed(context, "/login");
                      showToast(message: "Successfully signed out");
                    },
                  ),
                ],
              );
            } else {
              return Center(child: Text("No user data available"));
            }
          },
        ),
      ),
      body: _buildPage(),
    );
  }

  Widget _buildPage() {
    switch (_selectedIndex) {
      case 0:
        return CategoriesPage();
      case 1:
        return PostsPage();
      case 2:
        return FormBuilder();
      case 3:
        return FormListPage();
      default:
        throw UnimplementedError('no widget for $_selectedIndex');
    }
  }


}

class FormsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: const Center(
        child: Text('Forms Page'),
      ),
    );
  }
}