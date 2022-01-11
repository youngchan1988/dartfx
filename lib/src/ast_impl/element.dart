// Copyright (c) 2014, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';

import 'package:dartfx/src/ast/line_info.dart';
import 'package:dartfx/src/ast/nullability_suffix.dart';
import 'package:dartfx/src/ast/type.dart';
import 'package:dartfx/src/ast/value.dart';

import '../ast/element.dart';
import '../ast/ast.dart';
import 'display_string_builder.dart';
import 'element_type_provider.dart';
import 'scope.dart';
import 'type.dart';
import 'utilities_collection.dart';

/// A concrete implementation of a [CompilationUnitElement].
class CompilationUnitElementImpl extends ElementImpl
    implements CompilationUnitElement {
  @override
  LineInfo? lineInfo;

  /// A list containing all of the top-level accessors (getters and setters)
  /// contained in this compilation unit.
  List<PropertyAccessorElement> _accessors = const [];

  /// A list containing all of the top-level functions contained in this
  /// compilation unit.
  List<FunctionElement> _functions = const [];

  /// A list containing all of the type aliases contained in this compilation
  /// unit.
  List<TypeAliasElement> _typeAliases = const [];

  /// A list containing all of the variables contained in this compilation unit.
  List<TopLevelVariableElement> _variables = const [];

  /// Initialize a newly created compilation unit element to have the given
  /// [name].
  CompilationUnitElementImpl() : super(null, -1);

  @override
  List<PropertyAccessorElement> get accessors {
    return _accessors;
  }

  /// Set the top-level accessors (getters and setters) contained in this
  /// compilation unit to the given [accessors].
  set accessors(List<PropertyAccessorElement> accessors) {
    for (PropertyAccessorElement accessor in accessors) {
      (accessor as PropertyAccessorElementImpl).enclosingElement = this;
    }
    _accessors = accessors;
  }

  @override
  CompilationUnitElementImpl get enclosingUnit {
    return this;
  }

  @override
  List<FunctionElement> get functions {
    return _functions;
  }

  /// Set the top-level functions contained in this compilation unit to the
  ///  given[functions].
  set functions(List<FunctionElement> functions) {
    for (FunctionElement function in functions) {
      (function as FunctionElementImpl).enclosingElement = this;
    }
    _functions = functions;
  }

  @override
  ElementKind get kind => ElementKind.COMPILATION_UNIT;

  @override
  List<TopLevelVariableElement> get topLevelVariables {
    return _variables;
  }

  /// Set the top-level variables contained in this compilation unit to the
  ///  given[variables].
  set topLevelVariables(List<TopLevelVariableElement> variables) {
    for (TopLevelVariableElement field in variables) {
      (field as TopLevelVariableElementImpl).enclosingElement = this;
    }
    _variables = variables;
  }

  @override
  List<TypeAliasElement> get typeAliases {
    return _typeAliases;
  }

  /// Set the type aliases contained in this compilation unit to [typeAliases].
  set typeAliases(List<TypeAliasElement> typeAliases) {
    for (var typeAlias in typeAliases) {
      (typeAlias as ElementImpl).enclosingElement = this;
    }
    _typeAliases = typeAliases;
  }

  @override
  TypeParameterizedElementMixin? get typeParameterContext => null;

  @override
  T? accept<T>(ElementVisitor<T> visitor) =>
      visitor.visitCompilationUnitElement(this);

  @override
  void appendTo(ElementDisplayStringBuilder builder) {
    builder.writeCompilationUnitElement(this);
  }

  @override
  void visitChildren(ElementVisitor visitor) {
    super.visitChildren(visitor);
    safelyVisitChildren(accessors, visitor);
    safelyVisitChildren(functions, visitor);
    safelyVisitChildren(typeAliases, visitor);
    safelyVisitChildren(topLevelVariables, visitor);
  }
}

/// A [FieldFormalParameterElementImpl] for parameters that have an initializer.
class DefaultFieldFormalParameterElementImpl
    extends FieldFormalParameterElementImpl {
  /// Initialize a newly created parameter element to have the given [name] and
  /// [nameOffset].
  DefaultFieldFormalParameterElementImpl({
    required String name,
    required int nameOffset,
    required ParameterKind parameterKind,
  }) : super(
          name: name,
          nameOffset: nameOffset,
          parameterKind: parameterKind,
        );

  @override
  String? get defaultValueCode {
    return constantInitializer?.toSource();
  }
}

/// A [ParameterElement] for parameters that have an initializer.
class DefaultParameterElementImpl extends ParameterElementImpl {
  /// Initialize a newly created parameter element to have the given [name] and
  /// [nameOffset].
  DefaultParameterElementImpl({
    required String? name,
    required int nameOffset,
    required ParameterKind parameterKind,
  }) : super(
          name: name,
          nameOffset: nameOffset,
          parameterKind: parameterKind,
        );

  @override
  String? get defaultValueCode {
    return constantInitializer?.toSource();
  }
}

/// A base class for concrete implementations of an [Element].
abstract class ElementImpl implements Element {
  static const _metadataFlag_isReady = 1 << 0;
  static const _metadataFlag_hasDeprecated = 1 << 1;
  static const _metadataFlag_hasOverride = 1 << 2;

  static int _NEXT_ID = 0;

  @override
  final int id = _NEXT_ID++;

  /// The enclosing element of this element, or `null` if this element is at the
  /// root of the element structure.
  ElementImpl? _enclosingElement;

  /// The name of this element.
  String? _name;

  /// The offset of the name of this element in the file that contains the
  /// declaration of this element.
  int _nameOffset = 0;

  /// A bit-encoded form of the modifiers associated with this element.
  int _modifiers = 0;

  /// A list containing all of the metadata associated with this element.
  List<ElementAnnotation> _metadata = const [];

  /// Cached flags denoting presence of specific annotations in [_metadata].
  int _metadataFlags = 0;

  /// A cached copy of the calculated location for this element.
  ElementLocation? _cachedLocation;

  /// The documentation comment for this element.
  String? _docComment;

  /// The offset of the beginning of the element's code in the file that
  /// contains the element, or `null` if the element is synthetic.
  int? _codeOffset;

  /// The length of the element's code, or `null` if the element is synthetic.
  int? _codeLength;

  /// Initialize a newly created element to have the given [name] at the given
  /// [_nameOffset].
  ElementImpl(this._name, this._nameOffset);

  /// The length of the element's code, or `null` if the element is synthetic.
  int? get codeLength => _codeLength;

  /// The offset of the beginning of the element's code in the file that
  /// contains the element, or `null` if the element is synthetic.
  int? get codeOffset => _codeOffset;

  @override
  Element get declaration => this;

  @override
  String get displayName => _name ?? '';

  @override
  String? get documentationComment => _docComment;

  /// The documentation comment source for this element.
  set documentationComment(String? doc) {
    _docComment = doc;
  }

  @override
  Element? get enclosingElement => _enclosingElement;

  /// Set the enclosing element of this element to the given [element].
  set enclosingElement(Element? element) {
    _enclosingElement = element as ElementImpl?;
  }

  /// Return the enclosing unit element (which might be the same as `this`), or
  /// `null` if this element is not contained in any compilation unit.
  CompilationUnitElementImpl get enclosingUnit {
    return _enclosingElement!.enclosingUnit;
  }

