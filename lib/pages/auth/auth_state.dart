part of 'auth_bloc.dart';

@immutable
abstract class AuthState {}

class AuthInitial extends AuthState {}
class ErrorAuth extends AuthState {}
class ShowCodePageState extends AuthState {}
class HomePageState extends AuthState {}
