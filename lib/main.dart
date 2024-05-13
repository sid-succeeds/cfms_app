import 'package:flutter/material.dart';

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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Form is valid, submit data
      // Here you can implement sending the review data to your backend or perform any other actions
      print('Subject: $_selectedSubject');
      print('Message: $_message');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Review Form'),
      ),
      body: Padding(
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
                  onPressed: _submitForm,
                  child: Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
