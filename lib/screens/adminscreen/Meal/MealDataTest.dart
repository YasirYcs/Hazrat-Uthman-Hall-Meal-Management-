import 'package:flutter/material.dart';
import '../Bazar/BazarData.dart';
import '../Meal/MealData.dart';
import 'MealRate.dart'; // Ensure this import is correct

class MealRatePage extends StatefulWidget {
  @override
  _MealRatePageState createState() => _MealRatePageState();
}

class _MealRatePageState extends State<MealRatePage> {
  double mealRate = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchMealRate();
  }

  // Function to calculate meal rate and update the state
  Future<void> _fetchMealRate() async {
    final dataFetcher = BazarDataFetcher();
    final mealSummaryFetcher = MealSummaryFetcher();
    final mealRateCalculator = MealRateCalculator(
      dataFetcher: dataFetcher,
      mealSummaryFetcher: mealSummaryFetcher,
    );
    final currentDate = DateTime.now();
    final month = currentDate.month;
    final year = currentDate.year;

    double calculatedRate = await mealRateCalculator.calculateMealRateForCurrentMonth(month, year);

    setState(() {
      mealRate = calculatedRate;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Meal Rate for Current Month')),
      body: Center(
        child: mealRate == 0.0
            ? CircularProgressIndicator() // Show loading indicator while fetching data
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Meal Rate for this Month:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              '\$${mealRate.toStringAsFixed(2)}', // Display the meal rate
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