  /// Return an identifier that uniquely identifies this element among the
  /// children of this element's parent.
  String get identifier => name!;

  @override
  bool get isPrivate {
    final name = this.name;
    if (name == null) {
      return true;
    }
    return Identifier.isPrivateName(name);
  }

  @override
  bool get isPublic => !isPrivate;

  @override
  bool get isSynthetic {
    return hasModifier(Modifier.SYNTHETIC);
  }

  /// Set whether this element is synthetic.
  set isSynthetic(bool isSynthetic) {
    setModifier(Modifier.SYNTHETIC, isSynthetic);
  }

  @override
  ElementLocation get location {
    return _cachedLocation ??= ElementLocationImpl.con1(this);
  }

  @override
  List<ElementAnnotation> get metadata {
    return _metadata;
  }

  set metadata(List<ElementAnnotation> metadata) {
    _metadata = metadata;
  }

  @override
  String? get name => _name;

  /// Changes the name of this element.
  set name(String? name) {
    _name = name;
  }

  @override
  int get nameLength => displayName.length;

  @override
  int get nameOffset => _nameOffset;

  /// Sets the offset of the name of this element in the file that contains the
  /// declaration of this element.
  set nameOffset(int offset) {
    _nameOffset = offset;
  }

  @override
  Element get nonSynthetic => this;

  /// Return the context to resolve type parameters in, or `null` if neither
  /// this element nor any of its ancestors is of a kind that can declare type
  /// parameters.
  TypeParameterizedElementMixin? get typeParameterContext {
    return _enclosingElement?.typeParameterContext;
  }

  NullabilitySuffix get _noneOrStarSuffix {
    return NullabilitySuffix.star;
  }

  @override
  bool operator ==(Object object) {
    if (identical(this, object)) {
      return true;
    }
    return object is Element &&
        object.kind == kind &&
        object.location == location;
  }

  /// Set this element as the enclosing element for given [element].
  void encloseElement(ElementImpl element) {
    element.enclosingElement = this;
  }

  /// Set this element as the enclosing element for given [elements].
  void encloseElements(List<Element> elements) {
    for (Element element in elements) {
      (element as ElementImpl)._enclosingElement = this;
    }
  }

  @override
  String getDisplayString({
    required bool withNullability,
    bool multiline = false,
  }) {
    var builder = ElementDisplayStringBuilder(
      skipAllDynamicArguments: false,
      withNullability: withNullability,
      multiline: multiline,
    );
    return builder.toString();
  }

  /// Return `true` if this element has the given [modifier] associated with it.
  bool hasModifier(Modifier modifier) =>
      BooleanArray.get(_modifiers, modifier.ordinal);

  /// Use the given [visitor] to visit all of the [children] in the given array.
  void safelyVisitChildren(List<Element> children, ElementVisitor visitor) {
    for (Element child in children) {
      child.accept(visitor);
    }
  }

  /// Set the code range for this element.
  void setCodeRange(int offset, int length) {
    _codeOffset = offset;
    _codeLength = length;
  }

  /// Set whether the given [modifier] is associated with this element to
  /// correspond to the given [value].
  void setModifier(Modifier modifier, bool value) {
    _modifiers = BooleanArray.set(_modifiers, modifier.ordinal, value);
  }

  @override
  E thisOrAncestorMatching<E extends Element>(
    bool Function(Element) predicate,
  ) {
    Element? element = this;
    while (element != null && !predicate(element)) {
      element = element.enclosingElement;
    }
    return element as E;
  }

  @override
  E? thisOrAncestorOfType<E extends Element>() {
    Element? element = this;
    while (element != null && element is! E) {
      element = element.enclosingElement;
    }
    return element as E?;
  }

  @override
  String toString() {
    return getDisplayString(withNullability: true);
  }

  @override
  void visitChildren(ElementVisitor visitor) {
    // There are no children to visit
  }

  /// Return flags that denote presence of a few specific annotations.
  int _getMetadataFlags() {
    var result = _metadataFlags;

    // Has at least `_metadataFlag_isReady`.
    if (result != 0) {
      return result;
    }

    final metadata = this.metadata;
    for (var i = 0; i < metadata.length; i++) {
      var annotation = metadata[i];
      if (annotation.isDeprecated) {
        result |= _metadataFlag_hasDeprecated;
      } else if (annotation.isOverride) {
        result |= _metadataFlag_hasOverride;
      }
    }

    result |= _metadataFlag_isReady;
    return _metadataFlags = result;
  }
}

/// Abstract base class for elements whose type is guaranteed to be a function
/// type.
abstract class ElementImplWithFunctionType implements Element {
  /// Gets the element's return type, without going through the indirection of
  /// [ElementTypeProvider].
  ///
  /// In most cases, the element's `returnType` getter should be used instead.
  DartType get returnTypeInternal;

  /// Gets the element's type, without going through the indirection of
  /// [ElementTypeProvider].
  ///
  /// In most cases, the element's `type` getter should be used instead.
  FunctionType get typeInternal;
}

/// A concrete implementation of an [ElementLocation].
class ElementLocationImpl implements ElementLocation {
  /// The character used to separate components in the encoded form.
  static const int _SEPARATOR_CHAR = 0x3B;

  /// The path to the element whose location is represented by this object.
  late final List<String> _components;

  /// The object managing [indexKeyId] and [indexLocationId].
  Object? indexOwner;

  /// A cached id of this location in index.
  int? indexKeyId;

  /// A cached id of this location in index.
  int? indexLocationId;

  /// Initialize a newly created location to represent the given [element].
  ElementLocationImpl.con1(Element element) {
    List<String> components = <String>[];
    Element? ancestor = element;
    while (ancestor != null) {
      components.insert(0, (ancestor as ElementImpl).identifier);
      ancestor = ancestor.enclosingElement;
    }
    _components = components;
  }

  /// Initialize a newly created location from the given [encoding].
  ElementLocationImpl.con2(String encoding) {
    _components = _decode(encoding);
  }

  /// Initialize a newly created location from the given [components].
  ElementLocationImpl.con3(List<String> components) {
    _components = components;
  }

  @override
  List<String> get components => _components;

  @override
  String get encoding {
    StringBuffer buffer = StringBuffer();
    int length = _components.length;
    for (int i = 0; i < length; i++) {
      if (i > 0) {
        buffer.writeCharCode(_SEPARATOR_CHAR);
      }
      _encode(buffer, _components[i]);
    }
    return buffer.toString();
  }

  @override
  int get hashCode => Object.hashAll(_components);

  @override
  bool operator ==(Object object) {
    if (identical(this, object)) {
      return true;
    }
    if (object is ElementLocationImpl) {
      List<String> otherComponents = object._components;
      int length = _components.length;
      if (otherComponents.length != length) {
        return false;
      }
      for (int i = 0; i < length; i++) {
        if (_components[i] != otherComponents[i]) {
          return false;
        }
      }
      return true;
    }
    return false;
  }

  @override
  String toString() => encoding;

