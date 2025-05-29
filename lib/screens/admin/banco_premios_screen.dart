import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BancoPremiosScreen extends StatefulWidget {
  const BancoPremiosScreen({super.key});

  @override
  State<BancoPremiosScreen> createState() => _BancoPremiosScreenState();
}

class _BancoPremiosScreenState extends State<BancoPremiosScreen> {
  List<dynamic> premios = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarPremios();
  }

  Future<void> _cargarPremios() async {
    final data = await Supabase.instance.client
        .from('premios')
        .select()
        .order('fecha_creacion', ascending: false);
    setState(() {
      premios = data;
      cargando = false;
    });
  }

  Future<void> _editarPremio(Map premio) async {
    final tituloController = TextEditingController(text: premio['titulo']);
    final descripcionController = TextEditingController(
      text: premio['descripcion'] ?? '',
    );
    final puntosController = TextEditingController(
      text: premio['puntos'].toString(),
    );
    bool activo = premio['activo'];
    Uint8List? nuevaImagen;

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Editar Premio'),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: tituloController,
                      decoration: const InputDecoration(labelText: 'Título'),
                    ),
                    TextField(
                      controller: descripcionController,
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                      ),
                    ),
                    TextField(
                      controller: puntosController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Puntos'),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text('Activo'),
                        const Spacer(),
                        Switch(
                          value: activo,
                          onChanged: (v) => setDialogState(() => activo = v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final picker = ImagePicker();
                        final pickedFile = await picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (pickedFile != null) {
                          final bytes = await pickedFile.readAsBytes();
                          setDialogState(() => nuevaImagen = bytes);
                        }
                      },
                      icon: const Icon(Icons.image),
                      label: const Text('Actualizar Imagen (opcional)'),
                    ),
                    if (nuevaImagen != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Image.memory(nuevaImagen!, height: 120),
                      ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final updatedData = {
                    'titulo': tituloController.text.trim(),
                    'descripcion': descripcionController.text.trim(),
                    'puntos': int.tryParse(puntosController.text.trim()) ?? 0,
                    'activo': activo,
                  };

                  if (nuevaImagen != null) {
                    final path = 'premios/${premio['id']}.jpg';
                    final storage = Supabase.instance.client.storage.from(
                      'premios',
                    );
                    await storage.uploadBinary(
                      path,
                      nuevaImagen!,
                      fileOptions: const FileOptions(upsert: true),
                    );
                    final newUrl = storage.getPublicUrl(path);
                    updatedData['imagen_url'] = newUrl;
                  }

                  await Supabase.instance.client
                      .from('premios')
                      .update(updatedData)
                      .eq('id', premio['id']);

                  if (mounted) {
                    Navigator.pop(context);
                    _cargarPremios();
                  }
                } catch (e, s) {
                  debugPrint('❌ Error al guardar premio: $e');
                  debugPrint('Stack: $s');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al guardar: $e')),
                    );
                  }
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _eliminarPremio(String id, String storagePath) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('¿Eliminar Premio?'),
            content: const Text('Esto eliminará el premio permanentemente.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await Supabase.instance.client.from('premios').delete().eq('id', id);
      await Supabase.instance.client.storage.from('premios').remove([
        storagePath,
      ]);
      _cargarPremios();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Banco de Premios'),
        backgroundColor: const Color(0xFF004077),
      ),
      body:
          cargando
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: premios.length,
                itemBuilder: (_, i) {
                  final premio = premios[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(premio['imagen_url']),
                        radius: 28,
                      ),
                      title: Text(
                        premio['titulo'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Puntos: ${premio['puntos']} • ${premio['activo'] ? "Activo" : "Inactivo"}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editarPremio(premio),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed:
                                () => _eliminarPremio(
                                  premio['id'],
                                  'premios/${premio['id']}.jpg',
                                ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
