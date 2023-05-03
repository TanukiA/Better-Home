import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:service/controllers/technician_controller.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({Key? key, required this.controller}) : super(key: key);
  final TechnicianController controller;

  @override
  StateMVC<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends StateMVC<ReviewScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>?> reviewsDoc = [];
  double avgStarQty = 0;

  @override
  initState() {
    setReviewData();
    super.initState();
  }

  Future<void> setReviewData() async {
    reviewsDoc = await widget.controller.retrieveReviews(context);
    print("review doc in screen: $reviewsDoc");
    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFE8E5D4),
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Customer Reviews",
          style: TextStyle(
            fontSize: 22,
            fontFamily: 'Roboto',
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromRGBO(152, 161, 127, 1),
        leading: const BackButton(
          color: Colors.black,
        ),
        iconTheme: const IconThemeData(
          size: 40,
        ),
      ),
      body: isLoading == true
          ? const Center(
              child: CircularProgressIndicator(
              color: Color.fromARGB(255, 51, 119, 54),
            ))
          : SingleChildScrollView(
              child: Column(
                children: [
                  if (reviewsDoc.isEmpty && isLoading == false)
                    const Center(
                        child: Text(
                      'No customer review yet',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ))
                  else
                    SizedBox(
                      height: size.height * 0.5,
                      child: ListView.builder(
                          itemCount: reviewsDoc.length,
                          itemBuilder: (context, index) {
                            final reviewDoc = reviewsDoc[index];

                            return Container(
                              width: double.infinity,
                              margin: const EdgeInsets.fromLTRB(22, 10, 22, 10),
                              padding: const EdgeInsets.all(22),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.grey,
                                    blurRadius: 3,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RatingBar.builder(
                                    initialRating:
                                        reviewDoc!['starQty'].toDouble(),
                                    minRating: 1,
                                    direction: Axis.horizontal,
                                    allowHalfRating: true,
                                    itemCount: 5,
                                    itemPadding: const EdgeInsets.symmetric(
                                        horizontal: 4.0),
                                    itemBuilder: (context, _) => const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                    onRatingUpdate: (rating) {},
                                    ignoreGestures: true,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    reviewDoc['reviewText'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                ],
                              ),
                            );
                          }),
                    ),
                ],
              ),
            ),
    );
  }
}
