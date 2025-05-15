import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart';
import 'package:intl/intl.dart';
import '../utils/date_formatter.dart';
import '../utils/currency_formatter.dart';
import '../database_helper.dart';

class AddExpenseScreen extends StatefulWidget {
  final Function(Transaction) onAdd;

  const AddExpenseScreen({super.key, required this.onAdd});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();
  String _category = 'General';

  void _submit() async {
    print("Botón Guardar presionado");
    if (_formKey.currentState!.validate()) {
      print("Formulario validado correctamente");
      var dbHelper = DatabaseHelper();
      int newId = await dbHelper.insertGasto({  // Guarda el ID generado por SQLite
        'descripcion': _descriptionController.text,
        'categoria': _category,
        'monto': double.parse(_amountController.text.replaceAll(RegExp(r'[^0-9.]'), '')),
        'fecha': DateFormat("dd/MM/yyyy").parse(_dateController.text).toIso8601String(),
      });

      final newTransaction = Transaction(
        id: newId,  // Usa el ID generado por SQLite
        description: _descriptionController.text,
        category: _category,
        amount: double.parse(_amountController.text.replaceAll(RegExp(r'[^0-9.]'), '')),
        date: DateFormat("dd/MM/yyyy").parse(_dateController.text),
      );

      widget.onAdd(newTransaction);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Añadir Gasto', style: TextStyle(color: Colors.lightBlueAccent)),
        backgroundColor: const Color(0xFF0B0D1B),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                validator: (value) => value!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Monto'),
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyTextInputFormatter()],
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Monto requerido';
                  value = value.replaceAll(RegExp(r'[^0-9.]'), '');
                  if (double.tryParse(value) == null) return 'Monto inválido';
                  return null;
                },
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(labelText: 'Fecha'),
                keyboardType: TextInputType.number,
                inputFormatters: [DateTextInputFormatter()],
                validator: (value) => value == null || value.isEmpty ? 'Fecha requerida' : null,
              ),
              const SizedBox(height: 30),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Categoría'),
                items: const [
                  DropdownMenuItem(value: 'General', child: Text('General')),
                  DropdownMenuItem(value: 'Compras', child: Text('Compras')),
                  DropdownMenuItem(value: 'Transporte', child: Text('Transporte')),
                  DropdownMenuItem(value: 'Ocio', child: Text('Ocio')),
                  DropdownMenuItem(value: 'Comida', child: Text('Comida')),
                ],
                onChanged: (value) => setState(() => _category = value!),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  backgroundColor: Colors.transparent,
                  side: const BorderSide(color: Colors.lightBlueAccent),
                ),
                child: const Text('Guardar'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
