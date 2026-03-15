class RouteNames {
  RouteNames._();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  static const String dashboard = '/dashboard';

  static const String startupList = '/startups';
  static const String startupDetail = '/startups/:startupId';
  static const String createStartup = '/startups/create';
  static const String editStartup = '/startups/:startupId/edit';

  static const String roundList = '/startups/:startupId/rounds';
  static const String roundDetail = '/startups/:startupId/rounds/:roundId';
  static const String createRound = '/startups/:startupId/rounds/create';

  static const String invest = '/startups/:startupId/rounds/:roundId/invest';

  static const String myInvestments = '/my-investments';
  static const String profile = '/profile';

  static const String adminPanel = '/admin';
  static const String adminStartupDetail = '/admin/startups/:startupId';
}