  /// Decode the [encoding] of a location into a list of components and return
  /// the components.
  List<String> _decode(String encoding) {
    List<String> components = <String>[];
    StringBuffer buffer = StringBuffer();
    int index = 0;
    int length = encoding.length;
    while (index < length) {
      int currentChar = encoding.codeUnitAt(index);
      if (currentChar == _SEPARATOR_CHAR) {
        if (index + 1 < length &&
            encoding.codeUnitAt(index + 1) == _SEPARATOR_CHAR) {
          buffer.writeCharCode(_SEPARATOR_CHAR);
          index += 2;
        } else {
          components.add(buffer.toString());
          buffer = StringBuffer();
          index++;
        }
      } else {
        buffer.writeCharCode(currentChar);
        index++;
      }
    }
    components.add(buffer.toString());
    return components;
  }

  /// Append an encoded form of the given [component] to the given [buffer].
  void _encode(StringBuffer buffer, String component) {
    int length = component.length;
    for (int i = 0; i < length; i++) {
      int currentChar = component.codeUnitAt(i);
      if (currentChar == _SEPARATOR_CHAR) {
        buffer.writeCharCode(_SEPARATOR_CHAR);
      }
      buffer.writeCharCode(currentChar);
    }
  }
}

/// A base class for concrete implementations of an [ExecutableElement].
abstract class ExecutableElementImpl extends ElementImpl
    with TypeParameterizedElementMixin
    implements ExecutableElement, ElementImplWithFunctionType {
  /// A list containing all of the parameters defined by this executable
  /// element.
  List<ParameterElement> _parameters = const [];

  /// The inferred return type of this executable element.
  DartType? _returnType;

  /// The type of function defined by this executable element.
  FunctionType? _type;

  /// Initialize a newly created executable element to have the given [name] and
  /// [offset].
  ExecutableElementImpl(String name, int offset) : super(name, offset);

  @override
  Element get enclosingElement => super.enclosingElement!;

  @override
  bool get hasImplicitReturnType {
    return hasModifier(Modifier.IMPLICIT_TYPE);
  }

  /// Set whether this executable element has an implicit return type.
  set hasImplicitReturnType(bool hasImplicitReturnType) {
    setModifier(Modifier.IMPLICIT_TYPE, hasImplicitReturnType);
  }

  @override
  bool get isGenerator {
    return hasModifier(Modifier.GENERATOR);
  }

  /// Set whether this method's body is a generator.
  set isGenerator(bool isGenerator) {
    setModifier(Modifier.GENERATOR, isGenerator);
  }

  @override
  bool get isOperator => false;

  @override
  List<ParameterElement> get parameters =>
      ElementTypeProvider.current.getExecutableParameters(this);

  /// Set the parameters defined by this executable element to the given
  /// [parameters].
  set parameters(List<ParameterElement> parameters) {
    for (ParameterElement parameter in parameters) {
      (parameter as ParameterElementImpl).enclosingElement = this;
    }
    _parameters = parameters;
  }

  /// Gets the element's parameters, without going through the indirection of
  /// [ElementTypeProvider].
  ///
  /// In most cases, the [parameters] getter should be used instead.
  List<ParameterElement> get parametersInternal {
    return _parameters;
  }

  @override
  DartType get returnType =>
      ElementTypeProvider.current.getExecutableReturnType(this);

  set returnType(DartType returnType) {
    _returnType = returnType;
    // We do this because of return type inference. At the moment when we
    // create a local function element we don't know yet its return type,
    // because we have not done static type analysis yet.
    // It somewhere it between we access the type of this element, so it gets
    // cached in the element. When we are done static type analysis, we then
    // should clear this cached type to make it right.
    // TODO(scheglov) Remove when type analysis is done in the single pass.
    _type = null;
  }

  @override
  DartType get returnTypeInternal {
    return _returnType!;
  }

  @override
  FunctionType get type => ElementTypeProvider.current.getExecutableType(this);

  set type(FunctionType type) {
    _type = type;
  }

  @override
  FunctionType get typeInternal {
    if (_type != null) return _type!;

    return _type = FunctionTypeImpl(
      typeFormals: typeParameters,
      parameters: parameters,
      returnType: returnType,
      nullabilitySuffix: _noneOrStarSuffix,
    );
  }

  /// Set the type parameters defined by this executable element to the given
  /// [typeParameters].
  set typeParameters(List<TypeParameterElement> typeParameters) {
    for (TypeParameterElement parameter in typeParameters) {
      (parameter as TypeParameterElementImpl).enclosingElement = this;
    }
    _typeParameterElements = typeParameters;
  }

  @override
  void appendTo(ElementDisplayStringBuilder builder) {
    builder.writeExecutableElement(this, displayName);
  }

  @override
  void visitChildren(ElementVisitor visitor) {
    super.visitChildren(visitor);
    safelyVisitChildren(typeParameters, visitor);
    safelyVisitChildren(parameters, visitor);
  }
}

/// A concrete implementation of a [FieldElement].
class FieldElementImpl extends PropertyInducingElementImpl
    implements FieldElement {
  /// True if this field inherits from a covariant parameter. This happens
  /// when it overrides a field in a supertype that is covariant.
  bool inheritsCovariant = false;

  /// Initialize a newly created synthetic field element to have the given
  /// [name] at the given [offset].
  FieldElementImpl(String name, int offset) : super(name, offset);

  @override
  FieldElement get declaration => this;

  @override
  bool get isAbstract {
    return hasModifier(Modifier.ABSTRACT);
  }

  @override
  bool get isCovariant {
    return hasModifier(Modifier.COVARIANT);
  }

  /// Set whether this field is explicitly marked as being covariant.
  set isCovariant(bool isCovariant) {
    setModifier(Modifier.COVARIANT, isCovariant);
  }

  @override
  bool get isEnumConstant => false;

  @override
  bool get isExternal {
    return hasModifier(Modifier.EXTERNAL);
  }

  @override
  bool get isStatic {
    return hasModifier(Modifier.STATIC);
  }

  /// Set whether this field is static.
  set isStatic(bool isStatic) {
    setModifier(Modifier.STATIC, isStatic);
  }

  @override
  ElementKind get kind => ElementKind.FIELD;

  @override
  T? accept<T>(ElementVisitor<T> visitor) => visitor.visitFieldElement(this);
}

/// A [ParameterElementImpl] that has the additional information of the
/// [FieldElement] associated with the parameter.
class FieldFormalParameterElementImpl extends ParameterElementImpl
    implements FieldFormalParameterElement {
  @override
  FieldElement? field;

  /// Initialize a newly created parameter element to have the given [name] and
  /// [nameOffset].
  FieldFormalParameterElementImpl({
    required String name,
    required int nameOffset,
    required ParameterKind parameterKind,
  }) : super(
          name: name,
          nameOffset: nameOffset,
          parameterKind: parameterKind,
        );

  /// Initializing formals are visible only in the "formal parameter
  /// initializer scope", which is the current scope of the initializer list
  /// of the constructor, and which is enclosed in the scope where the
  /// constructor is declared. And according to the specification, they
  /// introduce final local variables, always, regardless whether the field
  /// is final.
  @override
  bool get isFinal => true;

  @override
  bool get isInitializingFormal => true;

  @override
  T? accept<T>(ElementVisitor<T> visitor) =>
      visitor.visitFieldFormalParameterElement(this);
}

