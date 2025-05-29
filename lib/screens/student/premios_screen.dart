import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PremiosScreen extends StatefulWidget {
  const PremiosScreen({super.key});

  @override
  State<PremiosScreen> createState() => _PremiosScreenState();
}

class _PremiosScreenState extends State<PremiosScreen> {
  List<dynamic> premios = [];
  bool cargando = true;
  double filtroPuntos = 0;
  String? userId;
  int puntosUsuario = 0;

  @override
  void initState() {
    super.initState();
    _inicializarUsuario();
  }

  Future<void> _inicializarUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('userId');
    if (id != null) {
      setState(() => userId = id);
      await _obtenerPuntosUsuario();
      await _cargarPremios();
    }
  }

  Future<void> _obtenerPuntosUsuario() async {
    final doc =
        await FirebaseFirestore.instance
            .collection('estudiantes')
            .doc(userId)
            .get();
    final data = doc.data();
    if (data != null) {
      setState(() {
        puntosUsuario = (data['puntos'] as num?)?.toInt() ?? 0;
      });
    }
  }

  Future<void> _cargarPremios() async {
    setState(() => cargando = true);
    try {
      final data = await Supabase.instance.client
          .from('premios')
          .select()
          .eq('activo', true)
          .gte('puntos', filtroPuntos.toInt())
          .order('puntos', ascending: true);

      setState(() {
        premios = data;
        cargando = false;
      });
    } catch (e) {
      debugPrint('❌ Error al cargar premios: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cargar premios')),
        );
      }
    }
  }

  Future<void> _canjearPremio(Map premio) async {
    final int costo = premio['puntos'];

    if (puntosUsuario >= costo) {
      final nuevoPuntaje = puntosUsuario - costo;
      await FirebaseFirestore.instance
          .collection('estudiantes')
          .doc(userId)
          .update({'puntos': nuevoPuntaje});

      setState(() => puntosUsuario = nuevoPuntaje);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('🎁 Premio canjeado: ${premio['titulo']}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ No tienes suficientes puntos')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Premios (${puntosUsuario} pts)',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF004077),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await _obtenerPuntosUsuario();
              await _cargarPremios();
            },
            tooltip: 'Actualizar premios',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Text(
                  'Filtrar por mínimo de puntos:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Slider(
                    min: 0,
                    max: 10000,
                    divisions: 20,
                    value: filtroPuntos,
                    label: '${filtroPuntos.toInt()} pts',
                    onChanged: (value) {
                      setState(() => filtroPuntos = value);
                    },
                    onChangeEnd: (_) => _cargarPremios(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child:
                cargando
                    ? const Center(child: CircularProgressIndicator())
                    : premios.isEmpty
                    ? const Center(child: Text("No hay premios disponibles"))
                    : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.75,
                          ),
                      itemCount: premios.length,
                      itemBuilder: (context, index) {
                        final premio = premios[index];
                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12),
                                  ),
                                  child: Image.network(
                                    premio['imagen_url'],
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorBuilder:
                                        (_, __, ___) => const Center(
                                          child: Icon(Icons.broken_image),
                                        ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Text(
                                      premio['titulo'],
                                      style: const TextStyle(
                                        color: Color(0xFF004077),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${premio['puntos']} Puntos',
                                      style: const TextStyle(
                                        color: Colors.orange,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ElevatedButton(
                                      onPressed: () => _canjearPremio(premio),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF004077,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                      child: const Text('Canjear'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
