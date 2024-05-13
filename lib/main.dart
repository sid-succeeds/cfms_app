import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'utils/LoadingOverlay.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Review Form',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: TextTheme(
          bodyText1: TextStyle(color: Colors.black),
          bodyText2: TextStyle(color: Colors.black),
        ),
      ),
      home: ReviewForm(),
    );
  }
}

class ReviewForm extends StatefulWidget {
  @override
  _ReviewFormState createState() => _ReviewFormState();
}

class _ReviewFormState extends State<ReviewForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _selectedSubject = 'Suggestion';
  String _message = '';
  bool _isLoading = false;
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Review Form'),
      ),
      body: _selectedIndex == 0 ? _buildReviewForm() : _buildAdminPage(),
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
              Text(
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
              SizedBox(height: 20),
              Text(
                'Message',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                maxLines: 5,
                maxLength: 256,
                decoration: InputDecoration(
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
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    _submitForm();
                  },
                  child: Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminPage() {
    return Center(
      child: Text(
        'Admin Page',
        style: TextStyle(fontSize: 24),
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
          _showToast("Failed to submit feedback. Error: ${response.reasonPhrase}");
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

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.black.withOpacity(0.8),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
