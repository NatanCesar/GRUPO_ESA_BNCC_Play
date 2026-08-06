import 'package:flutter/material.dart';

import '../features/auth/forgot_password_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_student_screen.dart';
import '../features/auth/register_teacher_screen.dart';
import '../features/auth/register_type_screen.dart';
import '../features/auth/splash_screen.dart';
import '../features/game/game_screen.dart';
import '../features/game/resultado_screen.dart';
import '../features/home/home_student_screen.dart';
import '../features/home/home_teacher_screen.dart';
import '../features/profile/edit_profile_screen.dart';
import '../features/profile/profile_student_screen.dart';
import '../features/profile/profile_teacher_screen.dart';
import '../features/questions/axis_selection_screen.dart';
import '../features/questions/question_list_screen.dart';
import '../features/questions/question_form_screen.dart';
import '../features/ranking/ranking_screen.dart';
import '../features/sala/sala_screen.dart';
import '../data/models/partida.dart';

/// Nomes de rota do app.
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
  static const jogar = '/jogar';
  static const resultado = '/resultado';
  static const ranking = '/ranking';
  static const sala = '/sala';

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
        ranking: (ctx) {
          final args = ModalRoute.of(ctx)!.settings.arguments as Map?;
          return RankingScreen(
            alunoId: args?['alunoId'] as int? ?? 0,
          );
        },
        sala: (_) => const SalaScreen(),
      };

  /// Rota para a tela de jogo — passa argumentos via arguments.
  static Route<dynamic> gerarRotaJogar(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>;
    return MaterialPageRoute(
      builder: (_) => GameScreen(
        alunoId: args['alunoId'] as int,
        apelido: args['apelido'] as String,
        eixo: args['eixo'] as String?,
      ),
    );
  }

  /// Rota para a tela de resultado.
  static Route<dynamic> gerarRotaResultado(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>;
    return MaterialPageRoute(
      builder: (_) => ResultadoScreen(
        partida: args['partida'] as Partida,
        apelido: args['apelido'] as String,
      ),
    );
  }
}
