import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../providers/catalogo_provider.dart';
import 'catalogo_detalle_screen.dart';

class CatalogoScreen extends StatefulWidget {
  const CatalogoScreen({super.key});

  @override
  State<CatalogoScreen> createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends State<CatalogoScreen> {
  final marcaController = TextEditingController();
  final modeloController = TextEditingController();
  final anioController = TextEditingController();
  final precioMinController = TextEditingController();
  final precioMaxController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<CatalogoProvider>().cargarCatalogo();
    });
  }

  @override
  void dispose() {
    marcaController.dispose();
    modeloController.dispose();
    anioController.dispose();
    precioMinController.dispose();
    precioMaxController.dispose();
    super.dispose();
  }

  String _safeText(dynamic value) {
    if (value == null) return '-';
    final text = value.toString().trim();
    return text.isEmpty ? '-' : text;
  }

  Future<void> _buscar() async {
    await context.read<CatalogoProvider>().cargarCatalogo(
          marca: marcaController.text.trim(),
          modelo: modeloController.text.trim(),
          anio: anioController.text.trim(),
          precioMin: precioMinController.text.trim(),
          precioMax: precioMaxController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CatalogoProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: marcaController,
              decoration: const InputDecoration(
                labelText: 'Marca',
                prefixIcon: Icon(Icons.sell_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: modeloController,
              decoration: const InputDecoration(
                labelText: 'Modelo',
                prefixIcon: Icon(Icons.directions_car_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: anioController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Año',
                prefixIcon: Icon(Icons.calendar_today_outlined),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: precioMinController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Precio mín.',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: precioMaxController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Precio máx.',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _buscar,
              icon: const Icon(Icons.search),
              label: const Text('Buscar'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.errorMessage.isNotEmpty && provider.items.isEmpty
                      ? Center(child: Text(provider.errorMessage))
                      : provider.items.isEmpty
                          ? const Center(
                              child: Text('No hay resultados en el catálogo'),
                            )
                          : RefreshIndicator(
                              onRefresh: _buscar,
                              child: ListView.separated(
                                itemCount: provider.items.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (_, i) {
                                  final item = provider.items[i];

                                  return Card(
                                    child: ListTile(
                                      leading: Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withOpacity(0.14),
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        child: const Icon(
                                          Icons.directions_car,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      title: Text(
                                        '${_safeText(item.marca)} ${_safeText(item.modelo)}',
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      subtitle: Text(
                                        'Año: ${_safeText(item.anio)}\nPrecio: ${_safeText(item.precio)}',
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      isThreeLine: true,
                                      trailing: const Icon(
                                        Icons.arrow_forward_ios,
                                        size: 16,
                                      ),
                                      onTap: item.id == null
                                          ? null
                                          : () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      CatalogoDetalleScreen(
                                                    itemId: item.id!,
                                                  ),
                                                ),
                                              );
                                            },
                                    ),
                                  );
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}