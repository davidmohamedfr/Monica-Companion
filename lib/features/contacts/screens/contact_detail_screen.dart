import 'package:flutter/material.dart';
import 'package:monica_companion/features/contacts/models/contact_model.dart';

class ContactDetailScreen extends StatefulWidget {
  const ContactDetailScreen({required this.contact, super.key});

  final Contact contact;

  @override
  State<ContactDetailScreen> createState() => _ContactDetailScreenState();
}

class _ContactDetailScreenState extends State<ContactDetailScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.contact.name)),
    body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Contact details for ${widget.contact.name}'),
          ],
        ),
      ),
    ),
  );
}
