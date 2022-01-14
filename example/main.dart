// Copyright (c) 2022, the dartfx project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartfx/dartfx.dart';
import 'package:args/args.dart';

void main(List<String> arguments) {
  final parser = ArgParser()
    ..addFlag('expression', negatable: false, abbr: 'e');

  ArgResults argResults = parser.parse(arguments);
  var expression = argResults.rest.first;

  var result = fx(expression);
  print('Fx result: $result');
}
