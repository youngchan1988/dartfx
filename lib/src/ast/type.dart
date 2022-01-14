// Copyright (c) 2014, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Modified by the dartfx project authors.
// Copyright (c) 2022, the dartfx project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'element.dart';
import 'nullability_suffix.dart';
import 'type_visitor.dart';

/// Defines the type model. The type model is part of the
/// [element model](../dart_element_element/dart_element_element-library.html)
/// in that most types are defined by Dart code (the types `dynamic` and `void`
/// being the notable exceptions). All types are represented by an instance of a
/// subclass of [DartType].
///
/// Other than `dynamic` and `void`, all of the types define either the
/// interface defined by a class (an instance of [InterfaceType]) or the type of
/// a function (an instance of [FunctionType]).
///
/// We make a distinction between the declaration of a class (a [ClassElement])
/// and the type defined by that class (an [InterfaceType]). The biggest reason
/// for the distinction is to allow us to more cleanly represent the distinction
/// between type parameters and type arguments. For example, if we define a
/// class as `class Pair<K, V> {}`, the declarations of `K` and `V` represent
/// type parameters. But if we declare a variable as `Pair<String, int> pair;`
/// the references to `String` and `int` are type arguments.

/// The type associated with elements in the element model.
///
/// Clients may not extend, implement or mix-in this class.
abstract class DartType {
  /// If this type is an instantiation of a type alias, information about
  /// the alias element, and the type arguments.
  /// Otherwise return `null`.
  InstantiatedTypeAliasElement? get alias;

  /// Return the element representing the declaration of this type, or `null` if
  /// the type has not, or cannot, be associated with an element. The former
  /// case will occur if the element model is not yet complete; the latter case
  /// will occur if this object represents an undefined type.
  Element? get element;

  /// Return `true` if this type represents the bottom type.
  bool get isBottom;

  /// Return `true` if this type represents the type 'Future' defined in the
  /// dart:async library.
  bool get isDartAsyncFuture;

  /// Return `true` if this type represents the type 'FutureOr<T>' defined in
  /// the dart:async library.
  bool get isDartAsyncFutureOr;

  /// Return `true` if this type represents the type 'Stream' defined in the
  /// dart:async library.
  bool get isDartAsyncStream;

  /// Return `true` if this type represents the type 'bool' defined in the
  /// dart:core library.
  bool get isDartCoreBool;

  /// Return `true` if this type represents the type 'double' defined in the
  /// dart:core library.
  bool get isDartCoreDouble;

  /// Return `true` if this type represents the type 'Function' defined in the
  /// dart:core library.
  bool get isDartCoreFunction;

  /// Return `true` if this type represents the type 'int' defined in the
  /// dart:core library.
  bool get isDartCoreInt;

  /// Returns `true` if this type represents the type 'Iterable' defined in the
  /// dart:core library.
  bool get isDartCoreIterable;

  /// Returns `true` if this type represents the type 'List' defined in the
  /// dart:core library.
  bool get isDartCoreList;

  /// Returns `true` if this type represents the type 'Map' defined in the
  /// dart:core library.
  bool get isDartCoreMap;

  /// Return `true` if this type represents the type 'Null' defined in the
  /// dart:core library.
  bool get isDartCoreNull;

  /// Return `true` if this type represents the type 'num' defined in the
  /// dart:core library.
  bool get isDartCoreNum;

  /// Return `true` if this type represents the type `Object` defined in the
  /// dart:core library.
  bool get isDartCoreObject;

  /// Returns `true` if this type represents the type 'Set' defined in the
  /// dart:core library.
  bool get isDartCoreSet;

  /// Return `true` if this type represents the type 'String' defined in the
  /// dart:core library.
  bool get isDartCoreString;

  /// Returns `true` if this type represents the type 'Symbol' defined in the
  /// dart:core library.
  bool get isDartCoreSymbol;

  /// Return `true` if this type represents the type 'void'.
  bool get isVoid;

  /// Return the name of this type, or `null` if the type does not have a name,
  /// such as when the type represents the type of an unnamed function.
  @Deprecated('Check element, or use getDisplayString()')
  String? get name;

  /// Return the nullability suffix of this type.
  NullabilitySuffix get nullabilitySuffix;

  /// Use the given [visitor] to visit this type.
  R accept<R>(TypeVisitor<R> visitor);

  /// Use the given [visitor] to visit this type.
  R acceptWithArgument<R, A>(
    TypeVisitorWithArgument<R, A> visitor,
    A argument,
  );

