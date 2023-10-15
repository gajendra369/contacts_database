import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'databasehelper.dart'; // Import your database helper class
import 'package:flutter_contacts/flutter_contacts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize your database helper class
  final dbHelper = DatabaseHelper();

  // Open the database
  final database = await dbHelper.database;

  runApp(MyApp(database: database));
}

class MyApp extends StatefulWidget {

  final Database database; // Receive the database instance

  MyApp({required this.database});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Contact> contacts = [];

  @override
  void initState() {
    super.initState();

    // Fetch contacts from the database
    _fetchContacts();
  }

  Future<void> _fetchContacts() async {
    if (await FlutterContacts.requestPermission()) {
      // Get all contacts (lightly fetched)
      final fetchedContacts = await FlutterContacts.getContacts();

      setState(() {
        contacts = fetchedContacts;
      });
      DatabaseHelper().putContact(contacts[0]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('My Contacts App'),
        ),
        body: ListView.builder(
          itemCount: contacts.length,
          itemBuilder: (context, index) {
            final contact = contacts[index];
            return ListTile(
              title: Text(contact.displayName),
              // You can display other contact details here.
            );
          },
        ),
      ),
    );
  }
}
