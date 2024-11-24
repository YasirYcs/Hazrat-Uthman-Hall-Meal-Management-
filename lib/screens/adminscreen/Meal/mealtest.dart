// import 'package:flutter/material.dart';
// import 'MealData.dart';
//
// class MealSummary extends StatefulWidget {
//   @override
//   _MealSummaryPageState createState() => _MealSummaryPageState();
// }
//
// class _MealSummaryPageState extends State<MealSummary> {
//   final MealData mealData = MealData();
//
//   @override
//   void initState() {
//     super.initState();
//     mealData.fetchMealData().then((_) {
//       setState(() {}); // Refresh the UI after data is fetched
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Meal Summary '),
//       ),
//       body: Column(
//         children: [
//           Text('Total Breakfast Daily: ${mealData.totalBreakfastDaily}'),
//           Text('Total Lunch Daily: ${mealData.totalLunchDaily}'),
//           Text('Total Dinner Daily: ${mealData.totalDinnerDaily}'),
//           Text('Total Breakfast Monthly: ${mealData.totalBreakfastMonthly}'),
//           Text('Total Lunch Monthly: ${mealData.totalLunchMonthly}'),
//           Text('Total Dinner Monthly: ${mealData.totalDinnerMonthly}'),
//           Text('Total Dinner Monthly: ${mealData.totalMealMonthly}'),
//         ],
//       ),
//     );
//   }
// }