part of 'home_bloc.dart';

@immutable
abstract class HomeEvent {}

class ImageLoadEvent extends HomeEvent {}
class CameraClickEvent extends HomeEvent {
  File file;
  CameraClickEvent(this.file){}
}
class ImageDeleteEvent extends HomeEvent {
  String url;
  ImageDeleteEvent(this.url){}
}
class UserExitEvent extends HomeEvent {}
