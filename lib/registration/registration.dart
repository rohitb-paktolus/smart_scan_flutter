import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:smart_scan_flutter/db/database_helper.dart';
import 'package:smart_scan_flutter/registration/models/user_model.dart';
import 'package:smart_scan_flutter/utils/pref_key.dart';
import 'package:smart_scan_flutter/utils/secure_prefs.dart';
import 'package:smart_scan_flutter/widgets/custom_alert.dart';

import '../../utils/app_functions.dart';
import '../../utils/route.dart';
import '../../utils/validation.dart';
import 'package:smart_scan_flutter/registration/bloc/registration_bloc.dart';

class Registration extends StatefulWidget {
  const Registration({super.key});

  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  // Color buttonColor = const Color(0xFF88c2f7); // Initialize the button color
  bool isButtonEnabled = false;
  bool _obscurePasswordText = true;
  bool _obscureConfirmPasswordText = true;
  String errorFirstName = '';
  String errorLastName = '';
  String errorEmail = '';
  String errorPhone = '';
  String errorPassword = '';
  String errorConfirmPassword = '';
  bool isSubmitting = false;

  void showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissal using the back button
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Registration Successful'),
          content: const Text('Your account has been created successfully.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed(ROUT_LOGIN_EMAIL);
              },
              child: const Text('Go to Login'),
            ),
          ],
        );
      },
    );
  }

  void _updateButtonColor(ColorScheme colorScheme) {
    setState(() {
      bool isPasswordValid = Validator.passwordValidate(
        passwordController.text,
      );
      bool isConfirmPassword = Validator.confirmPasswordMatch(
        passwordController.text,
        confirmPasswordController.text,
      );

      isButtonEnabled = isPasswordValid && isConfirmPassword;
      // buttonColor = isButtonEnabled ? colorScheme.primary : colorScheme.error;
    });
  }

  void _onButtonPressed(BuildContext context) {
    setState(() {
      isSubmitting = true;
    });
    final registerRequestBody = RegisterRequestModel(
      email: emailController.text,
      password: passwordController.text,
      firstName: firstNameController.text,
      lastName: lastNameController.text,
      phoneNumber: '9876543210',
    );
    print(registerRequestBody.toJson());
    print("Submitted");
    context.read<RegistrationBloc>().add(
      RegisterUserEvent(registerRequestBody),
    );
    FocusScope.of(context).requestFocus(FocusNode());
  }

  @override
  void initState() {
    super.initState();
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
            'Do you want to exit the registration process?',
            ROUT_SPLASH,
            false,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text("Registration")),
        body: BlocConsumer<RegistrationBloc, RegistrationState>(
          listener: (context, state) async {
            if (state is RegistrationSuccess) {
              final accessToken = state.registerUserResponse.accessToken;
              SecurePrefs().setString(TOKEN, accessToken);
              final refreshToken = state.registerUserResponse.refreshToken;
              SecurePrefs().setString(REFRESH_TOKEN, refreshToken);
              await DatabaseHelper.instance.saveUserInfo(
                state.registerUserResponse.user.toJson(),
              );
              print("Registration successful");
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil(ROUTE_HOME, (route) => false);
              // showSuccessDialog(context);
              setState(() {
                isSubmitting = false;
              });
            } else if (state is RegistrationError) {
              setState(() {
                isSubmitting = false;
              });
              showDialog(
                context: context,
                builder:
                    (context) => CustomAlert(
                      title: "Error",
                      message: state.error,
                      buttonText: "Okay",
                      onButtonTap: () => Navigator.of(context).pop(),
                    ),
              );
            } else {
              setState(() {
                isSubmitting = false;
              });
            }
          },
          builder: (context, state) {
            return Center(
              child: Container(
                margin: const EdgeInsets.only(top: 0, left: 24, right: 24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome to SmartScan",
                        style: textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 12),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: colorScheme.primary,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: TextFormField(
                                  controller: firstNameController,
                                  onChanged: (value) {
                                    setState(() {
                                      // Use the EmailValidator to validate and set error text
                                      errorFirstName =
                                          Validator.stringValidate(value)
                                              ? ''
                                              : 'Please enter a valid first name';
                                    });
                                    _updateButtonColor(colorScheme);
                                  },
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w400,
                                    height: 1.50,
                                    fontSize: 16,
                                  ),
                                  keyboardType: TextInputType.name,
                                  textCapitalization: TextCapitalization.words,
                                  decoration: const InputDecoration(
                                    labelText: '${'First Name'} *',
                                    labelStyle: TextStyle(
                                      color: Color(0xFF737373),
                                    ),
                                    counterText: '',
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                            Visibility(
                              visible: errorFirstName.isNotEmpty,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 4,
                                  top: 12.0,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        errorFirstName,
                                        style: textTheme.labelMedium?.copyWith(
                                          color: colorScheme.error,
                                        ),
                                      ),
                                    ),
                                  ],
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
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: TextFormField(
                                  controller: lastNameController,
                                  onChanged: (value) {
                                    setState(() {
                                      // Use the EmailValidator to validate and set error text
                                      errorLastName =
                                          Validator.stringValidate(value)
                                              ? ''
                                              : 'Please enter a valid last name';
                                    });
                                    _updateButtonColor(colorScheme);
                                  },
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w400,
                                    height: 1.50,
                                    fontSize: 16,
                                  ),
                                  keyboardType: TextInputType.name,
                                  textCapitalization: TextCapitalization.words,
                                  decoration: const InputDecoration(
                                    labelText: '${'Last Name'} *',
                                    labelStyle: TextStyle(
                                      color: Color(0xFF737373),
                                    ),
                                    counterText: '',
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                            Visibility(
                              visible: errorLastName.isNotEmpty,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 4,
                                  top: 12.0,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        errorLastName,
                                        style: textTheme.labelMedium?.copyWith(
                                          color: colorScheme.error,
                                        ),
                                      ),
                                    ),
                                  ],
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
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: TextFormField(
                                  controller: emailController,
                                  onChanged: (value) {
                                    setState(() {
                                      // Use the EmailValidator to validate and set error text
                                      errorEmail =
                                          Validator.emailValidate(value)
                                              ? ''
                                              : 'Please enter a valid email address';
                                    });
                                    _updateButtonColor(colorScheme);
                                  },
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w400,
                                    height: 1.50,
                                    fontSize: 16,
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  textCapitalization: TextCapitalization.none,
                                  decoration: const InputDecoration(
                                    labelText: '${'Email Address'} *',
                                    labelStyle: TextStyle(
                                      color: Color(0xFF737373),
                                    ),
                                    counterText: '',
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                            Visibility(
                              visible: errorEmail.isNotEmpty,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 4,
                                  top: 12.0,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        errorEmail,
                                        style: textTheme.labelMedium?.copyWith(
                                          color: colorScheme.error,
                                        ),
                                      ),
                                    ),
                                  ],
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
                                      right: 46,
                                    ),
                                    child: TextFormField(
                                      controller: passwordController,
                                      obscureText: _obscurePasswordText,
                                      onChanged: (value) {
                                        setState(() {
                                          // Use the EmailValidator to validate and set error text
                                          errorPassword =
                                              Validator.passwordValidate(value)
                                                  ? ''
                                                  : 'Password do not meet requirements:\n\u2022 Must contain at least 8 characters\n\u2022 Must contain one special symbol (#, &, % etc)\n\u2022 Must contain one number (0-9)';
                                        });
                                        if (confirmPasswordController.text !=
                                            '') {
                                          errorConfirmPassword =
                                              Validator.confirmPasswordMatch(
                                                    confirmPasswordController
                                                        .text,
                                                    value,
                                                  )
                                                  ? ''
                                                  : 'Passwords do not match';
                                        }
                                        _updateButtonColor(colorScheme);
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter Password';
                                        }
                                        return null;
                                      },
                                      style: const TextStyle(
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
                                    top: 0,
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
                              visible: errorPassword.isNotEmpty,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/error_icon.svg',
                                    height: 12.67,
                                    width: 12.67,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      errorPassword,
                                      style: textTheme.labelMedium?.copyWith(
                                        color: colorScheme.error,
                                      ),
                                    ),
                                  ),
                                ],
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
                                      right: 46,
                                    ),
                                    child: TextFormField(
                                      controller: confirmPasswordController,
                                      obscureText: _obscureConfirmPasswordText,
                                      onChanged: (value) {
                                        setState(() {
                                          errorConfirmPassword =
                                              Validator.confirmPasswordMatch(
                                                    passwordController.text,
                                                    value,
                                                  )
                                                  ? ''
                                                  : 'Passwords do not match';
                                        });
                                        _updateButtonColor(colorScheme);
                                      },
                                      style: const TextStyle(fontSize: 16),
                                      decoration: InputDecoration(
                                        labelText: 'Confirm Password',
                                        labelStyle: const TextStyle(
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
                              visible: errorConfirmPassword.isNotEmpty,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/error_icon.svg',
                                    height: 12.67,
                                    width: 12.67,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      errorConfirmPassword,
                                      style: textTheme.labelMedium?.copyWith(
                                        color: colorScheme.error,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
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
                                    isSubmitting
                                        ? null
                                        : (isButtonEnabled
                                            ? () => _onButtonPressed(context)
                                            : null),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Register",
                                      style: textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color:
                                            isButtonEnabled
                                                ? colorScheme.onPrimary
                                                : colorScheme.onError,
                                      ),
                                    ),
                                    if (isSubmitting)
                                      CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Center(
                        child: Visibility(
                          visible: isSubmitting,
                          child: const CircularProgressIndicator(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