  /// Return the presentation of this type as it should appear when presented
  /// to users in contexts such as error messages.
  ///
  /// If [withNullability] is `true`, then [NullabilitySuffix.question] and
  /// [NullabilitySuffix.star] will be represented as `?` and `*`.
  /// [NullabilitySuffix.none] does not have any explicit presentation.
  ///
  /// If [withNullability] is `false`, nullability suffixes will not be
  /// included into the presentation.
  ///
  /// Clients should not depend on the content of the returned value as it will
  /// be changed if doing so would improve the UX.
  String getDisplayString({required bool withNullability});

  /// If this type is a [TypeParameterType], returns its bound if it has one, or
  /// [objectType] otherwise.
  ///
  /// For any other type, returns `this`. Applies recursively -- if the bound is
  /// itself a type parameter, that is resolved too.
  DartType resolveToBound(DartType objectType);
}

/// The type `dynamic` is a type which is a supertype of all other types, just
/// like `Object`, with the difference that the static analysis assumes that
/// every member access has a corresponding member with a signature that
/// admits the given access.
abstract class DynamicType implements DartType {}

/// The type of a function, method, constructor, getter, or setter. Function
/// types come in three variations:
///
/// * The types of functions that only have required parameters. These have the
///   general form <i>(T<sub>1</sub>, &hellip;, T<sub>n</sub>) &rarr; T</i>.
/// * The types of functions with optional positional parameters. These have the
///   general form <i>(T<sub>1</sub>, &hellip;, T<sub>n</sub>, [T<sub>n+1</sub>
///   &hellip;, T<sub>n+k</sub>]) &rarr; T</i>.
/// * The types of functions with named parameters. These have the general form
///   <i>(T<sub>1</sub>, &hellip;, T<sub>n</sub>, {T<sub>x1</sub> x1, &hellip;,
///   T<sub>xk</sub> xk}) &rarr; T</i>.
///
/// Clients may not extend, implement or mix-in this class.
abstract class FunctionType implements DartType {
  /// Return a map from the names of named parameters to the types of the named
  /// parameters of this type of function. The entries in the map will be
  /// iterated in the same order as the order in which the named parameters were
  /// defined. If there were no named parameters declared then the map will be
  /// empty.
  Map<String, DartType> get namedParameterTypes;

  /// The names of the required positional parameters of this type of function,
  /// in the order that the parameters appear.
  List<String> get normalParameterNames;

  /// Return a list containing the types of the normal parameters of this type
  /// of function. The parameter types are in the same order as they appear in
  /// the declaration of the function.
  List<DartType> get normalParameterTypes;

  /// The names of the optional positional parameters of this type of function,
  /// in the order that the parameters appear.
  List<String> get optionalParameterNames;

  /// Return a map from the names of optional (positional) parameters to the
  /// types of the optional parameters of this type of function. The entries in
  /// the map will be iterated in the same order as the order in which the
  /// optional parameters were defined. If there were no optional parameters
  /// declared then the map will be empty.
  List<DartType> get optionalParameterTypes;

  /// Return a list containing the parameters elements of this type of function.
  /// The parameter types are in the same order as they appear in the
  /// declaration of the function.
  List<ParameterElement> get parameters;

  /// Return the type of object returned by this type of function.
  DartType get returnType;

  /// The formal type parameters of this generic function.
  /// For example `<T> T -> T`.
  ///
  /// TODO(scheglov) Remove the mention for "typeParameters".
  /// These are distinct from the `typeParameters` list, which contains type
  /// parameters from surrounding contexts, and thus are free type variables
  /// from the perspective of this function type.
  List<TypeParameterElement> get typeFormals;

  /// Produces a new function type by substituting type parameters of this
  /// function type with the given [argumentTypes]. The resulting function
  /// type will have no type parameters.
  FunctionType instantiate(List<DartType> argumentTypes);
}

/// Information about an instantiated [TypeAliasElement] and the type
/// arguments with which it is instantiated.
abstract class InstantiatedTypeAliasElement {
  /// The alias element that is instantiated to produce a [DartType].
  TypeAliasElement get element;

  /// The type arguments with which the [element] was instantiated.
  /// This list will be empty if the [element] is not generic.
  List<DartType> get typeArguments;
}

/// The type `Never` represents the uninhabited bottom type.
abstract class NeverType implements DartType {}

/// A type that can track substituted type parameters, either for itself after
/// instantiation, or from a surrounding context.
///
/// For example, given a class `Foo<T>`, after instantiation with S for T, it
/// will track the substitution `{S/T}`.
///
/// This substitution will be propagated to its members. For example, say our
/// `Foo<T>` class has a field `T bar;`. When we look up this field, we will get
/// back a [FieldElement] that tracks the substituted type as `{S/T}T`, so when
/// we ask for the field type we will get `S`.
///
/// Clients may not extend, implement or mix-in this class.
abstract class ParameterizedType implements DartType {
  /// Return the type arguments used to instantiate this type.
  ///
  /// An [InterfaceType] always has type arguments.
  ///
  /// A [FunctionType] has type arguments only if it is a result of a typedef
  /// instantiation, otherwise the result is `null`.
  List<DartType> get typeArguments;
}

