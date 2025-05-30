import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CrearQRSimpleScreen extends StatefulWidget {
  const CrearQRSimpleScreen({super.key});

  @override
  State<CrearQRSimpleScreen> createState() => _CrearQRSimpleScreenState();
}

class _CrearQRSimpleScreenState extends State<CrearQRSimpleScreen> {
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _contenidoQRController = TextEditingController();
  final GlobalKey _qrKey = GlobalKey();
  String? _qrGenerado;

  void _generarQR() {
    setState(() {
      _qrGenerado = _contenidoQRController.text.trim();
    });
  }

  Future<Uint8List?> _capturarQRBytes() async {
    try {
      await WidgetsBinding.instance.endOfFrame;
      final boundary =
          _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print('❌ Error capturando QR: $e');
      return null;
    }
  }

  Future<void> _subirASupabase() async {
    final descripcion = _descripcionController.text.trim();
    final contenido = _qrGenerado;

    if (descripcion.isEmpty || contenido == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
      return;
    }

    final bytes = await _capturarQRBytes();
    if (bytes == null) return;

    try {
      final fileName = 'qr_${DateTime.now().millisecondsSinceEpoch}.png';

      // Subir a Supabase Storage
      final supabase = Supabase.instance.client;
      final response = await supabase.storage
          .from('basedispos')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(contentType: 'image/png'),
          );

      if (response.isEmpty) throw Exception('Error subiendo imagen');

      final url = supabase.storage.from('basedispos').getPublicUrl(fileName);

      // Guardar en base de datos en tabla 'qr_data'
      await supabase.from('qr_data').insert({
        'descripcion': descripcion,
        'qr': contenido,
        'url': url,
        'creado_en': DateTime.now().toIso8601String(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Subido correctamente a Supabase')),
      );

      _descripcionController.clear();
      _contenidoQRController.clear();
      setState(() => _qrGenerado = null);
    } catch (e) {
      print('❌ Error Supabase: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Error: $e')));
    }
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    _contenidoQRController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF004077),
      appBar: AppBar(
        title: const Text(
          'Crear Código QR',
          style: TextStyle(color: Color(0xFFFFD700)),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xFFFFD700)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _descripcionController,
              style: const TextStyle(color: Colors.white),
              decoration: _buildInput('Descripción del QR'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _contenidoQRController,
              style: const TextStyle(color: Colors.white),
              decoration: _buildInput('Contenido del QR'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _generarQR,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
              ),
              child: const Text(
                'Generar QR',
                style: TextStyle(
                  color: Color(0xFF004077),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 30),
            if (_qrGenerado != null)
              Column(
                children: [
                  RepaintBoundary(
                    key: _qrKey,
                    child: QrImageView(
                      data: _qrGenerado!,
                      size: 200,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _subirASupabase,
                    icon: const Icon(
                      Icons.cloud_upload,
                      color: Color(0xFF004077),
                    ),
                    label: const Text('Subir a Supabase'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInput(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFFFD700), width: 2),
      ),
    );
  }
}
