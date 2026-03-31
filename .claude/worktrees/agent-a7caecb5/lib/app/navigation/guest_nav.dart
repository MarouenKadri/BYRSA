import 'package:flutter/material.dart';
import '../../features/auth/presentation/pages/home/home_page.dart';

class GuestNav extends StatelessWidget {
  const GuestNav({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: WelcomePage(), // 👉 seule page affichée
    );
  }
}
