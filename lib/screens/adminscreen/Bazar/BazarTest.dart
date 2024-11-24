import 'package:flutter/material.dart';
import 'BazarData.dart';

class FetchDataPage extends StatefulWidget {
  @override
  _FetchDataPageState createState() => _FetchDataPageState();
}

class _FetchDataPageState extends State<FetchDataPage> {
  final BazarDataFetcher _dataFetcher = BazarDataFetcher();
  int? _totalAmount;

  @override
  void initState() {
    super.initState();
    _fetchDataForMonth(12, 2024); // Fetch data for November 2024
  }

  Future<void> _fetchDataForMonth(int month, int year) async {
    final total = await _dataFetcher.totalBazar(month, year);
    setState(() {
      _totalAmount = total;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bazar Data'),
      ),
      body: Center(
        child: _totalAmount == null
            ? CircularProgressIndicator()
            : Text(
          'Total for Month: $_totalAmount',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

void main() => runApp(MaterialApp(home: FetchDataPage()));
