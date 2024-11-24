import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../adminscreen/Meal/MealData.dart';

class MealSummaryPage extends StatefulWidget {
  @override
  _MealSummaryPageState createState() => _MealSummaryPageState();
}

class _MealSummaryPageState extends State<MealSummaryPage> {
  final MealSummaryFetcher _mealSummaryFetcher = MealSummaryFetcher();
  Map<String, Map<String, int>> _totalMealsByDate = {};
  Map<String, Map<String, int>> _totalMealsByMonth = {};

  @override
  void initState() {
    super.initState();
    _fetchMealData();
  }

  Future<void> _fetchMealData() async {
    // Fetch meals for the specific month (e.g., November, which is 11)
    await _mealSummaryFetcher.fetchMealsByMonth(12);

    // Get the total meals by date and month from the fetcher
    _totalMealsByDate = _mealSummaryFetcher.getTotalMealsByDate();
    _totalMealsByMonth = _mealSummaryFetcher.getTotalMealsByMonth();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meal Summary'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _totalMealsByDate.length,
              itemBuilder: (context, index) {
                final date = _totalMealsByDate.keys.elementAt(index);
                final meals = _totalMealsByDate[date];

                return ListTile(
                  title: Text('Date: $date'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Breakfast: ${meals?['breakfast']}'),
                      Text('Lunch: ${meals?['lunch']}'),
                      Text('Dinner: ${meals?['dinner']}'),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Meals by Month:', style: TextStyle(fontWeight: FontWeight.bold)),
                for (var entry in _totalMealsByMonth.entries)
                  ListTile(
                    title: Text('Month: ${entry.key}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Breakfast: ${entry.value['breakfast']}'),
                        Text('Total Lunch: ${entry.value['lunch']}'),
                        Text('Total Dinner: ${entry.value['dinner']}'),
                        Text('Total Meals: ${entry.value['breakfast']! + entry.value['lunch']! + entry.value['dinner']!}'),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}