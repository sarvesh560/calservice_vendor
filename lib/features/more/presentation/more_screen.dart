import 'package:flutter/material.dart';
import '../../profile/presentation/profile_screen.dart';

/// Legacy `MoreScreen` wrapper.
/// Consolidated into [ProfileScreen] to ensure a single profile feature hub.
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfileScreen();
  }
}
