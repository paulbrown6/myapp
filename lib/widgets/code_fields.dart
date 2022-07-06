import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CodeFields extends StatelessWidget{

  List<String> numbers = ['0', '0', '0', '0', '0', '0'];

  CodeFields({Key? key, required this.onChanged}) : super(key: key);
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _numberField(context, 0),
          _numberField(context, 1),
          _numberField(context, 2),
          _numberField(context, 3),
          _numberField(context, 4),
          _numberField(context, 5)
        ],
      ),
    );
  }

  Widget _numberField(BuildContext context, int input){
    return
      SizedBox(
        height: 50,
        width: 40,
        child: TextFormField(
          onChanged: (value) {
            if (value.length == 1) {
              numbers[input] = value;
              FocusScope.of(context).nextFocus();
            }
            onChanged(_listToString(numbers));
          },
          style: Theme.of(context).textTheme.headline5,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          inputFormatters: [
            LengthLimitingTextInputFormatter(1),
            FilteringTextInputFormatter.digitsOnly
          ],
          decoration: const InputDecoration(hintText: '0'),
        ),
      );
  }

  String _listToString(List<String> list){
    String s = "";
    list.forEach((element) {s += element.toString();});
    return s;
  }
}