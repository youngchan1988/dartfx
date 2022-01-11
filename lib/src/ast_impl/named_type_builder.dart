// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartfx/src/ast/ast.dart';
import 'package:dartfx/src/ast/element.dart';
import 'package:dartfx/src/ast/nullability_suffix.dart';
import 'package:dartfx/src/ast/type.dart';
import 'package:dartfx/src/ast/type_visitor.dart';
import 'type.dart';
import 'type_builder.dart';
import 'ast.dart';
import 'element.dart';
import 'type_visitor.dart';

/// The type builder for a [NamedType].
class NamedTypeBuilder extends TypeBuilder {
  /// TODO(scheglov) Replace with `DartType` in `TypeAliasElementImpl`.
  static const _aliasedTypeKey = '_aliasedType';

  @override
  final Element element;

  final List<DartType> arguments;

  @override
  final NullabilitySuffix nullabilitySuffix;

  /// The node for which this builder is created, or `null` if the builder
  /// was detached from its node, e.g. during computing default types for
  /// type parameters.
  final NamedTypeImpl? node;

  /// The actual built type, not a [TypeBuilder] anymore.
  ///
  /// When [build] is called, the type is built, stored into this field,
  /// and set for the [node].
  DartType? _type;

  NamedTypeBuilder(this.element, this.arguments, this.nullabilitySuffix,
      {this.node});

  factory NamedTypeBuilder.of(
    NamedTypeImpl node,
    Element element,
    NullabilitySuffix nullabilitySuffix,
  ) {
    List<DartType> arguments;
    var argumentList = node.typeArguments;
    if (argumentList != null) {
      arguments = argumentList.arguments
          .map((n) => n.type ?? VoidTypeImpl.instance)
          .toList();
    } else {
      arguments = <DartType>[];
    }

    return NamedTypeBuilder(element, arguments, nullabilitySuffix, node: node);
  }

  @override
  R accept<R>(TypeVisitor<R> visitor) {
    if (visitor is LinkingTypeVisitor<R>) {
      var visitor2 = visitor as LinkingTypeVisitor<R>;
      return visitor2.visitNamedTypeBuilder(this);
    } else {
      throw StateError('Should not happen outside linking.');
    }
  }

  @override
  DartType build() {
    if (_type != null) {
      return _type!;
    }

    final element = this.element;
    if (element is TypeParameterElement) {
      _type = TypeParameterTypeImpl(
        element: element,
        nullabilitySuffix: nullabilitySuffix,
      );
    } else {
      _type = VoidTypeImpl.instance;
    }

    node?.type = _type;
    return _type!;
  }

  @override
  String toString() {
    var buffer = StringBuffer();
    buffer.write(element.displayName);
    if (arguments.isNotEmpty) {
      buffer.write('<');
      buffer.write(arguments.join(', '));
      buffer.write('>');
    }
    return buffer.toString();
  }

  @override
  TypeImpl withNullability(NullabilitySuffix nullabilitySuffix) {
    if (this.nullabilitySuffix == nullabilitySuffix) {
      return this;
    }

    return NamedTypeBuilder(element, arguments, nullabilitySuffix, node: node);
  }

  DartType _buildAliasedType(TypeAnnotation? node) {
    if (node is GenericFunctionType) {
      return _buildType(node.type);
    } else {
      return FunctionTypeImpl(
        typeFormals: const <TypeParameterElement>[],
        parameters: const <ParameterElement>[],
        returnType: VoidTypeImpl.instance,
        nullabilitySuffix: NullabilitySuffix.none,
      );
    }
  }

  /// Build arguments that correspond to the type [parameters].
  List<DartType> _buildArguments(List<TypeParameterElement> parameters) {
    if (parameters.isEmpty) {
      return const <DartType>[];
    } else if (arguments.isNotEmpty) {
      if (arguments.length == parameters.length) {
        return List.generate(arguments.length, (index) {
          var type = arguments[index];
          return _buildType(type);
        });
      } else {
        return List.filled(parameters.length, VoidTypeImpl.instance);
      }
    } else {
      return List.generate(parameters.length, (index) {
        var parameter = parameters[index] as TypeParameterElementImpl;
        var defaultType = parameter.defaultType!;
        return _buildType(defaultType);
      });
    }
  }

  DartType _buildFormalParameterType(FormalParameter node) {
    if (node is DefaultFormalParameter) {
      return _buildFormalParameterType(node.parameter);
    } else if (node is FunctionTypedFormalParameter) {
      return _buildFunctionType(
        typeParameterList: node.typeParameters,
        returnTypeNode: node.returnType,
        parameterList: node.parameters,
        hasQuestion: node.question != null,
      );
    } else if (node is SimpleFormalParameter) {
      return _buildNodeType(node.type);
    } else {
      throw UnimplementedError('(${node.runtimeType}) $node');
    }
  }

  FunctionType _buildFunctionType({
    required TypeParameterList? typeParameterList,
    required TypeAnnotation? returnTypeNode,
    required FormalParameterList parameterList,
    required bool hasQuestion,
  }) {
    var returnType = _buildNodeType(returnTypeNode);
    var typeParameters = _typeParameters(typeParameterList);
    var formalParameters = _formalParameters(parameterList);

    return FunctionTypeImpl(
      typeFormals: typeParameters,
      parameters: formalParameters,
      returnType: returnType,
      nullabilitySuffix: _getNullabilitySuffix(hasQuestion),
    );
  }

  DartType _buildNodeType(TypeAnnotation? node) {
    return _buildType(node?.type);
  }

  List<ParameterElementImpl> _formalParameters(FormalParameterList node) {
    return node.parameters.map((parameter) {
      return ParameterElementImpl.synthetic(
        parameter.identifier?.name ?? '',
        _buildFormalParameterType(parameter),
        (parameter as FormalParameterImpl).kind,
      );
    }).toList();
  }

  NullabilitySuffix _getNullabilitySuffix(bool hasQuestion) {
    if (hasQuestion) {
      return NullabilitySuffix.question;
    } else {
      return NullabilitySuffix.star;
    }
  }

  /// If the [type] is a [TypeBuilder], build it; otherwise return as is.
  static DartType _buildType(DartType? type) {
    if (type is TypeBuilder) {
      return type.build();
    } else {
      return type ?? VoidTypeImpl.instance;
    }
  }

  static List<TypeParameterElement> _typeParameters(TypeParameterList? node) {
    if (node != null) {
      return node.typeParameters
          .map<TypeParameterElement>((p) => p.declaredElement!)
          .toList();
    } else {
      return const <TypeParameterElement>[];
    }
  }
}
