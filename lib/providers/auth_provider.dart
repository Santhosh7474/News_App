import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/data/auth_repository.dart';

// Auth Repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// Stream of auth state
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

// Convenience provider for current user
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).value;
});