/// A concrete implementation of a [FunctionElement].
class FunctionElementImpl extends ExecutableElementImpl
    implements FunctionElement, FunctionTypedElementImpl {
  /// Initialize a newly created function element to have the given [name] and
  /// [offset].
  FunctionElementImpl(String name, int offset) : super(name, offset);

  /// Initialize a newly created function element to have no name and the given
  /// [nameOffset]. This is used for function expressions, that have no name.
  FunctionElementImpl.forOffset(int nameOffset) : super("", nameOffset);

  @override
  ExecutableElement get declaration => this;

  @override
  String get identifier {
    String identifier = super.identifier;
    Element? enclosing = enclosingElement;
    if (enclosing is ExecutableElement || enclosing is VariableElement) {
      identifier += "@$nameOffset";
    }
    return identifier;
  }

  @override
  bool get isEntryPoint {
    return isStatic && displayName == FunctionElement.MAIN_FUNCTION_NAME;
  }

  @override
  bool get isStatic => enclosingElement is CompilationUnitElement;

  @override
  ElementKind get kind => ElementKind.FUNCTION;

  @override
  T? accept<T>(ElementVisitor<T> visitor) => visitor.visitFunctionElement(this);
}

/// Common internal interface shared by elements whose type is a function type.
///
/// Clients may not extend, implement or mix-in this class.
abstract class FunctionTypedElementImpl
    implements ElementImpl, FunctionTypedElement {
  set returnType(DartType returnType);
}

/// The element used for a generic function type.
///
/// Clients may not extend, implement or mix-in this class.
class GenericFunctionTypeElementImpl extends ElementImpl
    with TypeParameterizedElementMixin
    implements
        GenericFunctionTypeElement,
        FunctionTypedElementImpl,
        ElementImplWithFunctionType {
  /// The declared return type of the function.
  DartType? _returnType;

  /// The elements representing the parameters of the function.
  List<ParameterElement> _parameters = const [];

  /// Is `true` if the type has the question mark, so is nullable.
  bool isNullable = false;

  /// The type defined by this element.
  FunctionType? _type;

  /// Initialize a newly created function element to have no name and the given
  /// [nameOffset]. This is used for function expressions, that have no name.
  GenericFunctionTypeElementImpl.forOffset(int nameOffset)
      : super("", nameOffset);

  @override
  String get identifier => '-';

  @override
  ElementKind get kind => ElementKind.GENERIC_FUNCTION_TYPE;

  @override
  List<ParameterElement> get parameters {
    return _parameters;
  }

  /// Set the parameters defined by this function type element to the given
  /// [parameters].
  set parameters(List<ParameterElement> parameters) {
    for (ParameterElement parameter in parameters) {
      (parameter as ParameterElementImpl).enclosingElement = this;
    }
    _parameters = parameters;
  }

  @override
  DartType get returnType =>
      ElementTypeProvider.current.getExecutableReturnType(this);

  /// Set the return type defined by this function type element to the given
  /// [returnType].
  @override
  set returnType(DartType returnType) {
    _returnType = returnType;
  }

  @override
  DartType get returnTypeInternal {
    return _returnType!;
  }

  @override
  FunctionType get type => ElementTypeProvider.current.getExecutableType(this);

  /// Set the function type defined by this function type element to the given
  /// [type].
  set type(FunctionType type) {
    _type = type;
  }

  @override
  FunctionType get typeInternal {
    if (_type != null) return _type!;

    return _type = FunctionTypeImpl(
      typeFormals: typeParameters,
      parameters: parameters,
      returnType: returnType,
      nullabilitySuffix:
          isNullable ? NullabilitySuffix.question : _noneOrStarSuffix,
    );
  }

  /// Set the type parameters defined by this function type element to the given
  /// [typeParameters].
  set typeParameters(List<TypeParameterElement> typeParameters) {
    for (TypeParameterElement parameter in typeParameters) {
      (parameter as TypeParameterElementImpl).enclosingElement = this;
    }
    _typeParameterElements = typeParameters;
  }

  @override
  T? accept<T>(ElementVisitor<T> visitor) {
    return visitor.visitGenericFunctionTypeElement(this);
  }

  @override
  void appendTo(ElementDisplayStringBuilder builder) {
    builder.writeGenericFunctionTypeElement(this);
  }

  @override
  void visitChildren(ElementVisitor visitor) {
    super.visitChildren(visitor);
    safelyVisitChildren(typeParameters, visitor);
    safelyVisitChildren(parameters, visitor);
  }
}

/// A concrete implementation of a [HideElementCombinator].
class HideElementCombinatorImpl implements HideElementCombinator {
  @override
  List<String> hiddenNames = const [];

  @override
  String toString() {
    StringBuffer buffer = StringBuffer();
    buffer.write("show ");
    int count = hiddenNames.length;
    for (int i = 0; i < count; i++) {
      if (i > 0) {
        buffer.write(", ");
      }
      buffer.write(hiddenNames[i]);
    }
    return buffer.toString();
  }
}

/// A concrete implementation of a [LabelElement].
class LabelElementImpl extends ElementImpl implements LabelElement {
  /// A flag indicating whether this label is associated with a `switch`
  /// statement.
  // TODO(brianwilkerson) Make this a modifier.
  final bool _onSwitchStatement;

  /// A flag indicating whether this label is associated with a `switch` member
  /// (`case` or `default`).
  // TODO(brianwilkerson) Make this a modifier.
  final bool _onSwitchMember;

  /// Initialize a newly created label element to have the given [name].
  /// [onSwitchStatement] should be `true` if this label is associated with a
  /// `switch` statement and [onSwitchMember] should be `true` if this label is
  /// associated with a `switch` member.
  LabelElementImpl(String name, int nameOffset, this._onSwitchStatement,
      this._onSwitchMember)
      : super(name, nameOffset);

  @override
  String get displayName => name;

  @override
  ExecutableElement get enclosingElement =>
      super.enclosingElement as ExecutableElement;

  /// Return `true` if this label is associated with a `switch` member (`case
  /// ` or`default`).
  bool get isOnSwitchMember => _onSwitchMember;

  /// Return `true` if this label is associated with a `switch` statement.
  bool get isOnSwitchStatement => _onSwitchStatement;

  @override
  ElementKind get kind => ElementKind.LABEL;

  @override
  String get name => super.name!;

  @override
  T? accept<T>(ElementVisitor<T> visitor) => visitor.visitLabelElement(this);
}

/// A concrete implementation of a [LocalVariableElement].
class LocalVariableElementImpl extends NonParameterVariableElementImpl
    implements LocalVariableElement {
  @override
  late bool hasInitializer;

  /// Initialize a newly created method element to have the given [name] and
  /// [offset].
  LocalVariableElementImpl(String name, int offset) : super(name, offset);

  @override
  String get identifier {
    return '$name$nameOffset';
  }

  @override
  bool get isLate {
    return hasModifier(Modifier.LATE);
  }

  @override
  ElementKind get kind => ElementKind.LOCAL_VARIABLE;

  @override
  T? accept<T>(ElementVisitor<T> visitor) =>
      visitor.visitLocalVariableElement(this);
}

