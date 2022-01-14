// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Modified by the dartfx project authors.
// Copyright (c) 2022, the dartfx project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartfx/src/ast/ast.dart';
import 'package:dartfx/src/ast/element.dart';
import 'package:dartfx/src/ast/nullability_suffix.dart';
import 'package:dartfx/src/ast/type.dart';
import 'package:dartfx/src/ast/type_visitor.dart';

import 'ast.dart';
import 'element.dart';
import 'type.dart';
import 'type_algebra.dart';
import 'type_builder.dart';
import 'type_visitor.dart';

/// The type builder for a [GenericFunctionType].
class FunctionTypeBuilder extends TypeBuilder {
  final List<TypeParameterElement> typeFormals;
  final List<ParameterElement> parameters;
  final DartType? returnType;

  @override
  final NullabilitySuffix nullabilitySuffix;

  /// The node for which this builder is created, or `null` if the builder
  /// was detached from its node, e.g. during computing default types for
  /// type parameters.
  final GenericFunctionTypeImpl? node;

  /// The actual built type, not a [TypeBuilder] anymore.
  ///
  /// When [build] is called, the type is built, stored into this field,
  /// and set for the [node].
  FunctionType? _type;

  FunctionTypeBuilder(
    this.typeFormals,
    this.parameters,
    this.returnType,
    this.nullabilitySuffix, {
    this.node,
  });

  /// [isNNBD] indicates whether the containing library is opted into NNBD.
  factory FunctionTypeBuilder.of(
    bool isNNBD,
    GenericFunctionTypeImpl node,
    NullabilitySuffix nullabilitySuffix,
  ) {
    return FunctionTypeBuilder(
      _getTypeParameters(node.typeParameters),
      getParameters(isNNBD, node.parameters),
      _getNodeType(node.returnType),
      nullabilitySuffix,
      node: node,
    );
  }

  @override
  Element? get element => null;

  @override
  R accept<R>(TypeVisitor<R> visitor) {
    if (visitor is LinkingTypeVisitor<R>) {
      var visitor2 = visitor as LinkingTypeVisitor<R>;
      return visitor2.visitFunctionTypeBuilder(this);
    } else {
      throw StateError('Should not happen outside linking.');
    }
  }

  @override
  DartType build() {
    var type = _type;
    if (type != null) {
      return type;
    }

    for (var typeParameter in typeFormals) {
      var typeParameterImpl = typeParameter as TypeParameterElementImpl;
      var bound = typeParameterImpl.bound;
      if (bound != null) {
        typeParameterImpl.bound = _buildType(bound);
      }
    }

    for (var parameter in parameters) {
      (parameter as ParameterElementImpl).type = _buildType(parameter.type);
    }

    var builtReturnType = _buildType(returnType);
    type = FunctionTypeImpl(
      typeFormals: typeFormals,
      parameters: parameters,
      returnType: builtReturnType,
      nullabilitySuffix: nullabilitySuffix,
    );

    var fresh = getFreshTypeParameters(typeFormals);
    type = fresh.applyToFunctionType(type) as FunctionTypeImpl;

    _type = type;
    node?.type = type;
    return type;
  }

  @override
  String toString() {
    var buffer = StringBuffer();

    if (typeFormals.isNotEmpty) {
      buffer.write('<');
      buffer.write(typeFormals.join(', '));
      buffer.write('>');
    }

    buffer.write('(');
    buffer.write(parameters.join(', '));
    buffer.write(')');

    buffer.write(' → ');
    buffer.write(returnType);

    return buffer.toString();
  }

  @override
  TypeImpl withNullability(NullabilitySuffix nullabilitySuffix) {
    if (this.nullabilitySuffix == nullabilitySuffix) {
      return this;
    }

    return FunctionTypeBuilder(
      typeFormals,
      parameters,
      returnType,
      nullabilitySuffix,
      node: node,
    );
  }

  /// [isNNBD] indicates whether the containing library is opted into NNBD.
  static List<ParameterElementImpl> getParameters(
    bool isNNBD,
    FormalParameterList node,
  ) {
    return node.parameters.map((parameter) {
      return ParameterElementImpl.synthetic(
        parameter.identifier?.name ?? '',
        _getParameterType(isNNBD, parameter),
        (parameter as FormalParameterImpl).kind,
      );
    }).toList();
  }

  /// If the [type] is a [TypeBuilder], build it; otherwise return as is.
  static DartType _buildType(DartType? type) {
    if (type is TypeBuilder) {
      return type.build();
    } else {
      return type ?? VoidTypeImpl.instance;
    }
  }

  /// Return the type of the [node] as is, possibly a [TypeBuilder].
  static DartType? _getNodeType(TypeAnnotation? node) {
    return node?.type;
  }

  /// Return the type of the [node] as is, possibly a [TypeBuilder].
  ///
  /// [isNNBD] indicates whether the containing library is opted into NNBD.
  static DartType _getParameterType(bool isNNBD, FormalParameter node) {
    if (node is DefaultFormalParameter) {
      return _getParameterType(isNNBD, node.parameter);
    } else if (node is SimpleFormalParameter) {
      return _getNodeType(node.type) ?? VoidTypeImpl.instance;
    } else if (node is FunctionTypedFormalParameter) {
      NullabilitySuffix nullabilitySuffix;
      if (node.question != null) {
        nullabilitySuffix = NullabilitySuffix.question;
      } else if (isNNBD) {
        nullabilitySuffix = NullabilitySuffix.none;
      } else {
        nullabilitySuffix = NullabilitySuffix.star;
      }

      return FunctionTypeBuilder(
        _getTypeParameters(node.typeParameters),
        getParameters(isNNBD, node.parameters),
        _getNodeType(node.returnType),
        nullabilitySuffix,
      );
    } else {
      throw UnimplementedError('(${node.runtimeType}) $node');
    }
  }

  static List<TypeParameterElement> _getTypeParameters(
    TypeParameterList? node,
  ) {
    if (node == null) return const [];
    return node.typeParameters.map((n) => n.declaredElement!).toList();
  }
}
