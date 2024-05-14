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
            _buildUserList(),
            _buildReviews(), // This can be a blank screen or any other content for reviews
          ],
        ),
      ),
    );
  }

  Widget _buildUserList() {
    return ListView.builder(
      itemCount: _users.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text('${_users[index]['firstName']} ${_users[index]['lastName']}'),
          subtitle: Text(_users[index]['email']),
        );
      },
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

}
