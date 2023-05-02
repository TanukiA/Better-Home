import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class MessageDB extends ChangeNotifier {
  final FirebaseDatabase _realtimeDB = FirebaseDatabase.instance;
}
