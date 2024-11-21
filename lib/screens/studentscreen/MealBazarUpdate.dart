import 'package:firebase_database/firebase_database.dart';

void listenToMealUpdates() {
  DatabaseReference mealRef = FirebaseDatabase.instance.ref().child('meal_menu');
  mealRef.onValue.listen((event) {
    if (event.snapshot.exists) {
      print('Updated Meal Data: ${event.snapshot.value}');
    } else {
      print('No meal data available');
    }
  });
}

void listenToBazarUpdates() {
  DatabaseReference bazarRef = FirebaseDatabase.instance.ref().child('bazar');
  bazarRef.onValue.listen((event) {
    if (event.snapshot.exists) {
      print('Updated Bazar Data: ${event.snapshot.value}');
    } else {
      print('No bazar data available');
    }
  });
}
