///
/// Author: YoungChan
/// Date: 2022-01-05 16:34:12
/// LastEditors: YoungChan
/// LastEditTime: 2022-01-05 16:34:12
/// Description: description
/// Copyright: ©2022 NEW CORE Technology Co. Ltd.
///
// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartfx/src/ast/element.dart';
import 'package:dartfx/src/ast/nullability_suffix.dart';
import 'package:dartfx/src/ast/type.dart';

import 'element.dart';
import 'element_type_provider.dart';
import 'type.dart';
import 'type_algebra.dart';

class ElementDisplayStringBuilder {
  final StringBuffer _buffer = StringBuffer();

  final bool skipAllDynamicArguments;
  final bool withNullability;
  final bool multiline;

  ElementDisplayStringBuilder({
    required this.skipAllDynamicArguments,
    required this.withNullability,
    this.multiline = false,
  });

  @override
  String toString() {
    return _buffer.toString();
  }

  void writeCompilationUnitElement(CompilationUnitElementImpl element) {
    var path = element.displayName;
    _write(path);
  }

  void writeExecutableElement(ExecutableElement element, String name) {
    _writeType(element.returnType);
    _write(' ');

    _write(name);

    if (element.kind != ElementKind.GETTER) {
      _writeTypeParameters(element.typeParameters);
      _writeFormalParameters(
        element.parameters,
        forElement: true,
        allowMultiline: true,
      );
    }
  }

  void writeFormalParameter(ParameterElement element) {
    if (element.isRequiredPositional) {
      _writeWithoutDelimiters(element, forElement: true);
    } else if (element.isOptionalPositional) {
      _write('[');
      _writeWithoutDelimiters(element, forElement: true);
      _write(']');
    } else if (element.isNamed) {
      _write('{');
      _writeWithoutDelimiters(element, forElement: true);
      _write('}');
    }
  }

  void writeFunctionType(FunctionType type) {
    type = _uniqueTypeParameters(type);

    _writeType(type.returnType);
    _write(' Function');
    _writeTypeParameters(type.typeFormals);
    _writeFormalParameters(type.parameters, forElement: false);
    _writeNullability(type.nullabilitySuffix);
  }

  void writeGenericFunctionTypeElement(GenericFunctionTypeElementImpl element) {
    _writeType(element.returnType);
    _write(' Function');
    _writeTypeParameters(element.typeParameters);
    _writeFormalParameters(element.parameters, forElement: true);
  }

  void writeTypeParameter(TypeParameterElement element) {
    _write(element.displayName);

    var bound = element.bound;
    if (bound != null) {
      _write(' extends ');
      _writeType(bound);
    }
  }

  void writeTypeParameterType(TypeParameterTypeImpl type) {
    _write(type.element.displayName);
    _writeNullability(type.nullabilitySuffix);

    var promotedBound = type.promotedBound;
    if (promotedBound != null) {
      _write(' & ');
      _writeType(promotedBound);
    }
  }

  void writeUnknownInferredType() {
    _write('_');
  }

  void writeVariableElement(VariableElement element) {
    _writeType(element.type);
    _write(' ');
    _write(element.displayName);
  }

  void writeVoidType() {
    _write('void');
  }

  void _write(String str) {
    _buffer.write(str);
  }

  void _writeFormalParameters(
    List<ParameterElement> parameters, {
    required bool forElement,
    bool allowMultiline = false,
  }) {
    // Assume the display string looks better wrapped when there are at least
    // three parameters. This avoids having to pre-compute the single-line
    // version and know the length of the function name/return type.
    var multiline = allowMultiline && this.multiline && parameters.length >= 3;

    // The prefix for open groups is included in seperator for single-line but
    // not for multline so must be added explicitly.
    var openGroupPrefix = multiline ? ' ' : '';
    var separator = multiline ? ',' : ', ';
    var trailingComma = multiline ? ',\n' : '';
    var parameterPrefix = multiline ? '\n  ' : '';

    _write('(');

    _WriteFormalParameterKind? lastKind;
    var lastClose = '';

    void openGroup(_WriteFormalParameterKind kind, String open, String close) {
      if (lastKind != kind) {
        _write(lastClose);
        if (lastKind != null) {
          // We only need to include the space before the open group if there
          // was a previous parameter, otherwise it goes immediately after the
          // open paren.
          _write(openGroupPrefix);
        }
        _write(open);
        lastKind = kind;
        lastClose = close;
      }
    }

    for (var i = 0; i < parameters.length; i++) {
      if (i != 0) {
        _write(separator);
      }

      var parameter = parameters[i];
      if (parameter.isRequiredPositional) {
        openGroup(_WriteFormalParameterKind.requiredPositional, '', '');
      } else if (parameter.isOptionalPositional) {
        openGroup(_WriteFormalParameterKind.optionalPositional, '[', ']');
      } else if (parameter.isNamed) {
        openGroup(_WriteFormalParameterKind.named, '{', '}');
      }
      _write(parameterPrefix);
      _writeWithoutDelimiters(parameter, forElement: forElement);
    }

    _write(trailingComma);
    _write(lastClose);
    _write(')');
  }

