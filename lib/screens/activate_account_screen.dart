import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';
import 'login_screen.dart';


class ActivateAccountScreen extends StatefulWidget {
  final String tokenTemporalInicial;

  const ActivateAccountScreen({
    super.key,
    this.tokenTemporalInicial = '',
  });

  @override
  State<ActivateAccountScreen> createState() => _ActivateAccountScreenState();
}

class _ActivateAccountScreenState extends State<ActivateAccountScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController tokenController;
  final TextEditingController contrasenaController = TextEditingController();
  final TextEditingController confirmarContrasenaController =
      TextEditingController();

  bool ocultarPassword = true;
  bool ocultarConfirmacion = true;

  @override
  void initState() {
    super.initState();
    tokenController = TextEditingController(text: widget.tokenTemporalInicial);
  }

  @override
  void dispose() {
    tokenController.dispose();
    contrasenaController.dispose();
    confirmarContrasenaController.dispose();
    super.dispose();
  }

  Future<void> _activar() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.activarManual(
      tokenTemporal: tokenController.text.trim(),
      contrasena: contrasenaController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cuenta activada correctamente'),
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage),
        ),
      );
    }
  }

  void _irAlLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activar cuenta'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const SizedBox(height: 12),
                const Text(
                  'Ingresa el token temporal recibido en el registro y define una contraseña nueva.',
                  style: TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: tokenController,
                  decoration: const InputDecoration(
                    labelText: 'Token temporal',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingrese el token temporal';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: contrasenaController,
                  obscureText: ocultarPassword,
                  decoration: InputDecoration(
                    labelText: 'Nueva contraseña',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          ocultarPassword = !ocultarPassword;
                        });
                      },
                      icon: Icon(
                        ocultarPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingrese una contraseña';
                    }
                    if (value.length < 6) {
                      return 'Debe tener al menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: confirmarContrasenaController,
                  obscureText: ocultarConfirmacion,
                  decoration: InputDecoration(
                    labelText: 'Confirmar contraseña',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          ocultarConfirmacion = !ocultarConfirmacion;
                        });
                      },
                      icon: Icon(
                        ocultarConfirmacion
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Confirme la contraseña';
                    }
                    if (value != contrasenaController.text.trim()) {
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: authProvider.isLoading ? null : _activar,
                    child: authProvider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Activar cuenta'),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: authProvider.isLoading ? null : _irAlLogin,
                  child: const Text('Volver al login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}