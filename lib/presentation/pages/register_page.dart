/*
 * Copyright (c) 2020, Kanan Yusubov. - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited.
 * Proprietary and confidential
 * Written by: Kanan Yusubov <kanan.yusub@gmail.com>, July 2020
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/authentication_bloc/authentication_bloc.dart';
import '../../bloc/register_bloc/register_bloc.dart';
import '../shared/app_text_styles.dart';
import '../widgets/custom_button.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _idController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _idController.addListener(_onIdChanged);
  }

  void _onIdChanged() {
    BlocProvider.of<RegisterBloc>(context).add(
      IdChanged(id: _idController.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register Page'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: BlocConsumer<RegisterBloc, RegisterState>(
                listener: (context, registerState) {
                  if (registerState.isFailure) {
                    Scaffold.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(SnackBar(
                        content: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(registerState.message),
                            Icon(Icons.error)
                          ],
                        ),
                        backgroundColor: Colors.red,
                      ));
                  }

                  if (registerState.isSubmitting) {
                    Scaffold.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Registering...'),
                              CircularProgressIndicator(),
                            ],
                          ),
                        ),
                      );
                  }

                  if (registerState.isSuccess) {
                    BlocProvider.of<AuthenticationBloc>(context)
                        .add(LoggedIn(registerState.user));
                    Navigator.of(context).pop();
                  }
                },
                builder: (context, state) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextFormField(
                        validator: (_) {
                          return !state.isIdValid ? 'Invalid Id' : null;
                        },
                        controller: _idController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.white,
                              width: 1,
                            ),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.white,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.white,
                              width: 1,
                            ),
                          ),
                          hintText: 'Enter user id',
                          hintStyle: AppTextStyles.mediumTextStyle,
                          counterStyle: AppTextStyles.mediumTextStyle,
                        ),
                        style: AppTextStyles.mediumTextStyle,
                        maxLength: 2,
                      ),
                      CustomButton(
                        'Register',
                        _isRegisterButtonEnabled(state)
                            ? _onRegisterButtonClicked
                            : null,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _isRegisterButtonEnabled(RegisterState state) =>
      state.isFormValid && !state.isSubmitting && _idController.text.isNotEmpty;

  void _onRegisterButtonClicked() {
    BlocProvider.of<RegisterBloc>(context)
        .add(RegisterClicked(id: _idController.text));
  }

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }
}
