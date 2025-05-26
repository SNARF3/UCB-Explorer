import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class CrearQRSimpleScreen extends StatefulWidget {
  const CrearQRSimpleScreen({super.key});

  @override
  State<CrearQRSimpleScreen> createState() => _CrearQRSimpleScreenState();
}

class _CrearQRSimpleScreenState extends State<CrearQRSimpleScreen> {
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _contenidoQRController = TextEditingController();
  String? _qrGenerado;
  final GlobalKey _qrKey = GlobalKey();

  void _generarQR() {
    setState(() {
      _qrGenerado = _contenidoQRController.text.trim();
    });
  }

  Future<void> _guardarTodo() async {
    final descripcion = _descripcionController.text.trim();
    final contenidoQR = _qrGenerado;

    if (descripcion.isEmpty || contenidoQR == null || contenidoQR.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
      return;
    }

    try {
      // Capturar imagen PNG del QR
      RenderRepaintBoundary boundary =
          _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Subir a Firebase Storage
      final fileName = 'qr_${DateTime.now().millisecondsSinceEpoch}.png';
      final ref = FirebaseStorage.instance.ref().child('qr_imagenes/$fileName');
      await ref.putData(pngBytes);
      final urlImagen = await ref.getDownloadURL();

      // Guardar en Firestore
      await FirebaseFirestore.instance.collection('qr').add({
        'datos': descripcion,
        'qr': contenidoQR,
        'urlImagen': urlImagen,
        'fecha': Timestamp.now(),
      });

      // Guardar en dispositivo
      await _guardarEnDispositivo(pngBytes);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('QR guardado en Firestore, Storage y dispositivo'),
        ),
      );

      setState(() {
        _descripcionController.clear();
        _contenidoQRController.clear();
        _qrGenerado = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
    }
  }

  Future<void> _guardarEnDispositivo(Uint8List bytes) async {
    final status = await Permission.storage.request();
    if (!status.isGranted) return;

    final directory = await getApplicationDocumentsDirectory();
    final path =
        '${directory.path}/qr_${DateTime.now().millisecondsSinceEpoch}.png';
    final file = File(path);
    await file.writeAsBytes(bytes);
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
              decoration: InputDecoration(
                labelText: 'Descripción del QR',
                labelStyle: const TextStyle(color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFFFD700), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _contenidoQRController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Contenido del QR (texto, URL, ID...)',
                labelStyle: const TextStyle(color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFFFD700), width: 2),
                ),
              ),
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
                  ElevatedButton(
                    onPressed: _guardarTodo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                    ),
                    child: const Text(
                      'Guardar y Descargar',
                      style: TextStyle(
                        color: Color(0xFF004077),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
