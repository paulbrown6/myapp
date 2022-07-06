import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/pages/home/home_bloc.dart';
import 'package:myapp/util/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatelessWidget {

  final ImagePicker _picker = ImagePicker();
  String _phone = "";
  List<String> urls = [];

  HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _phoneNumberLoad();
    return BlocProvider(
      create: (BuildContext context) {
        return HomeBloc();
      },
      child: _buildScaffoldBody(),
    );
  }

  Widget _buildScaffoldBody() {
    return BlocConsumer<HomeBloc, HomeState>(
      builder: (context, state) {
        context.read<HomeBloc>().add(ImageLoadEvent());
        return _buildParentWidget(context, state);
      },
      listener: (context, state) {
        if (state is HomeErrorImagesUpload) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Ошибка получения изображений!'),
        ));
        }
        if (state is HomeUserExit) Navigator.pushReplacementNamed(context, '/');
      },
      buildWhen: (previous, current) => _shouldBuildFor(current),
      listenWhen: (previous, current) => _shouldListenFor(current),
    );
  }

  bool _shouldBuildFor(HomeState currentState) {
    return currentState is HomeUserExit
        || currentState is HomeImagesUpdate;
  }

  bool _shouldListenFor(HomeState currentState) {
    return currentState is HomeErrorImagesUpload
        || currentState is HomeUserExit;
  }

  Widget _buildParentWidget(BuildContext context, HomeState state) {
    state is HomeImagesUpdate? urls = state.urls : null;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'MyApp',
        ),
        backgroundColor: Colors.blue,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
             DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                _phone,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.exit_to_app_rounded,
              ),
              title: const Text('Выход'),
              onTap: () {
                context.read<HomeBloc>().add(UserExitEvent());
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: GridView.count(
          crossAxisCount: 2,
          primary: false,
          padding: const EdgeInsets.all(15),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: _listImages(context),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showPicker(context);
        },
        child: const Icon(
          Icons.photo_camera,
        ),
      ),
    );
  }

  List<Widget> _listImages(BuildContext context){
    List<Widget> widgets = [];
    urls.forEach((element) {
      widgets.add(
        InkWell(
          onLongPress: () {
            _confirmDialog(context, element);
          },
          child: Image.network(element),
        )
      );
    });
    return widgets;
  }

  void _confirmDialog(BuildContext contextProvider, String url) {
    showDialog(
      context: contextProvider,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Удаление'),
          content: Text('Удалить выбранное изображение?'),
          actions: <Widget>[
            FlatButton(
              child: Text('Отмена'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              textColor: Colors.red,
              child: Text('УДАЛИТЬ'),
              onPressed: () {
                contextProvider.read<HomeBloc>().add(ImageDeleteEvent(url));
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: Wrap(
                children: <Widget>[
                  ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Gallery'),
                      onTap: () {
                        imgFromGallery(context);
                        Navigator.of(context).pop();
                      }),
                  ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      imgFromCamera(context);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future imgFromGallery(BuildContext context) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final image = File(pickedFile.path);
        context.read<HomeBloc>().add(CameraClickEvent(image));
    } else {
      print('No image selected.');
    };
  }

  Future imgFromCamera(BuildContext context) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final image = File(pickedFile.path);
      context.read<HomeBloc>().add(CameraClickEvent(image));
    } else {
      print('No image selected.');
    };
  }

  Future _phoneNumberLoad() async{
    final _prefs = await SharedPreferences.getInstance();
    _phone = _prefs.getString(Constants.NAME_PRAF)!;
  }
}
