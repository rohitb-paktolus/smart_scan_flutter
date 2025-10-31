import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:smart_scan_flutter/forgot_password/forgot_password_bloc/forgot_password_bloc.dart';
import 'package:smart_scan_flutter/forgot_password/models/forgot_password_get_otp_request.dart';
import 'package:smart_scan_flutter/forgot_password/models/set_new_password_request.dart';
import 'package:smart_scan_flutter/forgot_password/models/verify_otp_request.dart';
import 'package:smart_scan_flutter/widgets/custom_alert.dart';
import 'package:pinput/pinput.dart';

import '../../utils/app_functions.dart';
import '../../utils/route.dart';
import '../../utils/validation.dart';
import '../../widgets/custom_error.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/custom_toast.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  final pinController = TextEditingController();
  final focusNode = FocusNode();

  bool isButtonEnabled = false;
  bool backButtonVisible = true;
  bool clickEmailSubmit = true;
  bool clickOTPSubmit = false;
  bool clickResetPassword = false;
  String emailErrorText = '';
  String otpErrorText = '';

  int timeLeft = 0;
  bool timerStartedOnce = false;
  Timer? timer;
  bool _obscurePasswordText = true;
  bool _obscureConfirmPasswordText = true;
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  Color buttonColor = const Color(0xFF88C2F7);
  Color buttonEmailColor = const Color(0xFF88C2F7);
  Color buttonSetPasswordColor = const Color(0xFF88C2F7);

  String passwordErrorText = '';
  String confirmPasswordText = '';
  bool isVerifyingOTP = false;
  bool isResendCode = false;
  String resendMessage = '';
  int minutes = 1;
  int seconds = 0;

  final defaultPinTheme = PinTheme(
    width: 60,
    height: 70,
    textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
    decoration: BoxDecoration(
      border: Border.all(color: const Color(0xFFEEE7E5), width: 1),
      borderRadius: BorderRadius.circular(9),
    ),
  );

  void _startTimer() {
    timer?.cancel();
    setState(() {
      timerStartedOnce = true;
    });
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft > 0) {
        setState(() {
          timeLeft--;
          minutes = timeLeft ~/ 60;
          seconds = timeLeft % 60;
        });
      } else {
        setState(() {
          minutes = 1;
          seconds = 0;
        });
        timer.cancel();
      }
    });
  }

  bool validateOTP() {
    return pinController.text.length == 4;
  }

  void _updateOTPSubmitColor(String text) {
    setState(() {
      bool isOTPFieldValid = validateOTP();
      isButtonEnabled = isOTPFieldValid;
    });
  }

  void _updateSetPasswordBtnColor() {
    setState(() {
      bool isPasswordValid = Validator.passwordValidate(
        passwordController.text,
      );
      bool isConfirmPassword = Validator.confirmPasswordMatch(
        passwordController.text,
        confirmPasswordController.text,
      );
      isButtonEnabled = isConfirmPassword && isPasswordValid;
      buttonSetPasswordColor =
          isButtonEnabled ? const Color(0xFF2986CC) : const Color(0xFF88C2F7);
    });
  }

  void _showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Error',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _onEmailSubmit() {
    //API call to get OTP
    // add ForgotPasswordSendEmail event
    final forgotPasswordGetOTPRequest = ForgotPasswordGetOTPRequest(
      emailAddress: emailController.text,
    );
    BlocProvider.of<ForgotPasswordBloc>(context).add(
      ForgotPasswordGetOTPEvent(
        forgotPasswordGetOTPRequest: forgotPasswordGetOTPRequest,
      ),
    );
    setState(() {
      isButtonEnabled = false;
    });
    print(emailController.text);
  }

  void _onOTPSubmit() {
    if (!validateOTP()) {
      return;
    } else {
      setState(() {
        isVerifyingOTP = true;
      });

      // int intValue = int.parse(pinController.text);
      //API call to validate otp
      final verifyOTPRequest = VerifyOTPRequest(otp: pinController.text);
      BlocProvider.of<ForgotPasswordBloc>(
        context,
      ).add(VerifyOTPEvent(verifyOTPRequest: verifyOTPRequest));

      setState(() {
        isButtonEnabled = false;
      });
    }
  }

  void _onSetPassword() {
    //API to call set new Password
    final setNewPasswordRequest = SetNewPasswordRequest(
      emailAddress: emailController.text,
      newPassword: passwordController.text,
      confirmPassword: confirmPasswordController.text,
    );
    print(setNewPasswordRequest.toJson());
    BlocProvider.of<ForgotPasswordBloc>(
      context,
    ).add(SetNewPasswordEvent(setNewPasswordRequest: setNewPasswordRequest));
  }

  @override
  void dispose() {
    pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          showExitConfirmationDialog(
            context,
            'Confirm Exit',
            'Do you want to exit the password recovery process?',
            ROUT_SPLASH,
            false,
          );
        }
      },
      child: Scaffold(
        body: BlocConsumer<ForgotPasswordBloc, ForgotPasswordState>(
          listener: (context, state) {
            if (state is ForgotPasswordGetOTPSuccess) {
              // show OTP sheet
              setState(() {
                emailErrorText = '';
                backButtonVisible = false;
                clickEmailSubmit = false;
                clickOTPSubmit = true;
                clickResetPassword = false;
                timeLeft = 60;
                _startTimer();
              });
            } else if (state is ForgotPasswordGetOTPError) {
              // show error dialog
              _showErrorDialog(context, state.error);
            } else if (state is VerifyOTPSuccess) {
              // show Reset password sheet
              setState(() {
                backButtonVisible = false;
                clickEmailSubmit = false;
                clickOTPSubmit = false;
                clickResetPassword = true;
              });
            } else if (state is VerifyOTPError) {
              _showErrorDialog(context, state.error);
            } else if (state is SetNewPasswordSuccess) {
              // Show alert to navigate to login
              showDialog(
                context: context,
                builder:
                    (context) => CustomAlert(
                      title: "Alert",
                      message: "Password changed successfully",
                      buttonText: "Go to Login",
                      onButtonTap:
                          () => Navigator.of(
                            context,
                          ).pushReplacementNamed(ROUT_LOGIN_EMAIL),
                    ),
              );
            } else if (state is SetNewPasswordError) {
              // Show error alert
              _showErrorDialog(context, state.error);
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Visibility(
                      visible: clickEmailSubmit,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 24, right: 24),
                        child: Container(
                          key: _formKey,
                          width: double.infinity,
                          height: null,
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                  left: 16.0,
                                  right: 16.0,
                                  top: 48,
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      "Forgot Password",
                                      style: textTheme.headlineLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'Please enter your email address to receive your One Time Password code.',
                                      textAlign: TextAlign.center,
                                      style: textTheme.bodySmall?.copyWith(
                                        color: colorScheme.secondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 16.0,
                                  right: 16.0,
                                  top: 32.0,
                                  bottom: 32,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: colorScheme.primary,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          left: 8.0,
                                        ),
                                        child: TextFormField(
                                          controller: emailController,
                                          onChanged: (value) {
                                            setState(() {
                                              // Use the EmailValidator to validate and set error text
                                              emailErrorText =
                                                  Validator.emailValidate(value)
                                                      ? ''
                                                      : 'Please enter a valid email address';
                                              if (emailErrorText.isNotEmpty ||
                                                  emailController
                                                      .text
                                                      .isEmpty) {
                                                setState(() {
                                                  isButtonEnabled = false;
                                                });
                                              } else {
                                                setState(() {
                                                  isButtonEnabled = true;
                                                });
                                              }
                                            });
                                          },
                                          style: const TextStyle(
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
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Row(
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
                                            SizedBox(width: 4),
                                            Text(
                                              emailErrorText,
                                              style: textTheme.labelMedium
                                                  ?.copyWith(
                                                    color: colorScheme.error,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 32),
                                    Container(
                                      width: double.infinity,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color:
                                            isButtonEnabled
                                                ? colorScheme.primary
                                                : colorScheme.error,
                                      ),
                                      child: TextButton(
                                        onPressed:
                                            isButtonEnabled
                                                ? _onEmailSubmit
                                                : null,
                                        child: Text(
                                          "Send",
                                          style: textTheme.bodyLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color:
                                                isButtonEnabled
                                                    ? colorScheme.onPrimary
                                                    : colorScheme.onError,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 32),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: clickOTPSubmit,
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                              left: 16.0,
                              right: 16.0,
                              top: 48,
                            ),
                            child: Column(
                              children: [
                                Text(
                                  "Password Recovery",
                                  style: textTheme.headlineLarge?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'A code has been sent to your email.',
                                  style: TextStyle(color: colorScheme.primary),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 16.0,
                              right: 16.0,
                              top: 32.0,
                              bottom: 32,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Visibility(
                                  visible: otpErrorText.isNotEmpty,
                                  child: Column(
                                    children: [
                                      CustomError(errorText: otpErrorText),
                                      const SizedBox(height: 18),
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible: resendMessage.isNotEmpty,
                                  child: Column(
                                    children: [
                                      CustomToast(
                                        text: resendMessage,
                                        freeWidth: 124,
                                      ),
                                      const SizedBox(height: 18),
                                    ],
                                  ),
                                ),
                                Pinput(
                                  controller: pinController,
                                  length: 4,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  focusNode: focusNode,
                                  defaultPinTheme: defaultPinTheme,
                                  focusedPinTheme: defaultPinTheme.copyWith(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: colorScheme.primary,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(9),
                                    ),
                                  ),
                                  onChanged:
                                      (value) => _updateOTPSubmitColor(value),
                                ),
                                const SizedBox(height: 10),
                                Visibility(
                                  visible: otpErrorText.isNotEmpty,
                                  child: CustomText(
                                    text: otpErrorText,
                                    fontSize: 12,
                                    desiredLineHeight: 16,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFFF85A5A),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                const SizedBox(height: 32),
                                Column(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        // If timeLeft > 0, do nothing
                                        if (timeLeft == 0) {
                                          setState(() {
                                            isResendCode = true;
                                            //   set timeLeft to 60 and start timer once the code is sent successfully
                                            timeLeft = 60;
                                            _startTimer();
                                          });
                                          final forgotPasswordGetOTPRequest =
                                              ForgotPasswordGetOTPRequest(
                                                emailAddress:
                                                    emailController.text,
                                              );
                                          BlocProvider.of<ForgotPasswordBloc>(
                                            context,
                                          ).add(
                                            ForgotPasswordGetOTPEvent(
                                              forgotPasswordGetOTPRequest:
                                                  forgotPasswordGetOTPRequest,
                                            ),
                                          );
                                        }
                                      },
                                      child: Text(
                                        timeLeft > 0
                                            ? '${'Resend New Code in'} ${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}'
                                            : '${'Resend'} ${timerStartedOnce ? ' ${'New'}' : ''} ${'Code'}',
                                        style: textTheme.bodySmall?.copyWith(
                                          fontWeight:
                                              timeLeft > 0
                                                  ? FontWeight.normal
                                                  : FontWeight.bold,
                                          color:
                                              timeLeft > 0
                                                  ? colorScheme.secondary
                                                  : colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Container(
                                      width: double.infinity,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color:
                                            isButtonEnabled
                                                ? colorScheme.primary
                                                : colorScheme.error,
                                      ),
                                      child: TextButton(
                                        onPressed:
                                            isButtonEnabled
                                                ? _onOTPSubmit
                                                : null,
                                        child: Text(
                                          "Verify",
                                          style: textTheme.bodyLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color:
                                                isButtonEnabled
                                                    ? colorScheme.onPrimary
                                                    : colorScheme.onError,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          timer?.cancel();
                                          timerStartedOnce = false;
                                          timeLeft = 0;
                                          minutes = 1;
                                          seconds = 0;
                                          emailErrorText = '';
                                          otpErrorText = '';
                                          resendMessage = '';
                                          clickEmailSubmit = true;
                                          clickOTPSubmit = false;
                                          isButtonEnabled = true;
                                          isVerifyingOTP = false;
                                          pinController.clear();
                                        });
                                      },
                                      child: Text(
                                        "Change Email",
                                        style: textTheme.bodySmall?.copyWith(
                                          color: colorScheme.secondary,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: clickResetPassword,
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                              left: 16.0,
                              right: 16.0,
                              top: 48,
                            ),
                            child: Text(
                              'Set a new password',
                              style: textTheme.headlineLarge?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 16.0,
                              right: 16.0,
                              top: 32.0,
                              bottom: 32,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: colorScheme.primary,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Stack(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 8.0,
                                          right: 50.0,
                                        ),
                                        child: TextFormField(
                                          controller: passwordController,
                                          obscureText: _obscurePasswordText,
                                          onChanged: (value) {
                                            setState(() {
                                              passwordErrorText =
                                                  Validator.passwordValidate(
                                                        value,
                                                      )
                                                      ? ''
                                                      : 'Password do not meet requirements:\n\u2022 Must contain at least 8 characters\n\u2022 Must contain one special symbol (#, &, % etc)\n\u2022 Must contain one number (0-9)';
                                            });
                                            _updateSetPasswordBtnColor();
                                          },
                                          style: TextStyle(
                                            color: colorScheme.secondary,
                                            fontSize: 16,
                                            // Other text style properties like fontWeight, fontFamily, etc. can also be added here.
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
                                        top: 10,
                                        bottom: 0,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _obscurePasswordText =
                                                  !_obscurePasswordText;
                                            });
                                          },
                                          child: Icon(
                                            _obscurePasswordText
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                            color: const Color(0xFFA3A3A3),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible: passwordErrorText.isNotEmpty,
                                  child: Text(
                                    passwordErrorText,
                                    style: textTheme.bodySmall?.copyWith(
                                      color: colorScheme.error,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: colorScheme.primary,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Stack(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 8.0,
                                          right: 50.0,
                                        ),
                                        child: TextFormField(
                                          controller: confirmPasswordController,
                                          obscureText:
                                              _obscureConfirmPasswordText,
                                          onChanged: (value) {
                                            setState(() {
                                              confirmPasswordText =
                                                  Validator.confirmPasswordMatch(
                                                        passwordController.text,
                                                        value,
                                                      )
                                                      ? ''
                                                      : 'Passwords do not match';
                                            });
                                            _updateSetPasswordBtnColor();
                                          },
                                          style: TextStyle(
                                            color: colorScheme.secondary,
                                            fontSize: 16,
                                            // Other text style properties like fontWeight, fontFamily, etc. can also be added here.
                                          ),
                                          decoration: const InputDecoration(
                                            labelText: 'Confirm Password',
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
                                        top: 10,
                                        bottom: 0,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _obscureConfirmPasswordText =
                                                  !_obscureConfirmPasswordText;
                                            });
                                          },
                                          child: Icon(
                                            _obscureConfirmPasswordText
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                            color: const Color(0xFFA3A3A3),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible: confirmPasswordText.isNotEmpty,
                                  child: Text(
                                    confirmPasswordText,
                                    style: textTheme.bodySmall?.copyWith(
                                      color: colorScheme.error,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 32),
                                Container(
                                  width: double.infinity,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color:
                                        isButtonEnabled
                                            ? colorScheme.primary
                                            : colorScheme.error,
                                  ),
                                  child: TextButton(
                                    onPressed:
                                        isButtonEnabled ? _onSetPassword : null,
                                    child: Text(
                                      "Confirm",
                                      style: textTheme.bodyLarge?.copyWith(
                                        color:
                                            isButtonEnabled
                                                ? colorScheme.onPrimary
                                                : colorScheme.onError,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 32),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
