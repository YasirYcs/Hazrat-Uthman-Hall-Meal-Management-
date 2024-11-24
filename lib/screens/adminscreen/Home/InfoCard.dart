import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InfoCard extends StatelessWidget {
  final int totalMealsToday;
  final int? totalMealsThisMonth;
  final String formattedDateTime;
  final int? totalBazarAmount;

  const InfoCard({
    Key? key,
    required this.totalMealsToday,
    required this.totalMealsThisMonth,
    required this.formattedDateTime,
    required this.totalBazarAmount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double mealRate = 0.0;
    if (totalBazarAmount != null && totalMealsThisMonth != null && totalMealsThisMonth! > 0) {
      mealRate = totalBazarAmount! / totalMealsThisMonth!;
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Live Date and Time:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Center(
            child: Text(
              formattedDateTime,
              style: TextStyle(fontSize: 16),
            ),
          ),
          _buildInfoBlock('Meal Rate', '${mealRate.toStringAsFixed(2)}'), // Format to 2 decimal places
          _buildInfoBlock('Total Meal Today', '$totalMealsToday'),
          _buildInfoBlock('Total Meal This Month', '$totalMealsThisMonth'),
          _buildInfoBlock('Total Bazar This Month', '${totalBazarAmount ?? 0}'),
          _buildInfoBlock('Total Students', '200'),
        ],
      ),
    );
  }

  Widget _buildInfoBlock(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}