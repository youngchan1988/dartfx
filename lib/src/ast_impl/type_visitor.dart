// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartfx/src/ast/type.dart';
import 'package:dartfx/src/ast/type_visitor.dart';

import 'function_type_builder.dart';
import 'named_type_builder.dart';

/// Visitors that implement this interface can be used to visit partially
/// built types, during linking element model.
abstract class LinkingTypeVisitor<R> {
  R visitFunctionTypeBuilder(FunctionTypeBuilder type);

  R visitNamedTypeBuilder(NamedTypeBuilder type);
}

/// Recursively visits a DartType tree until any visit method returns `false`.
class RecursiveTypeVisitor extends UnifyingTypeVisitor<bool> {
  /// Visit each item in the list until one returns `false`, in which case, this
  /// will also return `false`.
  bool visitChildren(Iterable<DartType> types) =>
      types.every((type) => type.accept(this));

  @override
  bool visitDartType(DartType type) => true;

  @override
  bool visitFunctionType(FunctionType type) => visitChildren([
        type.returnType,
        ...type.typeFormals
            .map((formal) => formal.bound)
            .where((type) => type != null)
            .map((type) => type!),
        ...type.parameters.map((param) => param.type),
      ]);

  @override
  bool visitTypeParameterType(TypeParameterType type) {
    // TODO(scheglov) Should we visit the bound here?
    return true;
  }
}
