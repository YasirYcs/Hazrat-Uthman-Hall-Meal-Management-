import '../Bazar/BazarData.dart';
import '../Meal/MealData.dart';
class MealRateCalculator {
  final BazarDataFetcher _dataFetcher;
  final MealSummaryFetcher _mealSummaryFetcher;

  MealRateCalculator({
    required BazarDataFetcher dataFetcher,
    required MealSummaryFetcher mealSummaryFetcher,
  }) : _dataFetcher = dataFetcher,
        _mealSummaryFetcher = mealSummaryFetcher;

  Future<double> calculateMealRateForCurrentMonth(int month, int year) async {
    // Fetch the bazar data for the current month
    final totalBazarAmount = await _dataFetcher.totalBazar(month, year);

    // Fetch meal data for the current month
    await _mealSummaryFetcher.fetchMealsByMonth(month);
    final totalMealsThisMonth = _mealSummaryFetcher.getTotalMealsByMonth().values.fold(
      0,
          (sum, meal) => sum + (meal['breakfast'] ?? 0) + (meal['lunch'] ?? 0) + (meal['dinner'] ?? 0),
    );

    // Calculate meal rate
    if (totalMealsThisMonth > 0) {
      return totalBazarAmount / totalMealsThisMonth;
    }
    return 0.0; // If no meals this month, return 0
  }
}
