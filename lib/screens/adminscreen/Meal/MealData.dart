import 'package:firebase_database/firebase_database.dart';

class MealSummaryFetcher {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref('accepted_requests');

  Map<String, Map<String, int>> _totalMealsByDate = {};
  Map<String, Map<String, int>> _totalMealsByMonth = {};

  // Daily and monthly totals
  int totalBreakfastDaily = 0;
  int totalLunchDaily = 0;
  int totalDinnerDaily = 0;
  int totalMealDaily = 0; // Total meals for the day

  int totalBreakfastMonthly = 0;
  int totalLunchMonthly = 0;
  int totalDinnerMonthly = 0;
  int totalMealMonthly = 0; // Total meals for the month

  Future<void> fetchMealsByMonth(int month) async {
    // Clear previous data
    _totalMealsByDate.clear();
    _totalMealsByMonth.clear();

    // Reset totals
    totalBreakfastDaily = 0;
    totalLunchDaily = 0;
    totalDinnerDaily = 0;
    totalMealDaily = 0;

    totalBreakfastMonthly = 0;
    totalLunchMonthly = 0;
    totalDinnerMonthly = 0;
    totalMealMonthly = 0;

    DatabaseEvent event = await _databaseReference.once();
    Map<dynamic, dynamic>? snapshot = event.snapshot.value as Map<dynamic, dynamic>?;

    if (snapshot != null) {
      snapshot.forEach((date, meals) {
        // Extract the month from the date string (assuming format 'YYYY-MM-DD')
        String monthString = date.substring(5, 7);
        int mealMonth = int.parse(monthString);

        // Check if the month matches the requested month
        if (mealMonth == month) {
          int breakfastCount = 0;
          int lunchCount = 0;
          int dinnerCount = 0;

          (meals as Map<dynamic, dynamic>).forEach((userId, userMeals) {
            breakfastCount += userMeals['breakfast'] ? 1 : 0;
            lunchCount += userMeals['lunch'] ? 1 : 0;
            dinnerCount += userMeals['dinner'] ? 1 : 0;
          });

          // Store daily totals
          _totalMealsByDate[date] = {
            'breakfast': breakfastCount,
            'lunch': lunchCount,
            'dinner': dinnerCount,
          };

          // Update daily totals
          totalBreakfastDaily += breakfastCount;
          totalLunchDaily += lunchCount;
          totalDinnerDaily += dinnerCount;
          totalMealDaily += (breakfastCount + lunchCount + dinnerCount);

          // Initialize month entry if not already present
          if (!_totalMealsByMonth.containsKey(month.toString())) {
            _totalMealsByMonth[month.toString()] = {'breakfast': 0, 'lunch': 0, 'dinner': 0};
          }

          // Safely access and update monthly totals
          _totalMealsByMonth[month.toString()]!['breakfast'] = (_totalMealsByMonth[month.toString()]!['breakfast'] ?? 0) + breakfastCount;
          _totalMealsByMonth[month.toString()]!['lunch'] = (_totalMealsByMonth[month.toString()]!['lunch'] ?? 0) + lunchCount;
          _totalMealsByMonth[month.toString()]!['dinner'] = (_totalMealsByMonth[month.toString()]!['dinner'] ?? 0) + dinnerCount;

          // Update monthly totals
          totalBreakfastMonthly += breakfastCount;
          totalLunchMonthly += lunchCount;
          totalDinnerMonthly += dinnerCount;
          totalMealMonthly += (breakfastCount + lunchCount + dinnerCount);
        }
      });
    }
  }

  // Method to get daily meal totals
  Map<String, Map<String, int>> getTotalMealsByDate() {
    return _totalMealsByDate;
  }

  // Method to get monthly meal totals
  Map<String, Map<String, int>> getTotalMealsByMonth() {
    return _totalMealsByMonth;
  }
}