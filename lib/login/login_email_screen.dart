import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:smart_scan_flutter/login/login_bloc/login_bloc.dart';
import 'package:smart_scan_flutter/login/models/login_details.dart';
import 'package:smart_scan_flutter/widgets/custom_alert.dart';

import 'package:smart_scan_flutter/utils/pref_key.dart';
import 'package:smart_scan_flutter/utils/prefs.dart';
import '../../utils/route.dart';
import '../../utils/validation.dart';
import '../../widgets/custom_text.dart';

class LoginEmailScreen extends StatefulWidget {
  const LoginEmailScreen({super.key});

  @override
  State<LoginEmailScreen> createState() => _LoginEmailScreenState();
}

class _LoginEmailScreenState extends State<LoginEmailScreen> {
  bool _obscureText = true;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final _formEmailKey = GlobalKey<FormState>();
  Color buttonColor = const Color(0xFF88C2F7); // Initialize the button color
  String passwordErrorText = '';
  String emailErrorText = '';
  bool isButtonEnabled = false;
  bool clickLogin = false;
  int loginAttemptCount = 2;
  bool isBiometricDialogVisible = false;

  GlobalKey<State> loadingDialogKey = GlobalKey();

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          surfaceTintColor: Colors.white,
          shadowColor: Colors.white,
          key: loadingDialogKey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(19),
          ),
          child: Container(
            height: 180,
            padding: const EdgeInsets.all(16),
            child: const Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                      strokeWidth: 10.0,
                      color: Color(0xFF2986CC),
                      strokeCap: StrokeCap.round),
                  SizedBox(height: 24),
                  Text(
                    'Please Wait...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF171717),
                      fontSize: 20,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.40,
                    ),
                  ),
                ]),
          ),
        );
      },
    );
  }

  void hideLoadingDialog() {
    if (loadingDialogKey.currentContext != null) {
      Navigator.of(loadingDialogKey.currentContext!, rootNavigator: true).pop();
    }
  }

  @override
  void initState() {
    String savedEmail = Prefs.getString(SAVED_EMAIL);
    if (savedEmail.isNotEmpty) {
      emailController.text = Prefs.getString(SAVED_EMAIL);
    }

    super.initState();
  }

  void _updateButtonColor() {
    setState(() {
      bool isEmailValid = Validator.emailValidate(emailController.text);
      bool isPasswordValid =
      Validator.emptyFieldValidate(passwordController.text);
      isButtonEnabled = isEmailValid && isPasswordValid;
      buttonColor =
      isButtonEnabled ? const Color(0xFF2986CC) : const Color(0xFF88C2F7);
    });
  }

  void _onButtonPressed() async {
    showLoadingDialog(context);
    setState(() {
      clickLogin = true;
    });
    FocusScope.of(context).requestFocus(FocusNode());
    // String? fcmToken = Prefs.getString(FCM_TOKEN);
    LoginDetails loginDetails = LoginDetails(
      emailAddress: emailController.text,
      password: passwordController.text,
    );
    print("Login details");
    print(loginDetails.toJson());
    context.read<LoginEmailBloc>().add(LoginUser(loginDetails: loginDetails));
    // Navigator.pushReplacementNamed(context, ROUT_DASHBOARD);
    /*LoginRequest loginRequest = LoginRequest(
      email: emailController.text,
      password: passwordController.text,
      pushNotificationToken: fcmToken,
    );
    BlocProvider.of<AuthenticationBloc>(context)
        .add(LoginUser(loginRequest: loginRequest));*/
  }

  void _showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlert(
          title: "Error",
          message: errorMessage,
          buttonText: "OK",
          onButtonTap: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginEmailBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          // Set login flag to true
          print("LoginSuccess");
          hideLoadingDialog();
          clickLogin = false;
          print(state.loginResponse.toJson());
          Prefs.setBool(LOGIN_FLAG, true);
          // Navigate to Dashboard
          Navigator.of(context).pushNamedAndRemoveUntil(
            ROUTE_HOME,
                (route) => false,
          );
        } else if (state is LoginError) {
          hideLoadingDialog();
          clickLogin = false;
          print("login error");
          _showErrorDialog(context, state.error);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFFFFFFF),
          body: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Stack(children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Form(
                    key: _formEmailKey,
                    child: Container(
                        width: double.infinity,
                        height: null,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(19),
                          color: const Color(0xFFFFFFFF),
                        ),
                        child: Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 48),
                              child: CustomText(
                                  text: 'Login',
                                  fontSize: 24,
                                  desiredLineHeight: 29.05,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF262626)),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 16.0,
                                  right: 16.0,
                                  top: 32.0,
                                  bottom: 32.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: const Color(0xFFE5E5E5),
                                          width: 1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: TextFormField(
                                        controller: emailController,
                                        onChanged: (value) {
                                          setState(() {
                                            emailErrorText = Validator
                                                .emailValidate(value)
                                                ? ''
                                                : 'Please enter a valid email address';
                                          });
                                          _updateButtonColor();
                                        },
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          color: Color(0xFF171717),
                                          fontWeight: FontWeight.w400,
                                          height: 1.25,
                                          fontSize: 16,
                                        ),
                                        decoration: const InputDecoration(
                                          labelText: 'Email',
                                          labelStyle: TextStyle(
                                            color: Color(0xFF737373),
                                          ),
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Visibility(
                                    visible: emailErrorText.isNotEmpty,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 4, top: 12.0),
                                      child: Row(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: SvgPicture.asset(
                                                'assets/icons/error_icon.svg',
                                                height: 12.67,
                                                width: 12.67,
                                                alignment: Alignment.center,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 4,
                                            ),
                                            Expanded(
                                              child: CustomText(
                                                text: emailErrorText,
                                                fontSize: 12,
                                                desiredLineHeight: 16,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w500,
                                                color: const Color(0xFFF85A5A),
                                              ),
                                            ),
                                          ]),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: const Color(0xFFE5E5E5),
                                          width: 1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Stack(children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8.0, right: 46),
                                        child: TextFormField(
                                          controller: passwordController,
                                          obscureText: _obscureText,
                                          onChanged: (value) {
                                            setState(() {
                                              passwordErrorText =
                                              Validator.emptyFieldValidate(
                                                  value)
                                                  ? ''
                                                  : '';
                                            });
                                            _updateButtonColor();
                                          },
                                          style: const TextStyle(
                                            fontFamily: 'Inter',
                                            color: Color(0xFF171717),
                                            fontWeight: FontWeight.w400,
                                            height: 1.25,
                                            fontSize: 16,
                                          ),
                                          decoration: const InputDecoration(
                                            labelText: 'Password',
                                            labelStyle: TextStyle(
                                              color: Color(0xFF737373),
                                            ),
                                            border: InputBorder.none,
                                          ),
                                          keyboardType:
                                          TextInputType.visiblePassword,
                                          textInputAction: TextInputAction.done,
                                        ),
                                      ),
                                      Positioned(
                                        right: 14,
                                        top: 0,
                                        bottom: 0,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _obscureText = !_obscureText;
                                            });
                                          },
                                          child: Icon(
                                            _obscureText
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                            color: const Color(0xffa3a3a3),
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                    ]),
                                  ),
                                  Visibility(
                                    visible: passwordErrorText.isNotEmpty,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 4, top: 12.0),
                                      child: Row(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: SvgPicture.asset(
                                                'assets/icon/error_icon.svg',
                                                height: 12.67,
                                                width: 12.67,
                                                alignment: Alignment.center,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 4,
                                            ),
                                            Expanded(
                                              child: CustomText(
                                                text: passwordErrorText,
                                                fontSize: 12,
                                                desiredLineHeight: 16,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w500,
                                                color: const Color(0xFFF85A5A),
                                              ),
                                            ),
                                          ]),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 32,
                                  ),
                                  Container(
                                    width: double.infinity,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: buttonColor,
                                    ),
                                    child: TextButton(
                                      onPressed: isButtonEnabled
                                          ? _onButtonPressed
                                          : null,
                                      child: const CustomText(
                                          text: 'Login',
                                          fontSize: 16,
                                          desiredLineHeight: 24,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFFFFFFFF)),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.pushNamed(
                                            context, ROUT_FORGOT_PASSWORD);
                                      },
                                      child: const CustomText(
                                          text: 'Forgot Password?',
                                          fontSize: 12,
                                          desiredLineHeight: 14.52,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xFF737373)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                            text: 'New User? ',
                            style: const TextStyle(
                              color: Color(0xFF737373),
                              fontSize: 14,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              height: 16.94 / 14.0,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Register here',
                                style: const TextStyle(
                                    color: Color(0xFF737373),
                                    fontSize: 13,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                    height: 16.94 / 13.0),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () async {
                                    Navigator.pushNamed(
                                        context, ROUT_REGISTRATION);
                                  },
                              ),
                            ]),
                      ),
                    ),
                  ),
                ],
              ),
              Center(
                child: Visibility(
                  visible: clickLogin,
                  child: const CircularProgressIndicator(
                    color: Color(0XFFF85A5A),
                  ),
                ),
              ),
            ]),
          ),
        );
      },
    );
  }
}