/// The type introduced by a type parameter.
///
/// Clients may not extend, implement or mix-in this class.
abstract class TypeParameterType implements DartType {
  /// Return the type representing the bound associated with this parameter,
  /// or `dynamic` if there was no explicit bound.
  DartType get bound;

  /// An object that can be used to identify this type parameter with `==`.
  ///
  /// Depending on the use, [bound] may also need to be taken into account.
  /// A given type parameter, it may have different bounds in different scopes.
  /// Always consult the bound if that could be relevant.
  ElementLocation get definition;

  @override
  TypeParameterElement get element;
}

/// The special type `void` is used to indicate that the value of an
/// expression is meaningless, and intended to be discarded.
abstract class VoidType implements DartType {}

/// The kind of a parameter. A parameter can be either positional or named, and
/// can be either required or optional.
class ParameterKind implements Comparable<ParameterKind> {
  /// A positional required parameter.
  static const ParameterKind REQUIRED = ParameterKind(
    name: 'REQUIRED',
    ordinal: 0,
    isPositional: true,
    isRequiredPositional: true,
    isOptionalPositional: false,
    isNamed: false,
    isRequiredNamed: false,
    isOptionalNamed: false,
    isRequired: true,
    isOptional: false,
  );

  /// A positional optional parameter.
  static const ParameterKind POSITIONAL = ParameterKind(
    name: 'POSITIONAL',
    ordinal: 1,
    isPositional: true,
    isRequiredPositional: false,
    isOptionalPositional: true,
    isNamed: false,
    isRequiredNamed: false,
    isOptionalNamed: false,
    isRequired: false,
    isOptional: true,
  );

  /// A named required parameter.
  static const ParameterKind NAMED_REQUIRED = ParameterKind(
    name: 'NAMED_REQUIRED',
    ordinal: 2,
    isPositional: false,
    isRequiredPositional: false,
    isOptionalPositional: false,
    isNamed: true,
    isRequiredNamed: true,
    isOptionalNamed: false,
    isRequired: true,
    isOptional: false,
  );

  /// A named optional parameter.
  static const ParameterKind NAMED = ParameterKind(
    name: 'NAMED',
    ordinal: 3,
    isPositional: false,
    isRequiredPositional: false,
    isOptionalPositional: false,
    isNamed: true,
    isRequiredNamed: false,
    isOptionalNamed: true,
    isRequired: false,
    isOptional: true,
  );

  static const List<ParameterKind> values = [
    REQUIRED,
    POSITIONAL,
    NAMED_REQUIRED,
    NAMED
  ];

  /// The name of this parameter.
  final String name;

  /// The ordinal value of the parameter.
  final int ordinal;

  /// Return `true` if is a positional parameter.
  ///
  /// Positional parameters can either be required or optional.
  final bool isPositional;

  /// Return `true` if both a required and positional parameter.
  final bool isRequiredPositional;

  /// Return `true` if both an optional and positional parameter.
  final bool isOptionalPositional;

  /// Return `true` if a named parameter.
  ///
  /// Named parameters can either be required or optional.
  final bool isNamed;

  /// Return `true` if both a required and named parameter.
  ///
  /// Note: this will return `false` for a named parameter that is annotated
  /// with the `@required` annotation.
  final bool isRequiredNamed;

  /// Return `true` if both an optional and named parameter.
  final bool isOptionalNamed;

  /// Return `true` if a required parameter.
  ///
  /// Required parameters can either be positional or named.
  ///
  /// Note: this will return `false` for a named parameter that is annotated
  /// with the `@required` annotation.
  final bool isRequired;

  /// Return `true` if an optional parameter.
  ///
  /// Optional parameters can either be positional or named.
  final bool isOptional;

  /// Initialize a newly created kind with the given state.
  const ParameterKind({
    required this.name,
    required this.ordinal,
    required this.isPositional,
    required this.isRequiredPositional,
    required this.isOptionalPositional,
    required this.isNamed,
    required this.isRequiredNamed,
    required this.isOptionalNamed,
    required this.isRequired,
    required this.isOptional,
  });

  @override
  int get hashCode => ordinal;

  @override
  int compareTo(ParameterKind other) => ordinal - other.ordinal;

  @override
  String toString() => name;
}
