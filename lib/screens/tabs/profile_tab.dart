import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/common/custom_button.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(
              user?.name.substring(0, 1).toUpperCase() ?? "U",
              style: const TextStyle(fontSize: 40, color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 24),

          _buildInfoTile(Icons.person, "Nom", user?.name ?? "Utilisateur"),
          _buildInfoTile(Icons.email, "Email", user?.email ?? "Non defini"),

          const SizedBox(height: 40),

          CustomButton(
            text: "Se deconnecter",
            color: AppColors.error,
            isOutlined: true,
            icon: Icons.logout,
            onPressed: () => _handleLogout(context, authProvider),
          ),

          const SizedBox(height: 12),
          Text(
            "Version 1.0.0",
            style: TextStyle(color: AppColors.textDisable, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textDisable)),
      subtitle: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
    );
  }

  void _handleLogout(BuildContext context, AuthProvider auth) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Deconnexion"),
        content: const Text("Etes-vous sur de vouloir vous deconnecter ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Annuler")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Oui, deconnexion", style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await auth.logout();
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }
}