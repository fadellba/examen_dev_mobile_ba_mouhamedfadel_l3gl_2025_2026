import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.register(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } else if (authProvider.error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.error!), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text("Inscription")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [

                CustomTextField(
                  label: "Nom complet",
                  controller: _nameController,
                  prefixIcon: Icons.person_outline,
                  validator: (value) => (value == null || value.length < 2)
                      ? "Le nom doit faire au moins 2 caractères" : null,
                ),
                const SizedBox(height: 20),

                CustomTextField(
                  label: "Email",
                  controller: _emailController,
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => (value == null || !value.contains('@'))
                      ? "Veuillez entrer un email valide" : null,
                ),
                const SizedBox(height: 20),

                CustomTextField(
                  label: "Mot de passe",
                  controller: _passwordController,
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  validator: (value) => (value == null || value.length < 6)
                      ? "Minimum 6 caracteres" : null,
                ),
                const SizedBox(height: 20),

                CustomTextField(
                  label: "Confirmer le mot de passe",
                  controller: _confirmPasswordController,
                  prefixIcon: Icons.lock_reset,
                  obscureText: true,
                  validator: (value) => (value != _passwordController.text)
                      ? "Les mots de passe ne correspondent pas" : null,
                ),
                const SizedBox(height: 40),

                CustomButton(
                  text: "S'inscrire",
                  isLoading: isLoading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}