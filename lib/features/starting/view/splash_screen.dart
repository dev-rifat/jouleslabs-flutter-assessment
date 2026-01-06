import 'package:assessment/core/utils/app_string.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routes/app_route.dart';
import '../../../core/utils/app_color.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToLogin();
  }

  /// Handle splash delay & navigation
  Future<void> _navigateToLogin() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    if (GetStorage().read(AppString.ACCESS_TOKEN) == null) {
      /// remove splash from stack
      context.go(AppRoute.login);
      return;
    }

    /// fallback route
    context.go(AppRoute.homeScreen);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: AppColor.primaryColor, body: _buildBody());
  }

  /// Splash UI
  Widget _buildBody() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(color: AppColor.backgroundColor),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [_SplashTitle(), SizedBox(height: 20), _LoadingIndicator()],
      ),
    );
  }
}

/// Title Widget
class _SplashTitle extends StatelessWidget {
  const _SplashTitle();

  @override
  Widget build(BuildContext context) {
    return Text(
      'App Splash',
      style: TextStyle(
        color: AppColor.primaryColor,
        fontSize: 26,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

/// Loader Widget
class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(color: AppColor.primaryColor);
  }
}
