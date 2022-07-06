import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';
import 'package:myapp/util/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {

  List<String> imagesURL = [""];

  HomeBloc() : super(HomeInitial()) {
    on<HomeEvent>(_homeEvent);
    on<CameraClickEvent>(_cameraClickEvent);
    on<UserExitEvent>(_userExit);
    on<ImageLoadEvent>(_loadImageEvent);
    on<ImageDeleteEvent>(_deleteImageEvent);
  }

  Future<void> _homeEvent(HomeEvent e, Emitter emit) async {
    emit(HomeInitial());
  }

  Future<void> _userExit(HomeEvent e, Emitter emit) async {
    final _prefs = await SharedPreferences.getInstance();
    _prefs.remove(Constants.NAME_PRAF);
    emit(HomeUserExit());
  }

  Future<void> _loadImageEvent(ImageLoadEvent e, Emitter emit) async {
    imagesURL = List<String>.from(await _writeFromCloud());
    emit(HomeImagesUpdate(imagesURL));
  }

  Future<void> _cameraClickEvent(CameraClickEvent e, Emitter emit) async {
    String url = "";
    try {
      final file = File(e.file.path);
      url = await _loadToStorage(file);
    } catch (e) {
      print(e);
    }
    print(url);
    if (imagesURL == null) {
      imagesURL = [url];
    } else {
      imagesURL.add(url);
    }
    await _readToCloud();
    emit(HomeImagesUpdate(imagesURL));
  }


  Future<void> _deleteImageEvent(ImageDeleteEvent e, Emitter emit) async {
    if (imagesURL.length > 1) {
      imagesURL.removeAt(imagesURL.indexOf(e.url));
    } else {
      imagesURL.clear();
    }
    await _readToCloud();
    emit(HomeImagesUpdate(imagesURL));
  }

  Future<void> _readToCloud() async {
    final _prefs = await SharedPreferences.getInstance();
    final String? id = _prefs.getString(Constants.NAME_PRAF);
    final url = <String, dynamic>{
      "url": imagesURL
    };
    await Constants.firebaseCloud.collection("users").doc(id).set(url, SetOptions(merge: true));
  }

  Future<List> _writeFromCloud() async {
    final _prefs = await SharedPreferences.getInstance();
    final String? id = _prefs.getString(Constants.NAME_PRAF);
    List<dynamic> url = [];
    await Constants.firebaseCloud.collection("users").doc(id).get().then(
          (DocumentSnapshot doc) {
            final data = doc.data() as Map<String, dynamic>;
            url = data.putIfAbsent("url", () => []);
          },
          onError: (e) => print("Error getting document: $e"),
    );
    return url;
  }

  Future<String> _loadToStorage(File file) async {
    final _prefs = await SharedPreferences.getInstance();
    final String? id = _prefs.getString(Constants.NAME_PRAF);
    final destination = 'images/{$id}' + file.path;
    final ref = Constants.firebaseStorage.ref(destination).child('file/');
    await ref.putFile(file);
    final url = await ref.getDownloadURL();
    return url;
  }
}

