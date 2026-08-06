import 'package:flutter/material.dart';

import '../features/auth/forgot_password_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_student_screen.dart';
import '../features/auth/register_teacher_screen.dart';
import '../features/auth/register_type_screen.dart';
import '../features/auth/splash_screen.dart';
import '../features/home/home_student_screen.dart';
import '../features/home/home_teacher_screen.dart';
import '../features/profile/edit_profile_screen.dart';
import '../features/profile/profile_student_screen.dart';
import '../features/profile/profile_teacher_screen.dart';
import '../features/questions/axis_selection_screen.dart';
import '../features/questions/question_list_screen.dart';
import '../features/questions/question_form_screen.dart';

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
  static const axisSelection = '/professor/eixo';
  static const questionList = '/professor/questoes';
  static const questionCreate = '/professor/questao/nova';
  static const questionEdit = '/professor/questao/editar';

  static Map<String, WidgetBuilder> tabela() => <String, WidgetBuilder>{
        splash: (_) => const SplashScreen(),
        login: (_) => const LoginScreen(),
        registerType: (_) => const RegisterTypeScreen(),
        registerTeacher: (_) => const RegisterTeacherScreen(),
        registerStudent: (_) => const RegisterStudentScreen(),
        homeTeacher: (_) => const HomeTeacherScreen(),
        homeStudent: (_) => const HomeStudentScreen(),
        profileTeacher: (_) => const ProfileTeacherScreen(),
        profileStudent: (_) => const ProfileStudentScreen(),
        editProfile: (_) => const EditProfileScreen(),
        forgotPassword: (_) => const ForgotPasswordScreen(),
        axisSelection: (_) => const AxisSelectionScreen(),
        questionList: (_) => const QuestionListScreen(),
        questionCreate: (_) => const QuestionFormScreen(),
        questionEdit: (ctx) => QuestionFormScreen(
          questaoId: ModalRoute.of(ctx)!.settings.arguments as int?,
        ),
      };
}
