import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _reviews = [];
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _fetchReviews();
  }

  Future<void> _fetchUsers() async {
    var url = Uri.parse('https://localhost:7045/v2/User/all');
    try {
      var response = await http.get(url, headers: {"accept": "application/json"});
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _users = List<Map<String, dynamic>>.from(data);
        });
      } else {
        throw Exception('Failed to fetch users');
      }
    } catch (e) {
      print('Error fetching users: $e');
    }
  }

  Future<void> _fetchReviews() async {
    var url = Uri.parse('https://localhost:7045/v2/Feedback');
    try {
      var response = await http.get(url, headers: {"accept": "application/json"});
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _reviews = List<Map<String, dynamic>>.from(data);
        });
      } else {
        throw Exception('Failed to fetch reviews');
      }
    } catch (e) {
      print('Error fetching reviews: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Admin Operations'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Users'),
              Tab(text: 'Reviews'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Column(
              children: [
                Expanded(child: _buildUserList()),
              ],
            ),
            _buildReviews(), // This can be a blank screen or any other content for reviews
          ],
        ),
      ),
    );
  }

  Widget _buildUserList() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _users.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text('${_users[index]['firstName']} ${_users[index]['lastName']}'),
                subtitle: Text(_users[index]['email']),
              );
            },
          ),
        ),
        SizedBox(height: 20), // Add space below the list
        ElevatedButton(
          onPressed: () => _showAddUserDialog(context),
          child: Text('Add User'),
        ),
        SizedBox(height: 150), // Add space below the button
      ],
    );
  }



  Widget _buildReviews() {
    return ListView.builder(
      itemCount: _reviews.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(_reviews[index]['subject']),
          subtitle: Text(_reviews[index]['message']),
        );
      },
    );
  }

  void _showAddUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New User'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _firstNameController,
                  decoration: InputDecoration(labelText: 'First Name'),
                ),
                TextField(
                  controller: _lastNameController,
                  decoration: InputDecoration(labelText: 'Last Name'),
                ),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'Password'),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => _addUser(context),
              child: Text('Add'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _addUser(BuildContext context) {
    String firstName = _firstNameController.text.trim();
    String lastName = _lastNameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text;

    if (firstName.isNotEmpty && lastName.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
      // Validate password: alphanumeric and at least 8 characters
      if (!_isPasswordValid(password)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password must be alphanumeric and have at least 8 characters.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Create payload for the new user
      var newUser = {
        "id": DateTime.now().millisecondsSinceEpoch.toString(), // Unique ID
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "password": password,
        "isAdmin": true,
      };

      // Send POST request to add new user
      _addNewUser(newUser);
      // Clear text fields
      _firstNameController.clear();
      _lastNameController.clear();
      _emailController.clear();
      _passwordController.clear();
      // Close dialog
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all fields.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool _isPasswordValid(String password) {
    // Password must be alphanumeric and have at least 8 characters
    return RegExp(r'^[a-zA-Z0-9]{8,}$').hasMatch(password);
  }

  void _addNewUser(Map<String, dynamic> newUser) async {
    var url = Uri.parse('https://localhost:7045/v2/User');
    try {
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(newUser),
      );
      if (response.statusCode == 200) {
        // User added successfully
        _fetchUsers(); // Refresh user list
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User added successfully.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Failed to add user: ${response.reasonPhrase}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding user: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}