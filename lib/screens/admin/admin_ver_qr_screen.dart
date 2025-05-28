import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/rendering.dart';

class AdminVerQRScreen extends StatefulWidget {
  const AdminVerQRScreen({super.key});

  @override
  State<AdminVerQRScreen> createState() => _AdminVerQRScreenState();
}

class _AdminVerQRScreenState extends State<AdminVerQRScreen> {
  final supabase = Supabase.instance.client;
  List<dynamic> qrList = [];
  bool loading = true;
  bool _mounted = true;

  final GlobalKey _qrKey = GlobalKey();
  String? _newQRContent;

  @override
  void initState() {
    super.initState();
    _cargarQRs();
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> _cargarQRs() async {
    setState(() => loading = true);
    try {
      final response = await supabase
          .from('qr_data')
          .select()
          .order('creado_en', ascending: false);
      if (_mounted) {
        setState(() {
          qrList = response;
          loading = false;
        });
      }
    } catch (e) {
      print('❌ Error cargando QRs: $e');
      setState(() => loading = false);
    }
  }

  Future<Uint8List?> _capturarQRBytes(String data) async {
    try {
      final repaintBoundary = RenderRepaintBoundary();
      final qrPainter = QrPainter(
        data: data,
        version: QrVersions.auto,
        gapless: true,
        color: const Color(0xFF000000),
        emptyColor: const Color(0xFFFFFFFF),
      );
      final image = await qrPainter.toImage(300);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print('❌ Error generando nueva imagen QR: $e');
      return null;
    }
  }

  Future<void> _editarQRCompleto(Map item) async {
    final TextEditingController descripcionController = TextEditingController(
      text: item['descripcion'],
    );
    final TextEditingController contenidoQRController = TextEditingController(
      text: item['qr'],
    );

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Editar QR'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: descripcionController,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                ),
                TextField(
                  controller: contenidoQRController,
                  decoration: const InputDecoration(labelText: 'Contenido QR'),
                ),
              ],
            ),
            actions: [
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                child: const Text('Guardar'),
                onPressed: () async {
                  final nuevaDescripcion = descripcionController.text.trim();
                  final nuevoContenido = contenidoQRController.text.trim();
                  final nuevoQR = await _capturarQRBytes(nuevoContenido);
                  if (nuevoQR == null) return;

                  final fileName =
                      'qr_${DateTime.now().millisecondsSinceEpoch}.png';
                  final upload = await supabase.storage
                      .from('basedispos')
                      .uploadBinary(
                        fileName,
                        nuevoQR,
                        fileOptions: const FileOptions(
                          contentType: 'image/png',
                        ),
                      );
                  final newUrl = supabase.storage
                      .from('basedispos')
                      .getPublicUrl(fileName);

                  await supabase
                      .from('qr_data')
                      .update({
                        'descripcion': nuevaDescripcion,
                        'qr': nuevoContenido,
                        'url': newUrl,
                      })
                      .eq('id', item['id']);

                  if (_mounted) {
                    Navigator.pop(context);
                    await _cargarQRs();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ QR y descripción actualizados'),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
    );
  }

  Future<void> _eliminarQR(String id) async {
    try {
      await supabase.from('qr_data').delete().eq('id', id);
      await _cargarQRs();
      if (_mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('🗑️ QR eliminado')));
      }
    } catch (e) {
      print('❌ Error al eliminar QR: $e');
    }
  }

  void _mostrarQRGrande(String url) {
    showDialog(
      context: context,
      builder:
          (_) => Dialog(
            backgroundColor: Colors.transparent,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: InteractiveViewer(
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  errorBuilder:
                      (context, error, stackTrace) => const Icon(
                        Icons.broken_image,
                        size: 100,
                        color: Colors.white,
                      ),
                ),
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF004077),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Ver y Editar QRs',
          style: TextStyle(color: Color(0xFFFFD700)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFFFD700)),
      ),
      body:
          loading
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFFFD700)),
              )
              : ListView.builder(
                itemCount: qrList.length,
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final item = qrList[index];
                  final url = item['url'];

                  return Card(
                    color: Colors.white,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading:
                          url != null && url.toString().startsWith('http')
                              ? GestureDetector(
                                onTap: () => _mostrarQRGrande(url),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    url,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.broken_image,
                                              size: 40,
                                            ),
                                  ),
                                ),
                              )
                              : const Icon(Icons.image_not_supported, size: 40),
                      title: Text(item['descripcion']),
                      subtitle: Text(item['qr']),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Color(0xFF004077),
                            ),
                            onPressed: () => _editarQRCompleto(item),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _eliminarQR(item['id']),
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
