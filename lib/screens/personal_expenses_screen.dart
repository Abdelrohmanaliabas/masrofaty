import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class PersonalExpensesScreen extends StatefulWidget {
  @override
  _PersonalExpensesScreenState createState() => _PersonalExpensesScreenState();
}

class _PersonalExpensesScreenState extends State<PersonalExpensesScreen> {
  final Box expensesBox = Hive.box('expensesBox');
  final TextEditingController amountController = TextEditingController();
  final TextEditingController nameController =
      TextEditingController(); // لإدخال اسم المعاملة
  String transactionType = 'موجب'; // افتراضيا

  double totalPersonalMoney = 0.0;

  @override
  void initState() {
    super.initState();
    calculateTotalPersonalMoney();
  }

  void calculateTotalPersonalMoney() {
    totalPersonalMoney = 0.0;
    for (var transaction in expensesBox.values) {
      if (transaction['source'] == 'فلوس شخصية') {
        totalPersonalMoney += transaction['amount'];
      }
    }
  }

  void addTransaction() {
    var amount = double.tryParse(amountController.text);
    if (amount != null && nameController.text.isNotEmpty) {
      var formattedDate =
          DateFormat('dd/MM HH:mm').format(DateTime.now()); // Formatting date

      expensesBox.add({
        'amount': transactionType == 'موجب' ? amount : -amount,
        'date': formattedDate, // Use formatted date
        'source': 'فلوس شخصية',
        'name': nameController.text, // اسم المعاملة
      });

      amountController.clear();
      nameController.clear();
      calculateTotalPersonalMoney(); // تحديث مجموع الفلوس الشخصية بعد إضافة المعاملة
      setState(() {});
    }
  }

  void deleteTransaction(int index) {
    expensesBox.deleteAt(index);
    calculateTotalPersonalMoney(); // تحديث المجموع بعد الحذف
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("مصاريفي الشخصية"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Chip(
              label: Text(
                "مجموع الفلوس: ${totalPersonalMoney.toStringAsFixed(2)}",
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'اسم المعاملة',
                labelStyle: const TextStyle(
                  color: Colors.blue, // Color of the label text
                  fontSize: 16.0, // Font size of the label
                ),
                hintText:
                    'أدخل اسم المعاملة', // Optional hint text when the field is empty
                hintStyle: const TextStyle(
                  color: Colors.grey, // Color for the hint text
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0), // Rounded corners
                  borderSide: const BorderSide(
                    color: Colors.blue, // Border color
                    width: 2.0, // Border width
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(
                    color: Colors.green, // Border color when focused
                    width: 2.0,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(
                    color: Colors.blue, // Border color when not focused
                    width: 2.0,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 15.0), // Padding inside the field
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      transactionType = 'موجب';
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Green color for "موجب"
                  ),
                  child: const Text(
                    "موجب",
                    style: TextStyle(color: Colors.white), // White text color
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      transactionType = 'سالب';
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Red color for "سالب"
                  ),
                  child: const Text(
                    "سالب",
                    style: TextStyle(color: Colors.white), // White text color
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 14,
            ),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'المبلغ', // Label text
                labelStyle: const TextStyle(
                  color: Colors.blue, // Color of the label text
                  fontSize: 16.0, // Font size of the label
                ),
                hintText: 'أدخل المبلغ', // Hint text when the field is empty
                hintStyle: const TextStyle(
                  color: Colors.grey, // Color for the hint text
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0), // Rounded corners
                  borderSide: const BorderSide(
                    color: Colors.blue, // Border color
                    width: 2.0, // Border width
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(
                    color: Colors.green, // Border color when focused
                    width: 2.0,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(
                    color: Colors.blue, // Border color when not focused
                    width: 2.0,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 15.0), // Padding inside the field
              ),
            ),
            const SizedBox(
              height: 14,
            ),
            ElevatedButton(
              onPressed: addTransaction,
              child: const Text("أضف المعاملة"),
            ),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: expensesBox.listenable(),
                builder: (context, box, _) {
                  var transactions = box.values.toList().cast<Map>();
                  return ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      var transaction = transactions[index];
                      if (transaction['source'] == 'فلوس شخصية') {
                        return ListTile(
                          title: Text("${transaction['name']}"),
                          subtitle: Text(
                              "${transaction['amount']} - ${transaction['date']}"),
                          trailing: IconButton(
                            color: Colors.red,
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              deleteTransaction(index); // مسح الكارت
                            },
                          ),
                        );
                      }
                      return Container(); // تجاهل المعاملات الأخرى
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "القيمة المتبقية: ${totalPersonalMoney.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
