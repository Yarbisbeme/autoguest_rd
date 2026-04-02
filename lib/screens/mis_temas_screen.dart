import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/foro_provider.dart';
import 'foro_detalle_screen.dart';

class MisTemasScreen extends StatefulWidget {
  const MisTemasScreen({super.key});

  @override
  State<MisTemasScreen> createState() => _MisTemasScreenState();
}

class _MisTemasScreenState extends State<MisTemasScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ForoProvider>().cargarMisTemas();
    });
  }

  String _safeText(dynamic value) {
    if (value == null) return '-';
    final text = value.toString().trim();
    return text.isEmpty ? '-' : text;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ForoProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis temas'),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.misTemas.isEmpty
              ? Center(
                  child: Text(
                    provider.errorMessage.isNotEmpty
                        ? provider.errorMessage
                        : 'No tienes temas creados',
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => context.read<ForoProvider>().cargarMisTemas(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.misTemas.length,
                    itemBuilder: (_, i) {
                      final tema = provider.misTemas[i];

                      return Card(
                        child: ListTile(
                          title: Text(_safeText(tema['titulo'])),
                          subtitle: Text(
                            '${_safeText(tema['vehiculo'])}\n'
                            'Respuestas: ${_safeText(tema['totalRespuestas'])}\n'
                            'Última respuesta: ${_safeText(tema['ultimaRespuesta'])}',
                          ),
                          isThreeLine: true,
                          trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                          onTap: tema['id'] == null
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ForoDetalleScreen(
                                        temaId: tema['id'],
                                      ),
                                    ),
                                  );
                                },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}