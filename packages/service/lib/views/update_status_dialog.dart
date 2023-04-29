import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:service/controllers/service_controller.dart';
import 'package:service/views/technician_service_screen.dart';

class UpdateStatusDialog extends StatefulWidget {
  const UpdateStatusDialog({
    Key? key,
    required this.serviceDoc,
    required this.controller,
  }) : super(key: key);
  final QueryDocumentSnapshot serviceDoc;
  final ServiceController controller;

  @override
  StateMVC<UpdateStatusDialog> createState() => _UpdateStatusDialogState();
}

class _UpdateStatusDialogState extends StateMVC<UpdateStatusDialog> {
  String? _selectedStatus;

  final List<String> _statusOptions = [
    'Select new status',
    'In Progress',
    'Completed'
  ];

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AlertDialog(
        title: const Text("Update service status"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              items: _statusOptions
                  .map(
                    (status) => DropdownMenuItem<String>(
                      value: status,
                      child: Text(status),
                    ),
                  )
                  .toList(),
              onChanged: (selectedStatus) {
                setState(() {
                  _selectedStatus = selectedStatus;
                });
              },
              decoration: InputDecoration(
                labelText: 'Select new status',
                errorText: _selectedStatus == 'Select new status'
                    ? 'Please select a valid status'
                    : null,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            onPressed: () async {
              if (_selectedStatus == null ||
                  _selectedStatus == 'Select new status') {
                setState(() {
                  _selectedStatus = 'Select new status';
                });
              } else {
                await widget.controller.handleServiceStatusUpdate(
                    widget.serviceDoc.id, _selectedStatus!);

                if (mounted) {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TechnicianServiceScreen(),
                    ),
                  );
                }
              }
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }
}
