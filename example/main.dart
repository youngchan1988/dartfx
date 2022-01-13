import 'package:dartfx/dartfx.dart';
import 'package:args/args.dart';

///
/// Author: YoungChan
/// Date: 2022-01-09 00:17:49
/// LastEditors: YoungChan
/// LastEditTime: 2022-01-09 00:17:49
/// Description: description
/// Copyright: ©2022 NEW CORE Technology Co. Ltd.
///

void main(List<String> arguments) {
  final parser = ArgParser()
    ..addFlag('expression', negatable: false, abbr: 'e');

  ArgResults argResults = parser.parse(arguments);
  var expression = argResults.rest.first;

  var result = fx(expression);
  print('Fx result: $result');
}
