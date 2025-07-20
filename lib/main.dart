// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'services/firebase_teacher_service.dart';
import 'services/firebase_auth_service.dart';
import 'utils/app_theme.dart';
import 'models/teacher_model.dart';
import 'screens/auth/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const PrintPayApp());
}

class PrintPayApp extends StatelessWidget {
  const PrintPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FirebaseAuthService>(create: (_) => FirebaseAuthService()),
        ChangeNotifierProvider<FirebaseTeacherService>(
          create: (_) => FirebaseTeacherService(),
        ),
        StreamProvider<List<Teacher>>(
          create: (context) =>
              context.read<FirebaseTeacherService>().getTeachers(),
          initialData: [],
        ),
      ],
      child: MaterialApp(
        title: 'PrintPay',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: AuthWrapper(),
        routes: {
          '/login': (context) => LoginScreen(),
          '/dashboard': (context) => DashboardScreen(),
        },
      ),
    );
  }
}
