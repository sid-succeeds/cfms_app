import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CRUD Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  String _response = '';
  bool _isLoading = false;

  // Base URL of your API
  static const String baseUrl = 'https://localhost:7045/api';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('$baseUrl/customer'));
      if (response.statusCode == 200) {
        setState(() {
          _response = response.body;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      _showErrorToast(error.toString());
    }
  }

  Future<void> _createCustomer(String firstName, String lastName, String email) async {
    // Validate input fields
    if (firstName.isEmpty) {
      _showErrorToast('Customer name cannot be empty');
      return;
    }

    // Email validation
    if (!_isValidEmail(email)) {
      _showErrorToast('Invalid email');
      return;
    }

    // Generate a unique ID
    String customerId = Uuid().v4(); // Using version 4 UUID

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/customer'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'id': customerId,
          'firstName': firstName,
          'lastName': lastName, // Provide value for LastName if available
          'email': email, // Assuming email is entered in the text field
        }),
      );

      if (response.statusCode == 201) {
        _controller.clear();
        _fetchData(); // Refresh data after creating a new record
        _showSuccessToast('Customer created successfully');
      } else {
        throw Exception('Failed to create customer');
      }
    } catch (error) {
      _showErrorToast(error.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  bool _isValidEmail(String email) {
    // Regular expression for email validation
    final RegExp emailRegex = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
      caseSensitive: false,
      multiLine: false,
    );
    return emailRegex.hasMatch(email);
  }

  void _showErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  void _showSuccessToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CRUD Example'),
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(),
      )
          : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ElevatedButton(
          onPressed: () => _showEditDialog(context), // Pass null to indicate it's for creating a new customer
          child: Text('Create Customer'),
          ),
          ElevatedButton(
            onPressed: _fetchData,
            child: Text('Fetch Data'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _response.length, // Adjust based on your response structure
              itemBuilder: (context, index) {
                // Check if index is within the bounds of the list
                if (index < _response.length) {
                  // Parse JSON response and build a ListTile for each record
                  final record = jsonDecode(_response)[index];
                  return GestureDetector(
                    onTap: () => _showEditDialog(context, record: record),
                    child: ListTile(
                      title: Text(record['firstName']),
                      subtitle: Text(record['email']),
                      // Customize the ListTile as needed
                    ),
                  );
                } else {
                  return SizedBox(); // Return an empty SizedBox if index is out of bounds
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // Function to show edit dialog
  // Function to show edit dialog
  void _showEditDialog(BuildContext context, {Map<String, dynamic>? record}) async {
    final TextEditingController firstNameController = TextEditingController(text: record != null ? record['firstName'] : '');
    final TextEditingController lastNameController = TextEditingController(text: record != null ? record['lastName'] : '');
    final TextEditingController emailController = TextEditingController(text: record != null ? record['email'] : '');

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(record != null ? 'Edit User Details' : 'Create New Customer'), // Adjust title based on whether it's editing or creating
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: firstNameController,
                decoration: InputDecoration(labelText: 'First Name'),
              ),
              TextField(
                controller: lastNameController,
                decoration: InputDecoration(labelText: 'Last Name'),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog without saving changes
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Save changes and update user details
                // You can call a function here to update user details
                if (record != null) {
                  _updateUserDetails(record['id'], firstNameController.text, lastNameController.text, emailController.text);
                } else {
                  _createCustomer(firstNameController.text, lastNameController.text, emailController.text);
                }
                Navigator.of(context).pop(); // Close the dialog after saving changes
              },
              child: Text(record != null ? 'Save' : 'Create'), // Adjust button label based on whether it's editing or creating
            ),
          ],
        );
      },
    );
  }


  void _updateUserDetails(String userId, String newFirstName, String newLastName, String newEmail) async {
    setState(() {
      _isLoading = true; // Show loading indicator while updating user details
    });

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/customer/$userId'), // Assuming this is the endpoint to update user details
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'id': userId, // Provide the user ID to the backend
          'firstName': newFirstName,
          'lastName': newLastName,
          'email': newEmail,
          // Add other fields to update as needed
        }),
      );

      if (response.statusCode == 200) {
        _fetchData(); // Refresh data after updating user details
        _showSuccessToast('User details updated successfully');
      } else {
        throw Exception('Failed to update user details');
      }
    } catch (error) {
      _showErrorToast(error.toString());
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator after updating user details
      });
    }
  }


}
