// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartfx/src/ast/element.dart';
import 'package:dartfx/src/ast/scope.dart';

/// A scope that is lexically enclosed in another scope.
class EnclosedScope implements Scope {
  final Scope _parent;
  final Map<String, Element> _getters = {};
  final Map<String, Element> _setters = {};

  EnclosedScope(Scope parent) : _parent = parent;

  Scope get parent => _parent;

  @override
  ScopeLookupResult lookup(String id) {
    var getter = _getters[id];
    var setter = _setters[id];
    if (getter != null || setter != null) {
      return ScopeLookupResult(getter, setter);
    }

    return _parent.lookup(id);
  }

  void _addGetter(Element element) {
    _addTo(_getters, element);
  }

  void _addPropertyAccessor(PropertyAccessorElement element) {
    if (element.isGetter) {
      _addGetter(element);
    } else {
      _addSetter(element);
    }
  }

  void _addSetter(Element element) {
    _addTo(_setters, element);
  }

  void _addTo(Map<String, Element> map, Element element) {
    var id = element.displayName;
    map[id] ??= element;
  }
}

class FormalParameterScope extends EnclosedScope {
  FormalParameterScope(
    Scope parent,
    List<ParameterElement> elements,
  ) : super(parent) {
    for (var parameter in elements) {
      if (parameter is! FieldFormalParameterElement) {
        _addGetter(parameter);
      }
    }
  }
}

class LocalScope extends EnclosedScope {
  LocalScope(Scope parent) : super(parent);

  void add(Element element) {
    _addGetter(element);
  }
}

class TypeParameterScope extends EnclosedScope {
  TypeParameterScope(
    Scope parent,
    List<TypeParameterElement> elements,
  ) : super(parent) {
    elements.forEach(_addGetter);
  }
}
