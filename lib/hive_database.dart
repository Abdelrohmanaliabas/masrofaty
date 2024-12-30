import 'package:hive/hive.dart';

part 'hive_database.g.dart';

@HiveType(typeId: 0)
class Transaction {
  @HiveField(0)
  final String description;
  @HiveField(1)
  final double amount;
  @HiveField(2)
  final DateTime date;

  Transaction(
      {required this.description, required this.amount, required this.date});
}

class HiveDatabase {
  static late Box transactionBox;

  static Future<void> init() async {
    transactionBox = await Hive.openBox('transactions');
  }

  static List<Transaction> getTransactions() {
    return transactionBox.values.toList().cast<Transaction>();
  }

  static void addTransaction(Transaction transaction) {
    transactionBox.add(transaction);
  }

  static double getTotalAmount() {
    double total = 0;
    for (var transaction in transactionBox.values) {
      total += transaction.amount;
    }
    return total;
  }
}
