import 'package:dartfx/dartfx.dart';
import 'dart:js' as js;

void main() {
  js.context['fx'] = fx;
  js.context['fxWithEnvs'] = fxWithEnvs;
}
