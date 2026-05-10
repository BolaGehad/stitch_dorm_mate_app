import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'dashboard_screen.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'services/auth_service.dart';
import 'services/house_service.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data != null) {
          if (snapshot.data!.emailVerified) {
            return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: HouseService.instance.watchCurrentUserProfile(),
              builder: (context, userProfileSnapshot) {
                if (userProfileSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                final houseId =
                    userProfileSnapshot.data?.data()?['houseId'] as String?;
                if (houseId != null && houseId.isNotEmpty) {
                  return const DashboardScreen();
                }
                return const HomeScreen();
              },
            );
          }
          return const LoginScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