/// A concrete implementation of a [MethodElement].
class MethodElementImpl extends ExecutableElementImpl implements MethodElement {
  /// Is `true` if this method is `operator==`, and there is no explicit
  /// type specified for its formal parameter, in this method or in any
  /// overridden methods other than the one declared in `Object`.
  bool isOperatorEqualWithParameterTypeFromObject = false;

  /// If this method is a synthetic element which is based on another method
  /// with some modifications (such as making some parameters covariant),
  /// this field contains the base method.
  MethodElement? prototype;

  /// Initialize a newly created method element to have the given [name] at the
  /// given [offset].
  MethodElementImpl(String name, int offset) : super(name, offset);

  @override
  MethodElement get declaration => prototype ?? this;

  @override
  String get displayName {
    String displayName = super.displayName;
    if ("unary-" == displayName) {
      return "-";
    }
    return displayName;
  }

  /// Set whether this class is abstract.
  set isAbstract(bool isAbstract) {
    setModifier(Modifier.ABSTRACT, isAbstract);
  }

  @override
  bool get isOperator {
    String name = displayName;
    if (name.isEmpty) {
      return false;
    }
    int first = name.codeUnitAt(0);
    return !((0x61 <= first && first <= 0x7A) ||
        (0x41 <= first && first <= 0x5A) ||
        first == 0x5F ||
        first == 0x24);
  }

  @override
  bool get isStatic {
    return hasModifier(Modifier.STATIC);
  }

  /// Set whether this method is static.
  set isStatic(bool isStatic) {
    setModifier(Modifier.STATIC, isStatic);
  }

  @override
  ElementKind get kind => ElementKind.METHOD;

  @override
  T? accept<T>(ElementVisitor<T> visitor) => visitor.visitMethodElement(this);
}

/// The constants for all of the modifiers defined by the Dart language and for
/// a few additional flags that are useful.
///
/// Clients may not extend, implement or mix-in this class.
class Modifier implements Comparable<Modifier> {
  /// Indicates that the modifier 'abstract' was applied to the element.
  static const Modifier ABSTRACT = Modifier('ABSTRACT', 0);

  /// Indicates that an executable element has a body marked as being
  /// asynchronous.
  static const Modifier ASYNCHRONOUS = Modifier('ASYNCHRONOUS', 1);

  /// Indicates that the modifier 'const' was applied to the element.
  static const Modifier CONST = Modifier('CONST', 2);

  /// Indicates that the modifier 'covariant' was applied to the element.
  static const Modifier COVARIANT = Modifier('COVARIANT', 3);

  /// Indicates that the class is `Object` from `dart:core`.
  static const Modifier DART_CORE_OBJECT = Modifier('DART_CORE_OBJECT', 4);

  /// Indicates that the import element represents a deferred library.
  static const Modifier DEFERRED = Modifier('DEFERRED', 5);

  /// Indicates that a class element was defined by an enum declaration.
  static const Modifier ENUM = Modifier('ENUM', 6);

  /// Indicates that a class element was defined by an enum declaration.
  static const Modifier EXTERNAL = Modifier('EXTERNAL', 7);

  /// Indicates that the modifier 'factory' was applied to the element.
  static const Modifier FACTORY = Modifier('FACTORY', 8);

  /// Indicates that the modifier 'final' was applied to the element.
  static const Modifier FINAL = Modifier('FINAL', 9);

  /// Indicates that an executable element has a body marked as being a
  /// generator.
  static const Modifier GENERATOR = Modifier('GENERATOR', 10);

  /// Indicates that the pseudo-modifier 'get' was applied to the element.
  static const Modifier GETTER = Modifier('GETTER', 11);

  /// A flag used for libraries indicating that the variable has an explicit
  /// initializer.
  static const Modifier HAS_INITIALIZER = Modifier('HAS_INITIALIZER', 12);

  /// A flag used for fields and top-level variables that have implicit type,
  /// and specify when the type has been inferred.
  static const Modifier HAS_TYPE_INFERRED = Modifier('HAS_TYPE_INFERRED', 13);

  /// A flag used for libraries indicating that the defining compilation unit
  /// has a `part of` directive, meaning that this unit should be a part,
  /// but is used as a library.
  static const Modifier HAS_PART_OF_DIRECTIVE =
      Modifier('HAS_PART_OF_DIRECTIVE', 14);

  /// Indicates that the associated element did not have an explicit type
  /// associated with it. If the element is an [ExecutableElement], then the
  /// type being referred to is the return type.
  static const Modifier IMPLICIT_TYPE = Modifier('IMPLICIT_TYPE', 15);

  /// Indicates that modifier 'lazy' was applied to the element.
  static const Modifier LATE = Modifier('LATE', 16);

  /// Indicates that a class is a mixin application.
  static const Modifier MIXIN_APPLICATION = Modifier('MIXIN_APPLICATION', 17);

  /// Indicates that the pseudo-modifier 'set' was applied to the element.
  static const Modifier SETTER = Modifier('SETTER', 18);

  /// Indicates that the modifier 'static' was applied to the element.
  static const Modifier STATIC = Modifier('STATIC', 19);

  /// Indicates that the element does not appear in the source code but was
  /// implicitly created. For example, if a class does not define any
  /// constructors, an implicit zero-argument constructor will be created and it
  /// will be marked as being synthetic.
  static const Modifier SYNTHETIC = Modifier('SYNTHETIC', 20);

  static const List<Modifier> values = [
    ABSTRACT,
    ASYNCHRONOUS,
    CONST,
    COVARIANT,
    DART_CORE_OBJECT,
    DEFERRED,
    ENUM,
    EXTERNAL,
    FACTORY,
    FINAL,
    GENERATOR,
    GETTER,
    HAS_INITIALIZER,
    HAS_PART_OF_DIRECTIVE,
    IMPLICIT_TYPE,
    LATE,
    MIXIN_APPLICATION,
    SETTER,
    STATIC,
    SYNTHETIC
  ];

  /// The name of this modifier.
  final String name;

  /// The ordinal value of the modifier.
  final int ordinal;

  const Modifier(this.name, this.ordinal);

  @override
  int get hashCode => ordinal;

  @override
  int compareTo(Modifier other) => ordinal - other.ordinal;

  @override
  String toString() => name;
}

/// A concrete implementation of a [MultiplyDefinedElement].
class MultiplyDefinedElementImpl implements MultiplyDefinedElement {
  /// The unique integer identifier of this element.
  @override
  final int id = ElementImpl._NEXT_ID++;

  /// The name of the conflicting elements.
  @override
  final String name;

  @override
  final List<Element> conflictingElements;

  /// Initialize a newly created element in the given [context] to represent
  /// the given non-empty [conflictingElements].
  MultiplyDefinedElementImpl(this.name, this.conflictingElements);

  @override
  String get displayName => name;

  @override
  String? get documentationComment => null;

  @override
  Element? get enclosingElement => null;

  @override
  bool get isPrivate {
    throw UnimplementedError();
  }

  @override
  bool get isPublic => !isPrivate;

  @override
  bool get isSynthetic => true;

  bool get isVisibleForTemplate => false;

  @override
  ElementKind get kind => ElementKind.ERROR;

  @override
  ElementLocation? get location => null;

