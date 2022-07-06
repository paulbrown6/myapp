part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent {}

class StartLoadEvent extends AuthEvent {}
class AuthButtonTappedEvent extends AuthEvent {
  String number;
  AuthButtonTappedEvent(this.number);
}
class CodeButtonTappedEvent extends AuthEvent {
  String code;
  CodeButtonTappedEvent(this.code);
}