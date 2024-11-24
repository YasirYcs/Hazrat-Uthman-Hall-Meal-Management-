import 'package:firebase_database/firebase_database.dart';

class BazarDataFetcher {
  final _databaseReference = FirebaseDatabase.instance.ref('bazar');
  /// Fetch total data for a specific month (1-based) and return the total amount.
  Future<int> totalBazar(int month, int year) async {
    DatabaseEvent event = await _databaseReference.once();
    Map<dynamic, dynamic>? snapshot = event.snapshot.value as Map<dynamic, dynamic>?;

    if (snapshot != null) {
      int total = 0;

      snapshot.forEach((parentKey, parentValue) {
        if (parentValue is Map) {
          parentValue.forEach((entryKey, entryValue) {
            if (entryValue is Map) {
              final amount = int.tryParse(entryValue['amount'].toString().replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
              final submittedAt = entryValue['submittedAt'] ?? '';

              // Extract the month and year from the submittedAt field
              final dateMatch = RegExp(r'(\d{2})/(\d{4})').firstMatch(submittedAt);
              if (dateMatch != null) {
                final entryMonth = int.tryParse(dateMatch.group(1) ?? '');
                final entryYear = int.tryParse(dateMatch.group(2) ?? '');

                // Add to the total if the month and year match
                if (entryMonth == month && entryYear == year) {
                  total += amount;
                }
              }
            }
          });
        }
      });

      return total;
    }

    return 0; // Return 0 if no data is found
  }
}
