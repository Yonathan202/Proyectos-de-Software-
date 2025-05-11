import 'package:flutter/material.dart';
import '../screens/add_expense_screen.dart';
import '../screens/edit_expense_screen.dart';
import '../models/transaction.dart';
import '../widgets/transaction_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Transaction> transactions = [];

  void addTransaction(Transaction transaction) {
    setState(() {
      transactions.add(transaction);
    });
  }

  void editTransaction(Transaction updatedTransaction) {
    setState(() {
      transactions = transactions.map((tx) =>
      tx.id == updatedTransaction.id ? updatedTransaction : tx).toList();
    });
  }

  void deleteTransaction(String id) {
    setState(() {
      transactions.removeWhere((tx) => tx.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gasto", style: TextStyle(color: Colors.lightBlueAccent)),
        backgroundColor: const Color(0xFF0B0D1B),
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Total: \$${calculateTotal()}",
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  return TransactionCard(
                    transaction: transactions[index],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditExpenseScreen(
                          transaction: transactions[index],
                          onEdit: editTransaction,
                          onDelete: deleteTransaction,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text("Añadir gasto"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddExpenseScreen(onAdd: addTransaction),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                backgroundColor: Colors.transparent,
                side: const BorderSide(color: Colors.lightBlueAccent),
              ),
            ),

          ],
        ),
      ),
    );
  }

  double calculateTotal() {
    return transactions.fold(0, (sum, item) => sum + item.amount);
  }
}
