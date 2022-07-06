part of 'home_bloc.dart';

@immutable
abstract class HomeState {}

class HomeInitial extends HomeState {}
class HomeErrorImagesUpload extends HomeState {}
class HomeImagesUpdate extends HomeState {
  List<String> urls;
  HomeImagesUpdate(this.urls);
}
class HomeUserExit extends HomeState {}
