import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _firebaseAuth;

  AuthBloc({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<LoggedIn>(_onLoggedIn);
    on<SignedUp>(_onSignedUp);
    on<LoggedOut>(_onLoggedOut);
  }

  void _onAuthCheckRequested(
      AuthCheckRequested event, Emitter<AuthState> emit) {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      emit(Authenticated(user.email ?? ''));
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onLoggedIn(LoggedIn event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      print("_onLoggedIn: $userCredential");

      emit(Authenticated(userCredential.user?.email ?? ''));

    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(e.message ?? 'Authentication failed'));
    } catch (e) {
      emit(const AuthFailure('An unexpected error occurred'));
    }
  }

  Future<void> _onSignedUp(SignedUp event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      emit(Authenticated(userCredential.user?.email ?? ''));
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(e.message ?? 'Registration failed'));
    } catch (e) {
      emit(const AuthFailure('An unexpected error occurred'));
    }
  }

  Future<void> _onLoggedOut(LoggedOut event, Emitter<AuthState> emit) async {
    await _firebaseAuth.signOut();
    emit(Unauthenticated());
  }
}