  void _writeNullability(NullabilitySuffix nullabilitySuffix) {
    if (withNullability) {
      switch (nullabilitySuffix) {
        case NullabilitySuffix.question:
          _write('?');
          break;
        case NullabilitySuffix.star:
          _write('*');
          break;
        case NullabilitySuffix.none:
          break;
      }
    }
  }

  void _writeType(DartType type) {
    (type as TypeImpl).appendTo(this);
  }

  void _writeTypeArguments(List<DartType> typeArguments) {
    if (typeArguments.isEmpty) {
      return;
    }

    _write('<');
    for (var i = 0; i < typeArguments.length; i++) {
      if (i != 0) {
        _write(', ');
      }
      (typeArguments[i] as TypeImpl).appendTo(this);
    }
    _write('>');
  }

  void _writeTypeIfNotObject(String prefix, DartType? type) {
    if (type != null && !type.isDartCoreObject) {
      _write(prefix);
      _writeType(type);
    }
  }

  void _writeTypeParameters(List<TypeParameterElement> elements) {
    if (elements.isEmpty) return;

    _write('<');
    for (var i = 0; i < elements.length; i++) {
      if (i != 0) {
        _write(', ');
      }
      (elements[i] as TypeParameterElementImpl).appendTo(this);
    }
    _write('>');
  }

  void _writeTypes(List<DartType> types) {
    for (var i = 0; i < types.length; i++) {
      if (i != 0) {
        _write(', ');
      }
      _writeType(types[i]);
    }
  }

  void _writeTypesIfNotEmpty(String prefix, List<DartType> types) {
    if (types.isNotEmpty) {
      _write(prefix);
      _writeTypes(types);
    }
  }

  void _writeWithoutDelimiters(
    ParameterElement element, {
    required bool forElement,
  }) {
    if (element.isRequiredNamed) {
      _write('required ');
    }

    _writeType(element.type);

    if (forElement || element.isNamed) {
      _write(' ');
      _write(element.displayName);
    }

    if (forElement) {
      var defaultValueCode = element.defaultValueCode;
      if (defaultValueCode != null) {
        _write(' = ');
        _write(defaultValueCode);
      }
    }
  }

  static FunctionType _uniqueTypeParameters(FunctionType type) {
    if (type.typeFormals.isEmpty) {
      return type;
    }

    var referencedTypeParameters = <TypeParameterElement>{};

    void collectTypeParameters(DartType? type) {
      if (type is TypeParameterType) {
        referencedTypeParameters.add(type.element);
      } else if (type is FunctionType) {
        for (var typeParameter in type.typeFormals) {
          collectTypeParameters(typeParameter.bound);
        }
        for (var parameter in type.parameters) {
          collectTypeParameters(parameter.type);
        }
        collectTypeParameters(type.returnType);
      }
    }

    collectTypeParameters(type);
    referencedTypeParameters.removeAll(type.typeFormals);

    var namesToAvoid = <String>{};
    for (var typeParameter in referencedTypeParameters) {
      namesToAvoid.add(typeParameter.displayName);
    }

    var newTypeParameters = <TypeParameterElement>[];
    for (var typeParameter in type.typeFormals) {
      var name = typeParameter.name;
      for (var counter = 0; !namesToAvoid.add(name); counter++) {
        const unicodeSubscriptZero = 0x2080;
        const unicodeZero = 0x30;

        var subscript = String.fromCharCodes('$counter'.codeUnits.map((n) {
          return unicodeSubscriptZero + (n - unicodeZero);
        }));

        name = typeParameter.name + subscript;
      }

      var newTypeParameter = TypeParameterElementImpl(name, -1);
      newTypeParameter.bound = typeParameter.bound;
      newTypeParameters.add(newTypeParameter);
      ElementTypeProvider.current
          .freshTypeParameterCreated(newTypeParameter, typeParameter);
    }

    return replaceTypeParameters(type as FunctionTypeImpl, newTypeParameters);
  }
}

enum _WriteFormalParameterKind { requiredPositional, optionalPositional, named }
