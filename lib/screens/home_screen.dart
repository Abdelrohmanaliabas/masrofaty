import 'package:flutter/material.dart';
import 'personal_expenses_screen.dart';
import 'client_expenses_screen.dart';
import 'total_expenses_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("الصفحة الرئيسية")),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(),
              Spacer(),
              Spacer(),
              Spacer(),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PersonalExpensesScreen()));
                },
                child: Text("مصاريفي الشخصية"),
              ),
              Spacer(),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ClientExpensesScreen()));
                },
                child: Text("مصاريف العملاء"),
              ),
              Spacer(),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AllExpensesScreen()));
                },
                child: Text("إجمالي الفلوس"),
              ),
              Spacer(),
              Spacer(),
              Spacer(),
              Spacer(),
            ],
          ),
        ],
      ),
    );
  }
}
