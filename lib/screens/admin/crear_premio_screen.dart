import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class CrearPremioScreen extends StatefulWidget {
  const CrearPremioScreen({super.key});

  @override
  State<CrearPremioScreen> createState() => _CrearPremioScreenState();
}

class _CrearPremioScreenState extends State<CrearPremioScreen> {
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _puntosController = TextEditingController();
  Uint8List? _imagenBytes;
  File? _imagenArchivo;
  bool _subiendo = false;

  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imagenBytes = bytes;
        _imagenArchivo = File(pickedFile.path);
      });
    }
  }

  Future<void> _crearPremio() async {
    final titulo = _tituloController.text.trim();
    final descripcion = _descripcionController.text.trim();
    final puntos = int.tryParse(_puntosController.text.trim()) ?? -1;

    if (titulo.isEmpty || puntos < 0 || _imagenBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa todos los campos correctamente'),
        ),
      );
      return;
    }

    setState(() => _subiendo = true);

    try {
      final uuid = const Uuid().v4();
      final storagePath = 'premios/$uuid.jpg';

      final storage = Supabase.instance.client.storage.from('premios');
      await storage.uploadBinary(
        storagePath,
        _imagenBytes!,
        fileOptions: const FileOptions(upsert: true),
      );
      final imagenUrl = storage.getPublicUrl(storagePath);

      await Supabase.instance.client.from('premios').insert({
        'titulo': titulo,
        'descripcion': descripcion,
        'puntos': puntos,
        'imagen_url': imagenUrl,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🎉 Premio creado con éxito')),
      );

      _tituloController.clear();
      _descripcionController.clear();
      _puntosController.clear();
      setState(() {
        _imagenBytes = null;
        _imagenArchivo = null;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al crear premio: $e')));
    } finally {
      if (mounted) setState(() => _subiendo = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Premio'),
        backgroundColor: const Color(0xFF004077),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _tituloController,
              decoration: const InputDecoration(labelText: 'Título del premio'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descripcionController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Descripción'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _puntosController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Puntos necesarios'),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _seleccionarImagen,
              icon: const Icon(Icons.image),
              label: const Text('Seleccionar Imagen'),
            ),
            if (_imagenBytes != null) ...[
              const SizedBox(height: 12),
              Image.memory(_imagenBytes!, height: 150),
            ],
            const SizedBox(height: 24),
            _subiendo
                ? const CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: _crearPremio,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF004077),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Crear Premio',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
