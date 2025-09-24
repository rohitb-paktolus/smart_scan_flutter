import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_scan_flutter/home/home_screen.dart';
import 'package:smart_scan_flutter/login/login_bloc/login_bloc.dart';
import 'package:smart_scan_flutter/login/login_email_screen.dart';
import 'package:smart_scan_flutter/login/repository/login_repository.dart';
import 'package:smart_scan_flutter/registration/bloc/registration_bloc.dart';
import 'package:smart_scan_flutter/registration/registration.dart';
import 'package:smart_scan_flutter/registration/repository/registration_repository.dart';
import 'package:smart_scan_flutter/splash_screen.dart';
import 'package:smart_scan_flutter/utils/prefs.dart';
import 'package:smart_scan_flutter/utils/route.dart';

import 'forgot_password/forgot_password_bloc/forgot_password_bloc.dart';
import 'forgot_password/forgot_password_screen.dart';
import 'forgot_password/repository/forgot_password_repository.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Prefs.init();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<RegistrationBloc>(
          create: (context) => RegistrationBloc(RegistrationRepository()),
        ),
        BlocProvider<LoginEmailBloc>(
          create:
              (context) => LoginEmailBloc(loginRepository: LoginRepository()),
        ),
        BlocProvider<ForgotPasswordBloc>(
          create:
              (context) => ForgotPasswordBloc(
                forgotPasswordRepository: ForgotPasswordRepository(),
              ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: ROUT_SPLASH,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case ROUT_SPLASH:
            return MaterialPageRoute(
              builder: (BuildContext context) {
                return const SafeArea(top: false, bottom: false, child: SplashScreen());
              },
            );
          case ROUT_LOGIN_EMAIL:
            return MaterialPageRoute(
              builder: (BuildContext context) {
                return const SafeArea(top: false, child: LoginEmailScreen());
              },
            );
          case ROUT_REGISTRATION:
            return MaterialPageRoute(
              builder: (BuildContext context) {
                return const SafeArea(top: false, child: Registration());
              },
            );
          case ROUT_FORGOT_PASSWORD:
            return MaterialPageRoute(
              builder: (context) {
                return const SafeArea(
                  top: false,
                  child: ForgotPasswordScreen(),
                );
              },
            );
          case ROUTE_HOME:
            return MaterialPageRoute(
              builder: (BuildContext context) {
                return const SafeArea(
                  top: false,
                  child: HomeScreen(),
                );
              },
            );
        }

        return null;
      },
    );
  }
}
