import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class ClientExpensesScreen extends StatefulWidget {
  @override
  _ClientExpensesScreenState createState() => _ClientExpensesScreenState();
}

class _ClientExpensesScreenState extends State<ClientExpensesScreen> {
  final Box expensesBox = Hive.box('expensesBox');
  final TextEditingController amountController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  String transactionType = 'موجب'; // افتراضيا

  double totalClientMoney = 0.0;

  @override
  void initState() {
    super.initState();
    calculateTotalClientMoney();
  }

  void calculateTotalClientMoney() {
    totalClientMoney = 0.0;
    for (var transaction in expensesBox.values) {
      if (transaction['source'] == 'مصاريف العملاء') {
        totalClientMoney += transaction['amount'];
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
        'source': 'مصاريف العملاء',
        'name': nameController.text, // اسم المعاملة
      });

      amountController.clear();
      nameController.clear();
      calculateTotalClientMoney(); // تحديث مجموع فلوس العملاء بعد إضافة المعاملة
      setState(() {});
    }
  }

  void deleteTransaction(int index) {
    expensesBox.deleteAt(index);
    calculateTotalClientMoney(); // تحديث المجموع بعد الحذف
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("مصاريف العملاء"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Chip(
              label: Text(
                "مجموع الفلوس: ${totalClientMoney.toStringAsFixed(2)}",
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
                  color: Colors.blue,
                  fontSize: 16.0,
                ),
                hintText: 'أدخل اسم المعاملة',
                hintStyle: const TextStyle(
                  color: Colors.grey,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(
                    color: Colors.blue,
                    width: 2.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(
                    color: Colors.green,
                    width: 2.0,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(
                    color: Colors.blue,
                    width: 2.0,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 15.0),
              ),
            ),
            const SizedBox(height: 15),
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
                    backgroundColor: Colors.green,
                  ),
                  child: const Text(
                    "موجب",
                    style: TextStyle(color: Colors.white),
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
                    backgroundColor: Colors.red,
                  ),
                  child: const Text(
                    "سالب",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'المبلغ',
                labelStyle: const TextStyle(
                  color: Colors.blue,
                  fontSize: 16.0,
                ),
                hintText: 'أدخل المبلغ',
                hintStyle: const TextStyle(
                  color: Colors.grey,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(
                    color: Colors.blue,
                    width: 2.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(
                    color: Colors.green,
                    width: 2.0,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(
                    color: Colors.blue,
                    width: 2.0,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 15.0),
              ),
            ),
            const SizedBox(height: 14),
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
                      if (transaction['source'] == 'مصاريف العملاء') {
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
                "القيمة المتبقية: ${totalClientMoney.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
