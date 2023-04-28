import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:service/controllers/service_controller.dart';
import 'package:service/views/customer_service_screen.dart';

class ServiceReviewDialog extends StatefulWidget {
  const ServiceReviewDialog(
      {Key? key, required this.serviceDoc, required this.controller})
      : super(key: key);
  final QueryDocumentSnapshot serviceDoc;
  final ServiceController controller;

  @override
  StateMVC<ServiceReviewDialog> createState() => _ServiceReviewDialogState();
}

class _ServiceReviewDialogState extends StateMVC<ServiceReviewDialog> {
  double _starQty = 5.0;
  final _reviewController = TextEditingController();

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AlertDialog(
        title: const Text("Rate Service"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 15),
            RatingBar.builder(
              initialRating: _starQty,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (starQty) {
                setState(() {
                  _starQty = starQty;
                });
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _reviewController,
              decoration: const InputDecoration(
                hintText: "Enter your review (optional)",
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
              maxLength: 300,
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
              await widget.controller.submitReview(
                  _starQty, _reviewController.text, widget.serviceDoc);
              if (mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const CustomerServiceScreen(initialIndex: 1),
                  ),
                );
              }
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }
}
