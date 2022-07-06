import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/widgets/code_fields.dart';
import 'auth/auth_bloc.dart';

class AuthPage extends StatelessWidget {

  static late String _phone;
  static late String _code;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) {
        return AuthBloc();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("MyApp")),
        body: _buildScaffoldBody(),
      ),
    );
  }

  Widget _buildScaffoldBody() {
    return BlocConsumer<AuthBloc, AuthState>(
      builder: (context, state) {
        context
            .read<AuthBloc>()
            .add(StartLoadEvent());
        return _buildParentWidget(context, state);
      },
      listener: (context, state) {
        if (state is ErrorAuth) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Ошибка авторизации!'),
          ));
        }
        if (state is HomePageState) Navigator.popAndPushNamed(context, '/home');
      },
      buildWhen: (previous, current) => _shouldBuildFor(current),
      listenWhen: (previous, current) => _shouldListenFor(current),
    );
  }

  bool _shouldBuildFor(AuthState currentState) {
    return currentState is ShowCodePageState
        || currentState is HomePageState
        || currentState is ErrorAuth
    ;
  }

  bool _shouldListenFor(AuthState currentState) {
    return currentState is ErrorAuth
        || currentState is HomePageState;
  }

  Widget _buildParentWidget(BuildContext context, AuthState state) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          state is ShowCodePageState? _buildCodePanel(context) : _buildPhonePanel(context),
        ],
      ),
    );
  }

  Widget _buildCodePanel(BuildContext context){
    return Form(
      child: Container(
          padding: const EdgeInsets.only(left: 15, right: 15),
          child: Column(
            children: [
              SizedBox(
                height: 10,
              ),
              Text(
                "На указанный номер выслан код для подтверждения!",
                style: TextStyle(
                    color: Colors.blueAccent
                ),
              ),
              SizedBox(
                height: 20,
              ),
              CodeFields(onChanged: (value) {
                _code = value;
                print(value);
              }),
              SizedBox(
                height: 20,
              ),
              Container(
                  width: MediaQuery.of(context).size.width,
                  height: 40,
                  child: MaterialButton(
                    color: Colors.blue,
                    textColor: Colors.white,
                    onPressed: () {
                      context
                          .read<AuthBloc>()
                          .add(CodeButtonTappedEvent(_code));
                    },
                    child: const Text("Подтвердить"),
                  )
              )
            ],
          )),
    );
  }

  Widget _buildPhonePanel(BuildContext context){
    return Form(
      child: Container(
          padding: const EdgeInsets.only(left: 15, right: 15),
          child: Column(
            children: [
              SizedBox(
                height: 10,
              ),
              Text(
                "Введите номер телефона, для входа в приложение!",
                style: TextStyle(
                    color: Colors.blueAccent
                ),
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: "Введите номер",
                  labelText: "Номер телефона",
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(
                    color: Color.fromRGBO(102, 102, 102, 1),
                    fontSize: 16,
                  ),
                  contentPadding:
                  EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                ),
                onChanged: (value) {
                  _phone = value;
                },
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                  width: MediaQuery.of(context).size.width,
                  height: 40,
                  child: OutlinedButton(
                    onPressed: () {
                      context
                          .read<AuthBloc>()
                          .add(AuthButtonTappedEvent(_phone));
                    },
                    child: const Text("Войти"),
                  )
              )
            ],
          )),
    );
  }
}
