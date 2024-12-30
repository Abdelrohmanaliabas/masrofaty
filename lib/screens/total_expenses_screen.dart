import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart'; // Importing intl package for DateFormat

class AllExpensesScreen extends StatefulWidget {
  const AllExpensesScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AllExpensesScreenState createState() => _AllExpensesScreenState();
}

class _AllExpensesScreenState extends State<AllExpensesScreen> {
  final Box expensesBox = Hive.box('expensesBox');
  double totalMoney = 0.0;
  List<Map> allTransactions = [];

  @override
  void initState() {
    super.initState();
    loadTransactions();
  }

  void loadTransactions() {
    final dateFormat = DateFormat('dd/MM HH:mm'); // Correct DateFormat
    allTransactions.clear();
    for (var transaction in expensesBox.values) {
      try {
        // Ensure the date is being stored as a string, then parse it into DateTime
        String transactionDateStr = transaction['date'] ?? '';
        DateTime parsedDate = dateFormat.parse(transactionDateStr);

        allTransactions.add({
          'key': transaction['key'],
          'date': parsedDate,
          'amount': transaction['amount'],
          'name': transaction['name'],
          'source': transaction['source'],
        });
      } catch (e) {
        print(
            "Error parsing date: ${transaction['date']}"); // Handle parsing failure
      }
    }

    allTransactions.sort((a, b) {
      DateTime dateA = a['date'];
      DateTime dateB = b['date'];
      return dateA.compareTo(dateB);
    });

    calculateTotalMoney();
    setState(() {});
  }

  void calculateTotalMoney() {
    totalMoney = 0.0;
    for (var transaction in allTransactions) {
      totalMoney += transaction['amount'];
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime? prevTransactionDate;
    double dailyTotal = 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("جميع المعاملات"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Chip(
              label: Text(
                "المجموع: ${totalMoney.toStringAsFixed(2)}",
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(28.0),
        child: ListView.builder(
          itemCount: allTransactions.length,
          itemBuilder: (context, index) {
            var transaction = allTransactions[index];
            DateTime transactionDate = transaction['date'];

            bool isNewDay = prevTransactionDate == null ||
                transactionDate.day != prevTransactionDate?.day ||
                transactionDate.month != prevTransactionDate?.month ||
                transactionDate.year != prevTransactionDate?.year;

            if (isNewDay) {
              prevTransactionDate = transactionDate;
              if (index > 0) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          "مجموع مصروفات اليوم: ${dailyTotal.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: dailyTotal >= 0 ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                    ),
                    Container(height: 1, color: Colors.grey),
                  ],
                );
              }
              dailyTotal = 0.0;
            }

            dailyTotal += transaction['amount'];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isNewDay)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        "${transactionDate.day}/${transactionDate.month}/${transactionDate.year}",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ListTile(
                  title: Text("${transaction['name']}"),
                  subtitle: Text(
                      "${transaction['amount']} - ${transaction['source']} - ${transactionDate.toLocal()}"),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      expensesBox.deleteAt(index);
                      loadTransactions();
                    },
                  ),
                ),
                Divider(),
              ],
            );
          },
        ),
      ),
    );
  }
}