  @override
  List<ElementAnnotation> get metadata => const <ElementAnnotation>[];

  @override
  int get nameLength => 0;

  @override
  int get nameOffset => -1;

  @override
  Element get nonSynthetic => this;

  @override
  T? accept<T>(ElementVisitor<T> visitor) =>
      visitor.visitMultiplyDefinedElement(this);

  @override
  String getDisplayString({
    required bool withNullability,
    bool multiline = false,
  }) {
    var elementsStr = conflictingElements.map((e) {
      return e.getDisplayString(
        withNullability: withNullability,
      );
    }).join(', ');
    return '[' + elementsStr + ']';
  }

  @override
  E? thisOrAncestorMatching<E extends Element>(
    bool Function(Element) predicate,
  ) {
    return null;
  }

  @override
  E? thisOrAncestorOfType<E extends Element>() => null;

  @override
  String toString() {
    StringBuffer buffer = StringBuffer();
    bool needsSeparator = false;
    void writeList(List<Element> elements) {
      for (Element element in elements) {
        if (needsSeparator) {
          buffer.write(", ");
        } else {
          needsSeparator = true;
        }
        buffer.write(
          element.getDisplayString(withNullability: true),
        );
      }
    }

    buffer.write("[");
    writeList(conflictingElements);
    buffer.write("]");
    return buffer.toString();
  }

  @override
  void visitChildren(ElementVisitor visitor) {
    // There are no children to visit
  }

  @override
  Element get declaration => throw UnimplementedError();
}

/// A [VariableElementImpl], which is not a parameter.
abstract class NonParameterVariableElementImpl extends VariableElementImpl {
  /// Initialize a newly created variable element to have the given [name] and
  /// [offset].
  NonParameterVariableElementImpl(String name, int offset)
      : super(name, offset);

  @override
  Element get enclosingElement => super.enclosingElement!;

  bool get hasInitializer {
    return hasModifier(Modifier.HAS_INITIALIZER);
  }

  /// Set whether this variable has an initializer.
  set hasInitializer(bool hasInitializer) {
    setModifier(Modifier.HAS_INITIALIZER, hasInitializer);
  }
}

/// A concrete implementation of a [ParameterElement].
class ParameterElementImpl extends VariableElementImpl
    with ParameterElementMixin
    implements ParameterElement {
  /// A list containing all of the parameters defined by this parameter element.
  /// There will only be parameters if this parameter is a function typed
  /// parameter.
  List<ParameterElement> _parameters = const [];

  /// A list containing all of the type parameters defined for this parameter
  /// element. There will only be parameters if this parameter is a function
  /// typed parameter.
  List<TypeParameterElement> _typeParameters = const [];

  @override
  final ParameterKind parameterKind;

  @override
  String? defaultValueCode;

  /// True if this parameter inherits from a covariant parameter. This happens
  /// when it overrides a method in a supertype that has a corresponding
  /// covariant parameter.
  bool inheritsCovariant = false;

  /// Initialize a newly created parameter element to have the given [name] and
  /// [nameOffset].
  ParameterElementImpl({
    required String? name,
    required int nameOffset,
    required this.parameterKind,
  }) : super(name, nameOffset);

  /// Creates a synthetic parameter with [name], [type] and [parameterKind].
  factory ParameterElementImpl.synthetic(
      String? name, DartType type, ParameterKind parameterKind) {
    var element = ParameterElementImpl(
      name: name,
      nameOffset: -1,
      parameterKind: parameterKind,
    );
    element.type = type;
    element.isSynthetic = true;
    return element;
  }

  @override
  ParameterElement get declaration => this;

  @override
  bool get hasDefaultValue {
    return defaultValueCode != null;
  }

  @override
  bool get isCovariant {
    if (isExplicitlyCovariant || inheritsCovariant) {
      return true;
    }
    return false;
  }

  /// Return true if this parameter is explicitly marked as being covariant.
  bool get isExplicitlyCovariant {
    return hasModifier(Modifier.COVARIANT);
  }

  /// Set whether this variable parameter is explicitly marked as being
  /// covariant.
  set isExplicitlyCovariant(bool isCovariant) {
    setModifier(Modifier.COVARIANT, isCovariant);
  }

  @override
  bool get isInitializingFormal => false;

  @override
  bool get isLate => false;

  @override
  bool get isSuperFormal => false;

  @override
  ElementKind get kind => ElementKind.PARAMETER;

  @override
  List<ParameterElement> get parameters {
    return _parameters;
  }

  /// Set the parameters defined by this executable element to the given
  /// [parameters].
  set parameters(List<ParameterElement> parameters) {
    for (ParameterElement parameter in parameters) {
      (parameter as ParameterElementImpl).enclosingElement = this;
    }
    _parameters = parameters;
  }

  @override
  List<TypeParameterElement> get typeParameters {
    return _typeParameters;
  }

  /// Set the type parameters defined by this parameter element to the given
  /// [typeParameters].
  set typeParameters(List<TypeParameterElement> typeParameters) {
    for (TypeParameterElement parameter in typeParameters) {
      (parameter as TypeParameterElementImpl).enclosingElement = this;
    }
    _typeParameters = typeParameters;
  }

  @override
  T? accept<T>(ElementVisitor<T> visitor) =>
      visitor.visitParameterElement(this);

  @override
  void appendTo(ElementDisplayStringBuilder builder) {
    builder.writeFormalParameter(this);
  }

  @override
  void visitChildren(ElementVisitor visitor) {
    super.visitChildren(visitor);
    safelyVisitChildren(parameters, visitor);
  }
}

/// The parameter of an implicit setter.
class ParameterElementImpl_ofImplicitSetter extends ParameterElementImpl {
  final PropertyAccessorElementImpl_ImplicitSetter setter;

  ParameterElementImpl_ofImplicitSetter(
      PropertyAccessorElementImpl_ImplicitSetter setter)
      : setter = setter,
        super(
          name: '_${setter.variable.name}',
          nameOffset: -1,
          parameterKind: ParameterKind.REQUIRED,
        ) {
    enclosingElement = setter;
    isSynthetic = true;
  }

  @override
  bool get inheritsCovariant {
    var variable = setter.variable;
    if (variable is FieldElementImpl) {
      return variable.inheritsCovariant;
    }
    return false;
  }

  @override
  set inheritsCovariant(bool value) {
    var variable = setter.variable;
    if (variable is FieldElementImpl) {
      variable.inheritsCovariant = value;
    }
  }

  @override
  bool get isCovariant {
    if (isExplicitlyCovariant || inheritsCovariant) {
      return true;
    }
    return false;
  }

  @override
  bool get isExplicitlyCovariant {
    var variable = setter.variable;
    if (variable is FieldElementImpl) {
      return variable.isCovariant;
    }
    return false;
  }

  @override
  Element get nonSynthetic {
    return setter.variable;
  }

  @override
  DartType get type => ElementTypeProvider.current.getVariableType(this);

  @override
  set type(DartType type) {
    assert(false); // Should never be called.
  }

  @override
  DartType get typeInternal => setter.variable.type;
}

