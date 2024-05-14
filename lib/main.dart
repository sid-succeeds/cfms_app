import 'package:cfms_app/utils/LoadingOverlay.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:email_validator/email_validator.dart';

import 'UserListScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Review Form',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black),
        ),
      ),
      home: const ReviewForm(),
    );
  }
}

class ReviewForm extends StatefulWidget {
  const ReviewForm({super.key});

  @override
  _ReviewFormState createState() => _ReviewFormState();
}

class _ReviewFormState extends State<ReviewForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _selectedSubject = 'Suggestion';
  String _message = '';
  bool _isLoading = false;
  int _selectedIndex = 0;
  String _appBarTitle = 'Review Form';
  String _email = '';
  String _password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle),
      ),
      body: _selectedIndex == 0 ? _buildReviewForm() : _buildAdminLoginForm(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Capture',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings),
            label: 'Admin',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onTabSelected,
      ),
    );
  }

  Widget _buildReviewForm() {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Subject',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              DropdownButtonFormField<String>(
                value: _selectedSubject,
                onChanged: (String? value) {
                  setState(() {
                    _selectedSubject = value!;
                  });
                },
                items: ['Suggestion', 'Compliment', 'Bug', 'Feature Request']
                    .map((String subject) {
                  return DropdownMenuItem<String>(
                    value: subject,
                    child: Text(subject),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              const Text(
                'Message',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                maxLines: 5,
                maxLength: 256,
                decoration: const InputDecoration(
                  hintText: 'Enter your review here',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a message';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _message = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    _submitForm();
                  },
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Show loading overlay
      });

      var id = UniqueKey().toString();
      var submittedDate = DateTime.now().toIso8601String();

      var feedbackData = {
        "id": id,
        "subject": _selectedSubject,
        "message": _message,
        "submittedDate": submittedDate,
      };

      var url = Uri.parse('https://localhost:7045/v2/Feedback');

      try {
        var response = await http.post(
          url,
          headers: {
            "Content-Type": "application/json",
          },
          body: jsonEncode(feedbackData),
        );

        if (response.statusCode == 200) {
          _showToast("Feedback submitted successfully!");
        } else {
          _showToast(
              "Failed to submit feedback. Error: ${response.reasonPhrase}");
        }
      } catch (e) {
        _showToast("Error occurred while submitting feedback: $e");
      } finally {
        setState(() {
          _isLoading = false; // Hide loading overlay
        });
      }
    }
  }

  Widget _buildAdminLoginForm(){
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {
                  setState(() {
                    _email = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  } else if (!EmailValidator.validate(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                onChanged: (value) {
                  setState(() {
                    _password = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    _login(_email, _password);
                  },
                  child: const Text('Login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _login(String email, String password) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Show loading overlay
      });

      var url = Uri.parse(
          'https://localhost:7045/v2/User?email=${Uri.encodeComponent(email)}&password=${Uri.encodeComponent(password)}');

      try {
        var response = await http.get(
          url,
          headers: {
            "accept": "text/plain",
          },
        );

        if (response.statusCode == 200) {
          // Navigate to user list screen upon successful login
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UserListScreen()),
          );
        } else {
          _showToast("Login failed. Please check your credentials.");
        }
      } catch (e) {
        _showToast("Error occurred during login: $e");
      } finally {
        setState(() {
          _isLoading = false; // Hide loading overlay
        });
      }
    }
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.black.withOpacity(0.8),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
      _appBarTitle = index == 0 ? 'Review Form' : 'Admin Login';
    });
  }
}