import 'package:flutter/material.dart';
import '../models/transaction.dart';
import 'package:intl/intl.dart';
import '../utils/date_formatter.dart';
import '../utils/currency_formatter.dart';
import '../database_helper.dart';

class EditExpenseScreen extends StatefulWidget {
  final Transaction transaction;
  final Function(Transaction) onEdit;
  final Function(int) onDelete;

  const EditExpenseScreen({
    super.key,
    required this.transaction,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  late TextEditingController _dateController;
  late String _category;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.transaction.description);
    _amountController = TextEditingController(text: widget.transaction.amount.toString());
    _dateController = TextEditingController(text: DateFormat("dd/MM/yyyy").format(widget.transaction.date));
    _category = widget.transaction.category;
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final updatedTransaction = widget.transaction.copyWith(
        description: _descriptionController.text,
        amount: double.parse(_amountController.text.replaceAll(RegExp(r'[^0-9.]'), '')),
        category: _category,
        date: DateFormat("dd/MM/yyyy").parse(_dateController.text),
      );

      var dbHelper = DatabaseHelper();
      dbHelper.updateGasto({
        'id': widget.transaction.id,
        'descripcion': updatedTransaction.description,
        'categoria': updatedTransaction.category,
        'monto': updatedTransaction.amount,
        'fecha': updatedTransaction.date.toIso8601String(),
      });

      widget.onEdit(updatedTransaction);
      Navigator.of(context).pop();
    }
  }

  void _delete() async {
    var dbHelper = DatabaseHelper();
    await dbHelper.deleteGasto(widget.transaction.id); 
    widget.onDelete(widget.transaction.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Gasto eliminado correctamente"),
        duration: Duration(seconds: 2),
      ),
    );



    Navigator.of(context).pop();
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmar eliminación"),
          content: Text("¿Seguro que quieres eliminar este gasto?"),
          actions: [
            TextButton(
              child: Text("Cancelar"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text("Eliminar"),
              onPressed: () {
                _delete();  
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Gasto', style: TextStyle(color: Colors.lightBlueAccent)),
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
              const SizedBox(height: 10),
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
              const SizedBox(height: 10),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(labelText: 'Fecha'),
                keyboardType: TextInputType.number,
                inputFormatters: [DateTextInputFormatter()],
                validator: (value) => value!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Categoría'),
                items: const [
                  DropdownMenuItem(value: 'General', child: Text('General')),
                  DropdownMenuItem(value: 'Compras', child: Text('Compras')),
                  DropdownMenuItem(value: 'Transporte', child: Text('Transporte')),
                  DropdownMenuItem(value: 'Ocio', child: Text('Ocio')),
                ],
                onChanged: (value) => setState(() => _category = value!),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:  _confirmDelete,
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red,
                          backgroundColor: Colors.transparent,
                          side: const BorderSide(color: Colors.red)),
                      child: const Text('Eliminar'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(foregroundColor: Colors.blueAccent,
                          backgroundColor: Colors.transparent,
                          side: const BorderSide(color: Colors.blueAccent)),
                      child: const Text('Guardar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
