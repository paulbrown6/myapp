import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:myapp/util/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {

  late User _user;
  late String _verificationID;

  AuthBloc() : super(AuthInitial()) {
    on<StartLoadEvent>(_authEvent);
    on<AuthButtonTappedEvent>(_authButtonTapped);
    on<CodeButtonTappedEvent>(_codeButtonTaped);
  }

  Future<void> _authEvent(AuthEvent e, Emitter emit) async {
    final _prefs = await SharedPreferences.getInstance();
    try {
      final String? phone = _prefs.getString(Constants.NAME_PRAF);
      if (phone != null) {
        print(phone);
        emit(HomePageState());
        return;
      }
    } catch (e) {
      print(Error.safeToString(e));
    }
    emit(AuthInitial());
  }

  Future<void> _authButtonTapped(AuthButtonTappedEvent e, Emitter emit) async {
    try {
      await Constants.firebaseAuth.verifyPhoneNumber(
          phoneNumber: e.number,
          verificationCompleted: (PhoneAuthCredential credential) async {
            _signInInWithCredential(credential);
          },
          verificationFailed: (FirebaseAuthException e) async {
            print(e.toString());
            _authError();
          },
          codeSent: (String verificationId, int? resendToken) async {
            _verificationID = verificationId;
          },
          timeout: const Duration(seconds: 60),
          codeAutoRetrievalTimeout: (String verificationId) {
            _verificationID = verificationId;
          });
    } catch (e) {
      print(Error.safeToString(e));
      emit(ErrorAuth());
      return;
    }
    emit(ShowCodePageState());
  }

  Future<void> _codeButtonTaped(CodeButtonTappedEvent e, Emitter emit) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationID,
        smsCode: e.code
    );
    print("id: " + _verificationID + " code: " + e.code);
    _signInInWithCredential(credential);
  }

  Future<void> _signInInWithCredential(PhoneAuthCredential credential) async {
    try {
      await Constants.firebaseAuth.signInWithCredential(credential);
    }
    catch (e){
      print(e);
      emit(ErrorAuth());
      return;
    }
    await _userIsAuth(Constants.firebaseAuth.currentUser!);
  }

  Future<bool> _userIsAuth(User user) async{
    _user = user;
    if (_user.phoneNumber != null) {
      final user = <String, dynamic>{
        "phone": _user.phoneNumber,
      };
      final prefs = await SharedPreferences.getInstance();
      await Constants.firebaseCloud.collection("users").doc(_user.phoneNumber).set(user, SetOptions(merge: true));
      await prefs.setString(Constants.NAME_PRAF, _user.phoneNumber.toString());
      emit(HomePageState());
      return true;
    } else {
      emit(ErrorAuth());
    }
    return false;
  }

  Future<void> _authError() async {
    emit(ErrorAuth());
  }
}
