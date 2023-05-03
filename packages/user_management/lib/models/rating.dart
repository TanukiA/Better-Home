import 'package:firebase_data/models/database.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class Rating extends ModelMVC {
  List<Map<String, dynamic>?> _reviewData = [];
  double _avgStarQty = 0.0;

  List<Map<String, dynamic>?> get reviewData => _reviewData;
  double get avgStarQty => _avgStarQty;

  Future<void> getReviewsForTechnician(String technicianID) async {
    Database firestore = Database();
    _reviewData = await firestore.readReviewsForTechnician(technicianID);
    print("Review Data: $_reviewData");
    if (reviewData.isNotEmpty) {
      calculateAvgRating();
    }
  }

  void calculateAvgRating() {
    final List allStarQtys = reviewData
        .where((review) => review != null && review.containsKey('starQty'))
        .map((review) => review!['starQty'].toDouble())
        .toList();

    final double sum = allStarQtys.reduce((a, b) => a + b);
    _avgStarQty = sum / allStarQtys.length;
    print("Average star: $_avgStarQty");
  }
}