/// A mixin that provides a common implementation for methods defined in
/// [ParameterElement].
mixin ParameterElementMixin implements ParameterElement {
  @override
  bool get isNamed => parameterKind.isNamed;

  @override
  bool get isNotOptional => parameterKind.isRequired;

  @override
  bool get isOptional => parameterKind.isOptional;

  @override
  bool get isOptionalNamed => parameterKind.isOptionalNamed;

  @override
  bool get isOptionalPositional => parameterKind.isOptionalPositional;

  @override
  bool get isPositional => parameterKind.isPositional;

  @override
  bool get isRequiredNamed => parameterKind.isRequiredNamed;

  @override
  bool get isRequiredPositional => parameterKind.isRequiredPositional;

  @override
  // Overridden to remove the 'deprecated' annotation.
  ParameterKind get parameterKind;

  @override
  void appendToWithoutDelimiters(
    StringBuffer buffer, {
    bool withNullability = false,
  }) {
    buffer.write(
      type.getDisplayString(
        withNullability: withNullability,
      ),
    );
    buffer.write(' ');
    buffer.write(displayName);
    if (defaultValueCode != null) {
      buffer.write(' = ');
      buffer.write(defaultValueCode);
    }
  }
}

/// A concrete implementation of a [PropertyAccessorElement].
class PropertyAccessorElementImpl extends ExecutableElementImpl
    implements PropertyAccessorElement {
  /// The variable associated with this accessor.
  @override
  late PropertyInducingElement variable;

  /// If this method is a synthetic element which is based on another method
  /// with some modifications (such as making some parameters covariant),
  /// this field contains the base method.
  PropertyAccessorElement? prototype;

  /// Initialize a newly created property accessor element to have the given
  /// [name] and [offset].
  PropertyAccessorElementImpl(String name, int offset) : super(name, offset);

  /// Initialize a newly created synthetic property accessor element to be
  /// associated with the given [variable].
  PropertyAccessorElementImpl.forVariable(this.variable)
      : super(variable.name, -1);

  @override
  PropertyAccessorElement? get correspondingGetter {
    if (isGetter) {
      return null;
    }
    return variable.getter;
  }

  @override
  PropertyAccessorElement? get correspondingSetter {
    if (isSetter) {
      return null;
    }
    return variable.setter;
  }

  @override
  PropertyAccessorElement get declaration => prototype ?? this;

  @override
  String get identifier {
    String name = displayName;
    String suffix = isGetter ? "?" : "=";
    return "$name$suffix";
  }

  @override
  bool get isGetter {
    return hasModifier(Modifier.GETTER);
  }

  /// Set whether this accessor is a getter.
  set isGetter(bool isGetter) {
    setModifier(Modifier.GETTER, isGetter);
  }

  @override
  bool get isSetter {
    return hasModifier(Modifier.SETTER);
  }

  /// Set whether this accessor is a setter.
  set isSetter(bool isSetter) {
    setModifier(Modifier.SETTER, isSetter);
  }

  @override
  bool get isStatic {
    return hasModifier(Modifier.STATIC);
  }

  /// Set whether this accessor is static.
  set isStatic(bool isStatic) {
    setModifier(Modifier.STATIC, isStatic);
  }

  @override
  ElementKind get kind {
    if (isGetter) {
      return ElementKind.GETTER;
    }
    return ElementKind.SETTER;
  }

  @override
  T? accept<T>(ElementVisitor<T> visitor) =>
      visitor.visitPropertyAccessorElement(this);

  @override
  void appendTo(ElementDisplayStringBuilder builder) {
    builder.writeExecutableElement(
      this,
      (isGetter ? 'get ' : 'set ') + variable.displayName,
    );
  }
}

/// Implicit getter for a [PropertyInducingElementImpl].
class PropertyAccessorElementImpl_ImplicitGetter
    extends PropertyAccessorElementImpl {
  /// Create the implicit getter and bind it to the [property].
  PropertyAccessorElementImpl_ImplicitGetter(
    PropertyInducingElementImpl property,
  ) : super.forVariable(property) {
    property.getter = this;
  }

  @override
  Element get enclosingElement => variable.enclosingElement!;

  @override
  bool get isGetter => true;

  @override
  Element get nonSynthetic {
    return variable;
  }

  @override
  DartType get returnType =>
      ElementTypeProvider.current.getExecutableReturnType(this);

  @override
  set returnType(DartType returnType) {
    assert(false); // Should never be called.
  }

  @override
  DartType get returnTypeInternal => variable.type;

  @override
  FunctionType get type => ElementTypeProvider.current.getExecutableType(this);

  @override
  set type(FunctionType type) {
    assert(false); // Should never be called.
  }

  @override
  FunctionType get typeInternal {
    return _type ??= FunctionTypeImpl(
      typeFormals: const <TypeParameterElement>[],
      parameters: const <ParameterElement>[],
      returnType: returnType,
      nullabilitySuffix: _noneOrStarSuffix,
    );
  }
}

/// Implicit setter for a [PropertyInducingElementImpl].
class PropertyAccessorElementImpl_ImplicitSetter
    extends PropertyAccessorElementImpl {
  /// Create the implicit setter and bind it to the [property].
  PropertyAccessorElementImpl_ImplicitSetter(
    PropertyInducingElementImpl property,
  ) : super.forVariable(property) {
    property.setter = this;
  }

  @override
  Element get enclosingElement => variable.enclosingElement!;

  @override
  bool get isSetter => true;

  @override
  Element get nonSynthetic => variable;

  @override
  List<ParameterElement> get parameters =>
      ElementTypeProvider.current.getExecutableParameters(this);

  @override
  List<ParameterElement> get parametersInternal {
    if (_parameters.isNotEmpty) {
      return _parameters;
    }

    return _parameters = <ParameterElement>[
      ParameterElementImpl_ofImplicitSetter(this)
    ];
  }

  @override
  DartType get returnType =>
      ElementTypeProvider.current.getExecutableReturnType(this);

  @override
  set returnType(DartType returnType) {
    assert(false); // Should never be called.
  }

  @override
  DartType get returnTypeInternal => VoidTypeImpl.instance;

  @override
  FunctionType get type => ElementTypeProvider.current.getExecutableType(this);

  @override
  set type(FunctionType type) {
    assert(false); // Should never be called.
  }

  @override
  FunctionType get typeInternal {
    return _type ??= FunctionTypeImpl(
      typeFormals: const <TypeParameterElement>[],
      parameters: parameters,
      returnType: returnType,
      nullabilitySuffix: _noneOrStarSuffix,
    );
  }
}

