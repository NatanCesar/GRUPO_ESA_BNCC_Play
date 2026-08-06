import 'package:flutter/material.dart';

import '../features/auth/login_screen.dart';
import '../features/auth/register_teacher_screen.dart';
import '../features/auth/splash_screen.dart';
import '../features/home/home_student_screen.dart';
import '../features/home/home_teacher_screen.dart';
import '../features/profile/profile_student_screen.dart';
import '../features/profile/profile_teacher_screen.dart';

/// Nomes de rota do app.
///
/// A tabela cresce a cada tarefa do ciclo; manter aqui a lista inteira
/// evita string de rota espalhada pelas telas.
abstract final class Rotas {
  static const splash = '/';
  static const login = '/login';
  static const registerType = '/cadastro';
  static const registerTeacher = '/cadastro/professor';
  static const registerStudent = '/cadastro/aluno';
  static const forgotPassword = '/esqueci-senha';
  static const homeTeacher = '/professor';
  static const homeStudent = '/aluno';
  static const profileTeacher = '/professor/perfil';
  static const profileStudent = '/aluno/perfil';
  static const editProfile = '/perfil/editar';

  static Map<String, WidgetBuilder> tabela() => <String, WidgetBuilder>{
        splash: (_) => const SplashScreen(),
        login: (_) => const LoginScreen(),
        registerTeacher: (_) => const RegisterTeacherScreen(),
        homeTeacher: (_) => const HomeTeacherScreen(),
        homeStudent: (_) => const HomeStudentScreen(),
        profileTeacher: (_) => const ProfileTeacherScreen(),
        profileStudent: (_) => const ProfileStudentScreen(),
      };
}
