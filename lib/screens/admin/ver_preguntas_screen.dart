import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VerPreguntasScreen extends StatelessWidget {
  const VerPreguntasScreen({super.key});

  void _eliminarPregunta(String id, BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('preguntas').doc(id).delete();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pregunta eliminada')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF004077),
      appBar: AppBar(
        title: const Text(
          'Preguntas Registradas',
          style: TextStyle(color: Color(0xFFFFD700)),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xFFFFD700)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('preguntas').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final preguntas = snapshot.data!.docs;

          return ListView.builder(
            itemCount: preguntas.length,
            itemBuilder: (context, index) {
              final pregunta = preguntas[index];
              return Card(
                color: Colors.white,
                child: ListTile(
                  title: Text(
                    pregunta['Pregunta'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("Respuesta: ${pregunta['respuesta']}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () {
                          // TODO: pantalla de edición
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed:
                            () => _eliminarPregunta(pregunta.id, context),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
