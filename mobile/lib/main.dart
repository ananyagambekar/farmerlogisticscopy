import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/user.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/farmer_dashboard.dart';
import 'screens/agent_dashboard.dart';
import 'screens/driver_dashboard.dart';
import 'screens/receiver_dashboard.dart';
import 'screens/admin_dashboard.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DynamicAgriLogisticsApp());
}

class DynamicAgriLogisticsApp extends StatelessWidget {
  const DynamicAgriLogisticsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthService(),
      child: MaterialApp(
        title: 'Dynamic Agri-Logistics',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);

    if (auth.isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.primaryGreen),
              SizedBox(height: 16),
              Text('Initializing Agri-Logistics Mobile...', style: TextStyle(color: AppColors.textMuted)),
            ],
          ),
        ),
      );
    }

    if (!auth.isAuthenticated) {
      return const LoginScreen();
    }

    final user = auth.currentUser!;
    switch (user.role) {
      case UserRole.farmer:
        return const FarmerDashboard();
      case UserRole.agent:
        return const AgentDashboard();
      case UserRole.driver:
        return const DriverDashboard();
      case UserRole.receiver:
        return const ReceiverDashboard();
      case UserRole.admin:
        return const AdminDashboard();
    }
  }
}
