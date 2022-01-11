import 'package:dartfx/src/resolver/iterable_resolver.dart';
import 'package:dartfx/src/resolver/list_resolver.dart';
import 'package:dartfx/src/resolver/num_resolver.dart';
import 'package:dartfx/src/resolver/string_resolver.dart';
import 'package:dartfx/src/runtime/ast_context.dart';
import 'package:dartfx/src/runtime/ast_runtime_node.dart';
import 'package:dartfx/src/runtime/ast_resolver.dart';
import 'package:dartfx/src/runtime/ast_runtime_executor.dart';
import 'package:dartfx/src/util/logger.dart';

import 'map_resolver.dart';

class CommonResolver implements AstResolver {
  CommonResolver() {
    //初始化Parser map
    addParser(StringResolver())
        .addParser(IntResolver())
        .addParser(DoubleResolver())
        .addParser(ListResolver())
        .addParser(MapResolver())
        .addParser(IterableResolver());
  }

  static const _tag = "CommonParser";

  static CommonResolver? get instance => _instance ??= CommonResolver();

  static CommonResolver? _instance;

  final _resolverList = <AstResolver>[];

  CommonResolver addParser(AstResolver resolver) {
    _resolverList.add(resolver);
    return this;
  }

  @override
  bool canResolve(target, {String? property}) => true;

  ///
  /// ClassName.methodName()
  /// methodName()
  /// obj.methodName()
  /// ClassName()
  ///
  @override
  dynamic resolve(AstContext astContext, AstRuntimeExecutor executor, target,
      {String? property, List<AstRuntimeNode>? arguments}) {
    for (var parser in _resolverList) {
      if (parser.canResolve(target, property: property)) {
        return parser.resolve(astContext, executor, target,
            property: property, arguments: arguments);
      }
    }
    logError(_tag,
        "Didn't found parser for target: $target, or property: $property");
  }
}
