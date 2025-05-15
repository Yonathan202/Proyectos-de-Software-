import 'package:flutter/material.dart';
import '../database_helper.dart';

class VerificarGastosScreen extends StatelessWidget {
  const VerificarGastosScreen({super.key});

  Future<List<Map<String, dynamic>>> _getGastos() async {
    var dbHelper = DatabaseHelper();
    return await dbHelper.getGastos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gastos Guardados')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getGastos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar los datos'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay gastos guardados.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var gasto = snapshot.data![index];
              return ListTile(
                title: Text(gasto['descripcion']),
                subtitle: Text('Monto: \$${gasto['monto']} - Fecha: ${gasto['fecha']}'),
              );
            },
          );
        },
      ),
    );
  }
}
