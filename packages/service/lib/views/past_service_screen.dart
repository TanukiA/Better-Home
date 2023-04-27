import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:service/controllers/service_controller.dart';

class PastServiceScreen extends StatefulWidget {
  const PastServiceScreen({Key? key, required this.controller})
      : super(key: key);
  final ServiceController controller;

  @override
  StateMVC<PastServiceScreen> createState() => _PastServiceScreenState();
}

class _PastServiceScreenState extends StateMVC<PastServiceScreen> {
  List<QueryDocumentSnapshot> servicesDoc = [];

  @override
  initState() {
    getServicesData();
    setState(() {});
    super.initState();
  }

  void getServicesData() async {}

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
