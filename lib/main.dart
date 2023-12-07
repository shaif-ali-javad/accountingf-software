import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(AccountingApp());
}

class AccountingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Accounting App',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Transaction> transactions = [];

  @override
  void initState() {
    super.initState();
    // Load transactions from shared preferences when the app starts
    loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Accounting App'),
      ),
      body: Column(
        children: [
          TransactionList(transactions),
          TransactionForm((String title, double amount) {
            addTransaction(title, amount);
          }),
        ],
      ),
    );
  }

  void addTransaction(String title, double amount) async {
    setState(() {
      transactions.add(Transaction(title, amount));
    });

    // Save transactions to shared preferences
    await saveTransactions();
  }

  Future<void> loadTransactions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? transactionsJson = prefs.getStringList('transactions');

    if (transactionsJson != null) {
      setState(() {
        transactions =
            transactionsJson.map((json) => Transaction.fromJson(json)).toList();
      });
    }
  }

  Future<void> saveTransactions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> transactionsJson =
        transactions.map((transaction) => transaction.toJson()).toList();

    prefs.setStringList('transactions', transactionsJson);
  }
}

class Transaction {
  final String title;
  final double amount;

  Transaction(this.title, this.amount);

  // Convert transaction to JSON
  String toJson() {
    return '{"title": "$title", "amount": $amount}';
  }

  // Create a transaction from JSON
  factory Transaction.fromJson(String json) {
    Map<String, dynamic> data = jsonDecode(json);
    return Transaction(data['title'], data['amount']);
  }
}

class TransactionList extends StatelessWidget {
  final List<Transaction> transactions;

  TransactionList(this.transactions);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Transactions'),
        ListView.builder(
          shrinkWrap: true,
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(transactions[index].title),
              subtitle: Text('\$${transactions[index].amount}'),
            );
          },
        ),
      ],
    );
  }
}

class TransactionForm extends StatefulWidget {
  final Function(String title, double amount) onFormSubmit;

  TransactionForm(this.onFormSubmit);

  @override
  _TransactionFormState createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Add Transaction'),
        TextField(
          controller: _titleController,
          decoration: InputDecoration(labelText: 'Title'),
        ),
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'Amount'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onFormSubmit(
              _titleController.text,
              double.parse(_amountController.text),
            );
            _titleController.clear();
            _amountController.clear();
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}
