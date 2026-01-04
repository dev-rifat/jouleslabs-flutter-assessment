import 'package:assessment/core/utils/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:assessment/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/app_route.dart';
import '../../../../core/widgets/app_input_field.dart';
import '../../../../core/widgets/custom_app_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  bool _isLogin = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isFormValid() {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      _showSnackBar('Please fill in all fields');
      return false;
    }
    return true;
  }

  void _dispatchAuthEvent() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    context.read<AuthBloc>().add(
      _isLogin
          ? LoggedIn(email: email, password: password)
          : SignedUp(email: email, password: password),
    );
  }

  void _submit() {
    if (!_isFormValid()) return;
    _dispatchAuthEvent();
  }

  void _toggleAuthMode() {
    setState(() => _isLogin = !_isLogin);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _authListener(BuildContext context, AuthState state) {
    if (state is AuthFailure) {
      _showSnackBar(state.message);
    }

    if (state is Authenticated) {
      context.go(AppRoute.homeScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Login' : 'Sign Up'),
        centerTitle: true,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: _authListener,
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: _buildForm(state),
          );
        },
      ),
    );
  }

  Widget _buildForm(AuthState state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomInputField(
          controller: _emailController,
          hintText: "Email",
          radius: 4,
          hintStyle: TextStyle(color: AppColor.hintColor),
        ),
        const SizedBox(height: 16),
        PasswordInputField(
          controller: _passwordController,
          hintText: "Password",
          radius: 4,
        ),
        const SizedBox(height: 24),
        state is AuthLoading
            ? const CircularProgressIndicator(color: AppColor.primaryColor,)
            : _buildActions(),
      ],
    );
  }

  Widget _buildActions() {
    return Column(
      children: [
        CustomAppButton(
          text: _isLogin ? 'Login' : 'Sign Up',
          onPressed: _submit,
          buttonRadius: 4,
          buttonColor: AppColor.primaryColor,
        ),
        TextButton(
          onPressed: _toggleAuthMode,
          child: Text(
            _isLogin
                ? 'Don\'t have an account? Sign Up'
                : 'Already have an account? Login',
            style: TextStyle(color: AppColor.normalTextColor),
          ),
        ),
      ],
    );
  }
}
