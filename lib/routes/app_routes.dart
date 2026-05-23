import 'package:flutter/material.dart';
import '../views/auth/login_page.dart';
import '../views/auth/register_page.dart';
import '../views/home/home_page.dart';
import '../views/transactions/transaction_list_page.dart';
import '../views/transactions/transaction_detail_page.dart';
import '../views/budget/budget_page.dart';
import '../views/report/report_page.dart';
import '../models/transaction_model.dart';

class AppRoutes {
  AppRoutes._();
  static const String login = '/';
  static const String home = '/home';
  static const String register = '/register';

  static Map<String, WidgetBuilder> routes = {
    login:      (context) => const LoginPage(),
    home:       (context) => const HomePage(),
    register:   (context) => const RegisterPage(),
    '/history': (context) => const TransactionListPage(),
    '/budget':  (context) => const BudgetPage(),
    '/report':  (context) => const ReportPage(),
    '/detail':  (context) {
      // Protege contra refresh da pagina no browser (argumento fica null)
      final t = ModalRoute.of(context)?.settings.arguments;
      if (t == null || t is! TransactionModel) {
        return const HomePage();
      }
      return TransactionDetailPage(transacao: t);
    },
  };
}