/// A concrete implementation of a [PropertyInducingElement].
abstract class PropertyInducingElementImpl
    extends NonParameterVariableElementImpl implements PropertyInducingElement {
  /// The getter associated with this element.
  @override
  PropertyAccessorElement? getter;

  /// The setter associated with this element, or `null` if the element is
  /// effectively `final` and therefore does not have a setter associated with
  /// it.
  @override
  PropertyAccessorElement? setter;

  /// This field is set during linking, and performs type inference for
  /// this property. After linking this field is always `null`.
  PropertyInducingElementTypeInference? typeInference;

  /// Initialize a newly created synthetic element to have the given [name] and
  /// [offset].
  PropertyInducingElementImpl(String name, int offset) : super(name, offset);

  bool get hasTypeInferred => hasModifier(Modifier.HAS_TYPE_INFERRED);

  set hasTypeInferred(bool value) {
    setModifier(Modifier.HAS_TYPE_INFERRED, value);
  }

  @override
  Element get nonSynthetic {
    if (isSynthetic) {
      return (getter ?? setter)!;
    } else {
      return this;
    }
  }

  @override
  DartType get type => ElementTypeProvider.current.getFieldType(this);

  @override
  set type(DartType type) {
    super.type = type;
    // Reset cached types of synthetic getters and setters.
    // TODO(scheglov) Consider not caching these types.
    if (!isSynthetic) {
      var getter = this.getter;
      if (getter is PropertyAccessorElementImpl_ImplicitGetter) {
        getter._type = null;
      }
      var setter = this.setter;
      if (setter is PropertyAccessorElementImpl_ImplicitSetter) {
        setter._type = null;
      }
    }
  }

  @override
  DartType get typeInternal {
    if (_type != null) return _type!;

    if (isSynthetic && _type == null) {
      if (getter != null) {
        _type = getter!.returnType;
      } else if (setter != null) {
        List<ParameterElement> parameters = setter!.parameters;
        _type =
            parameters.isNotEmpty ? parameters[0].type : VoidTypeImpl.instance;
      } else {
        _type = VoidTypeImpl.instance;
      }
    }
    return super.typeInternal;
  }
}

/// Instances of this class are set for fields and top-level variables
/// to perform top-level type inference during linking.
abstract class PropertyInducingElementTypeInference {
  void perform();
}

/// A concrete implementation of a [ShowElementCombinator].
class ShowElementCombinatorImpl implements ShowElementCombinator {
  @override
  List<String> shownNames = const [];

  @override
  int offset = 0;

  @override
  int end = -1;

  @override
  String toString() {
    StringBuffer buffer = StringBuffer();
    buffer.write("show ");
    int count = shownNames.length;
    for (int i = 0; i < count; i++) {
      if (i > 0) {
        buffer.write(", ");
      }
      buffer.write(shownNames[i]);
    }
    return buffer.toString();
  }
}

/// A concrete implementation of a [TopLevelVariableElement].
class TopLevelVariableElementImpl extends PropertyInducingElementImpl
    implements TopLevelVariableElement {
  /// Initialize a newly created synthetic top-level variable element to have
  /// the given [name] and [offset].
  TopLevelVariableElementImpl(String name, int offset) : super(name, offset);

  @override
  TopLevelVariableElement get declaration => this;

  @override
  bool get isExternal {
    return hasModifier(Modifier.EXTERNAL);
  }

  @override
  bool get isStatic => true;

  @override
  ElementKind get kind => ElementKind.TOP_LEVEL_VARIABLE;

  @override
  List<ElementAnnotation> get metadata {
    return super.metadata;
  }

  @override
  T? accept<T>(ElementVisitor<T> visitor) =>
      visitor.visitTopLevelVariableElement(this);
}

/// A concrete implementation of a [TypeParameterElement].
class TypeParameterElementImpl extends ElementImpl
    implements TypeParameterElement {
  /// The default value of the type parameter. It is used to provide the
  /// corresponding missing type argument in type annotations and as the
  /// fall-back type value in type inference.
  DartType? defaultType;

  /// The type representing the bound associated with this parameter, or `null`
  /// if this parameter does not have an explicit bound.
  DartType? _bound;

  /// Initialize a newly created method element to have the given [name] and
  /// [offset].
  TypeParameterElementImpl(String name, int offset) : super(name, offset);

  /// Initialize a newly created synthetic type parameter element to have the
  /// given [name], and with [synthetic] set to true.
  TypeParameterElementImpl.synthetic(String name) : super(name, -1) {
    isSynthetic = true;
  }

  @override
  DartType? get bound =>
      ElementTypeProvider.current.getTypeParameterBound(this);

  set bound(DartType? bound) {
    _bound = bound;
  }

  DartType? get boundInternal {
    return _bound;
  }

  @override
  TypeParameterElement get declaration => this;

  @override
  String get displayName => name;

  bool get isLegacyCovariant => true;

  @override
  ElementKind get kind => ElementKind.TYPE_PARAMETER;

  @override
  String get name {
    return super.name!;
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) {
      return true;
    }
    if (other is TypeParameterElement) {
      if (other.enclosingElement == null || enclosingElement == null) {
        return identical(other, this);
      }
      return other.location == location;
    }
    return false;
  }

  @override
  T? accept<T>(ElementVisitor<T> visitor) =>
      visitor.visitTypeParameterElement(this);

  @override
  void appendTo(ElementDisplayStringBuilder builder) {
    builder.writeTypeParameter(this);
  }

  @override
  TypeParameterType instantiate({
    required NullabilitySuffix nullabilitySuffix,
  }) {
    return TypeParameterTypeImpl(
      element: this,
      nullabilitySuffix: nullabilitySuffix,
    );
  }
}

/// Mixin representing an element which can have type parameters.
mixin TypeParameterizedElementMixin
    implements ElementImpl, TypeParameterizedElement {
  /// The type parameters declared by this element directly. This does not
  /// include type parameters that are declared by any enclosing elements.
  List<TypeParameterElement> _typeParameterElements = const [];

  @override
  bool get isSimplyBounded => true;

  @override
  List<TypeParameterElement> get typeParameters {
    return _typeParameterElements;
  }

  List<TypeParameterElement> get typeParameters_unresolved {
    return _typeParameterElements;
  }
}

/// A concrete implementation of a [VariableElement].
abstract class VariableElementImpl extends ElementImpl
    implements VariableElement {
  /// The type of this variable.
  DartType? _type;

  /// Initialize a newly created variable element to have the given [name] and
  /// [offset].
  VariableElementImpl(String? name, int offset) : super(name, offset);

  /// If this element represents a constant variable, and it has an initializer,
  /// a copy of the initializer for the constant.  Otherwise `null`.
  ///
  /// Note that in correct Dart code, all constant variables must have
  /// initializers.  However, analyzer also needs to handle incorrect Dart code,
  /// in which case there might be some constant variables that lack
  /// initializers.
  Expression? get constantInitializer => null;

  @override
  VariableElement get declaration => this;

  @override
  String get displayName => name;

  @override
  String get name => super.name!;

  @override
  DartType get type => ElementTypeProvider.current.getVariableType(this);

  set type(DartType type) {
    _type = type;
  }

  /// Gets the element's type, without going through the indirection of
  /// [ElementTypeProvider].
  ///
  /// In most cases, the element's `returnType` getter should be used instead.
  DartType get typeInternal => _type!;

  @override
  void appendTo(ElementDisplayStringBuilder builder) {
    builder.writeVariableElement(this);
  }

  @override
  DartObject? computeConstantValue() => null;
}

/// Instances of [List]s that are used as "not yet computed" values, they
/// must be not `null`, and not identical to `const <T>[]`.
class _Sentinel {
  static final List<FieldElement> fieldElement = List.unmodifiable([]);
  static final List<MethodElement> methodElement = List.unmodifiable([]);
  static final List<PropertyAccessorElement> propertyAccessorElement =
      List.unmodifiable([]);
}
