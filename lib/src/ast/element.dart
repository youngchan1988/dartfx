// Copyright (c) 2014, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'line_info.dart';
import 'nullability_suffix.dart';
import 'scope.dart';
import 'type.dart';
import 'value.dart';

/// Defines the element model. The element model describes the semantic (as
/// opposed to syntactic) structure of Dart code. The syntactic structure of the
/// code is modeled by the [AST
/// structure](../analyzer.dart.ast.ast/analyzer.dart.ast.ast-library.html).
///
/// The element model consists of two closely related kinds of objects: elements
/// (instances of a subclass of [Element]) and types. This library defines the
/// elements, the types are defined in
/// [type.dart](../dart_element_type/dart_element_type-library.html).
///
/// Generally speaking, an element represents something that is declared in the
/// code, such as a class, method, or variable. Elements are organized in a tree
/// structure in which the children of an element are the elements that are
/// logically (and often syntactically) part of the declaration of the parent.
/// For example, the elements representing the methods and fields in a class are
/// children of the element representing the class.
///
/// Every complete element structure is rooted by an instance of the class
/// [LibraryElement]. A library element represents a single Dart library. Every
/// library is defined by one or more compilation units (the library and all of
/// its parts). The compilation units are represented by the class
/// [CompilationUnitElement] and are children of the library that is defined by
/// them. Each compilation unit can contain zero or more top-level declarations,
/// such as classes, functions, and variables. Each of these is in turn
/// represented as an element that is a child of the compilation unit. Classes
/// contain methods and fields, methods can contain local variables, etc.
///
/// The element model does not contain everything in the code, only those things
/// that are declared by the code. For example, it does not include any
/// representation of the statements in a method body, but if one of those
/// statements declares a local variable then the local variable will be
/// represented by an element.

/// An element that is contained within a [ClassElement].
///
/// When the 'extension-methods' experiment is enabled, these elements can also
/// be contained within an extension element.
///
/// Clients may not extend, implement or mix-in this class.
abstract class ClassMemberElement implements Element {
  // TODO(brianwilkerson) Either remove this class or rename it to something
  //  more correct.

  @override
  Element get enclosingElement;

  /// Return `true` if this element is a static element. A static element is an
  /// element that is not associated with a particular instance, but rather with
  /// an entire library or class.
  bool get isStatic;
}

/// An element representing a compilation unit.
///
/// Clients may not extend, implement or mix-in this class.
abstract class CompilationUnitElement implements Element {
  /// Return a list containing all of the top-level accessors (getters and
  /// setters) contained in this compilation unit.
  List<PropertyAccessorElement> get accessors;

  /// Return a list containing all of the top-level functions contained in this
  /// compilation unit.
  List<FunctionElement> get functions;

  /// Return the [LineInfo] for the [source], or `null` if not computed yet.
  LineInfo? get lineInfo;

  /// Return a list containing all of the top-level variables contained in this
  /// compilation unit.
  List<TopLevelVariableElement> get topLevelVariables;

  /// Return a list containing all of the type aliases contained in this
  /// compilation unit.
  List<TypeAliasElement> get typeAliases;
}

/// The base class for all of the elements in the element model. Generally
/// speaking, the element model is a semantic model of the program that
/// represents things that are declared with a name and hence can be referenced
/// elsewhere in the code.
///
/// There are two exceptions to the general case. First, there are elements in
/// the element model that are created for the convenience of various kinds of
/// analysis but that do not have any corresponding declaration within the
/// source code. Such elements are marked as being <i>synthetic</i>. Examples of
/// synthetic elements include
/// * default constructors in classes that do not define any explicit
///   constructors,
/// * getters and setters that are induced by explicit field declarations,
/// * fields that are induced by explicit declarations of getters and setters,
///   and
/// * functions representing the initialization expression for a variable.
///
/// Second, there are elements in the element model that do not have a name.
/// These correspond to unnamed functions and exist in order to more accurately
/// represent the semantic structure of the program.
///
/// Clients may not extend, implement or mix-in this class.
abstract class Element {
  /// A comparator that can be used to sort elements by their name offset.
  /// Elements with a smaller offset will be sorted to be before elements with a
  /// larger name offset.
  static final Comparator<Element> SORT_BY_OFFSET =
      (Element firstElement, Element secondElement) =>
          firstElement.nameOffset - secondElement.nameOffset;

  /// Return the declaration of this element. If the element is a view on an
  /// element, e.g. a method from an interface type, with substituted type
  /// parameters, return the corresponding element from the class, without any
  /// substitutions. If this element is already a declaration (or a synthetic
  /// element, e.g. a synthetic property accessor), return itself.
  Element get declaration;

  /// Return the display name of this element, possibly the empty string if
  /// this element does not have a name.
  ///
  /// In most cases the name and the display name are the same. Differences
  /// though are cases such as setters where the name of some setter `set f(x)`
  /// is `f=`, instead of `f`.
  String get displayName;

  /// Return the content of the documentation comment (including delimiters) for
  /// this element, or `null` if this element does not or cannot have
  /// documentation.
  String? get documentationComment;

  /// Return the element that either physically or logically encloses this
  /// element. This will be `null` if this element is a library because
  /// libraries are the top-level elements in the model.
  Element? get enclosingElement;

  /// The unique integer identifier of this element.
  int get id;

  /// Return `true` if this element is private. Private elements are visible
  /// only within the library in which they are declared.
  bool get isPrivate;

  /// Return `true` if this element is public. Public elements are visible
  /// within any library that imports the library in which they are declared.
  bool get isPublic;

  /// Return `true` if this element is synthetic. A synthetic element is an
  /// element that is not represented in the source code explicitly, but is
  /// implied by the source code, such as the default constructor for a class
  /// that does not explicitly define any constructors.
  bool get isSynthetic;

  /// Return the kind of element that this is.
  ElementKind get kind;

  /// Return an object representing the location of this element in the element
  /// model. The object can be used to locate this element at a later time.
  ElementLocation? get location;

  /// Return a list containing all of the metadata associated with this element.
  /// The array will be empty if the element does not have any metadata or if
  /// the library containing this element has not yet been resolved.
  List<ElementAnnotation> get metadata;

  /// Return the name of this element, or `null` if this element does not have a
  /// name.
  String? get name;

  /// Return the length of the name of this element in the file that contains
  /// the declaration of this element, or `0` if this element does not have a
  /// name.
  int get nameLength;

  /// Return the offset of the name of this element in the file that contains
  /// the declaration of this element, or `-1` if this element is synthetic,
  /// does not have a name, or otherwise does not have an offset.
  int get nameOffset;

  /// Return the non-synthetic element that caused this element to be created.
  ///
  /// If this element is not synthetic, then the element itself is returned.
  ///
  /// If this element is synthetic, then the corresponding non-synthetic
  /// element is returned. For example, for a synthetic getter of a
  /// non-synthetic field the field is returned; for a synthetic constructor
  /// the enclosing class is returned.
  Element get nonSynthetic;

  /// Use the given [visitor] to visit this element. Return the value returned
  /// by the visitor as a result of visiting this element.
  T? accept<T>(ElementVisitor<T> visitor);

  /// Return the presentation of this element as it should appear when
  /// presented to users.
  ///
  /// If [withNullability] is `true`, then [NullabilitySuffix.question] and
  /// [NullabilitySuffix.star] in types will be represented as `?` and `*`.
  /// [NullabilitySuffix.none] does not have any explicit presentation.
  ///
  /// If [withNullability] is `false`, nullability suffixes will not be
  /// included into the presentation.
  ///
  /// If [multiline] is `true`, the string may be wrapped over multiple lines
  /// with newlines to improve formatting. For example function signatures may
  /// be formatted as if they had trailing commas.
  ///
  /// Clients should not depend on the content of the returned value as it will
  /// be changed if doing so would improve the UX.
  String getDisplayString({
    required bool withNullability,
    bool multiline = false,
  });

  /// Return either this element or the most immediate ancestor of this element
  /// for which the [predicate] returns `true`, or `null` if there is no such
  /// element.
  E? thisOrAncestorMatching<E extends Element>(
    bool Function(Element) predicate,
  );

  /// Return either this element or the most immediate ancestor of this element
  /// that has the given type, or `null` if there is no such element.
  E? thisOrAncestorOfType<E extends Element>();

  /// Use the given [visitor] to visit all of the children of this element.
  /// There is no guarantee of the order in which the children will be visited.
  void visitChildren(ElementVisitor visitor);
}

/// A single annotation associated with an element.
///
/// Clients may not extend, implement or mix-in this class.
abstract class ElementAnnotation {
  /// Return the element referenced by this annotation.
  ///
  /// In valid code this element can be a [PropertyAccessorElement] getter
  /// of a constant top-level variable, or a constant static field of a
  /// class; or a constant [ConstructorElement].
  ///
  /// In invalid code this element can be `null`, or a reference to any
  /// other element.
  Element? get element;

  /// Return `true` if this annotation marks the associated function as always
  /// throwing.
  bool get isAlwaysThrows;

  /// Return `true` if this annotation marks the associated element as being
  /// deprecated.
  bool get isDeprecated;

  /// Return `true` if this annotation marks the associated element as not to be
  /// stored.
  bool get isDoNotStore;

  /// Return `true` if this annotation marks the associated member as a factory.
  bool get isFactory;

  /// Return `true` if this annotation marks the associated class and its
  /// subclasses as being immutable.
  bool get isImmutable;

  /// Return `true` if this annotation marks the associated element as being
  /// internal to its package.
  bool get isInternal;

  /// Return `true` if this annotation marks the associated member as running
  /// a single test.
  bool get isIsTest;

  /// Return `true` if this annotation marks the associated member as running
  /// a test group.
  bool get isIsTestGroup;

  /// Return `true` if this annotation marks the associated element with the
  /// `JS` annotation.
  bool get isJS;

  /// Return `true` if this annotation marks the associated constructor as
  /// being literal.
  bool get isLiteral;

  /// Return `true` if this annotation marks the associated member as requiring
  /// overriding methods to call super.
  bool get isMustCallSuper;

  /// Return `true` if this annotation marks the associated member as being
  /// non-virtual.
  bool get isNonVirtual;

  /// Return `true` if this annotation marks the associated type as
  /// having "optional" type arguments.
  bool get isOptionalTypeArgs;

  /// Return `true` if this annotation marks the associated method as being
  /// expected to override an inherited method.
  bool get isOverride;

  /// Return `true` if this annotation marks the associated member as being
  /// protected.
  bool get isProtected;

  /// Return `true` if this annotation marks the associated class as
  /// implementing a proxy object.
  bool get isProxy;

  /// Return `true` if this annotation marks the associated member as being
  /// required.
  bool get isRequired;

  /// Return `true` if this annotation marks the associated class as being
  /// sealed.
  bool get isSealed;

  /// Return `true` if this annotation marks the associated class as being
  /// intended to be used as an annotation.
  bool get isTarget;

  /// Return `true` if this annotation marks the associated returned element as
  /// requiring use.
  bool get isUseResult;

  /// Return `true` if this annotation marks the associated member as being
  /// visible for overriding only.
  bool get isVisibleForOverriding;

  /// Return `true` if this annotation marks the associated member as being
  /// visible for template files.
  bool get isVisibleForTemplate;

  /// Return `true` if this annotation marks the associated member as being
  /// visible for testing.
  bool get isVisibleForTesting;

  /// Return a textual description of this annotation in a form approximating
  /// valid source. The returned string will not be valid source primarily in
  /// the case where the annotation itself is not well-formed.
  String toSource();
}

/// The kind of elements in the element model.
///
/// Clients may not extend, implement or mix-in this class.
class ElementKind implements Comparable<ElementKind> {
  static const ElementKind CLASS = ElementKind('CLASS', 0, "class");

  static const ElementKind COMPILATION_UNIT =
      ElementKind('COMPILATION_UNIT', 1, "compilation unit");

  static const ElementKind CONSTRUCTOR =
      ElementKind('CONSTRUCTOR', 2, "constructor");

  static const ElementKind DYNAMIC = ElementKind('DYNAMIC', 3, "<dynamic>");

  static const ElementKind ENUM = ElementKind('ENUM', 4, "enum");

  static const ElementKind ERROR = ElementKind('ERROR', 5, "<error>");

  static const ElementKind EXPORT =
      ElementKind('EXPORT', 6, "export directive");

  static const ElementKind EXTENSION = ElementKind('EXTENSION', 7, "extension");

  static const ElementKind FIELD = ElementKind('FIELD', 8, "field");

  static const ElementKind FUNCTION = ElementKind('FUNCTION', 9, "function");

  static const ElementKind GENERIC_FUNCTION_TYPE =
      ElementKind('GENERIC_FUNCTION_TYPE', 10, 'generic function type');

  static const ElementKind GETTER = ElementKind('GETTER', 11, "getter");

  static const ElementKind IMPORT =
      ElementKind('IMPORT', 12, "import directive");

  static const ElementKind LABEL = ElementKind('LABEL', 13, "label");

  static const ElementKind LIBRARY = ElementKind('LIBRARY', 14, "library");

  static const ElementKind LOCAL_VARIABLE =
      ElementKind('LOCAL_VARIABLE', 15, "local variable");

  static const ElementKind METHOD = ElementKind('METHOD', 16, "method");

  static const ElementKind NAME = ElementKind('NAME', 17, "<name>");

  static const ElementKind NEVER = ElementKind('NEVER', 18, "<never>");

  static const ElementKind PARAMETER =
      ElementKind('PARAMETER', 19, "parameter");

  static const ElementKind PREFIX = ElementKind('PREFIX', 20, "import prefix");

  static const ElementKind SETTER = ElementKind('SETTER', 21, "setter");

  static const ElementKind TOP_LEVEL_VARIABLE =
      ElementKind('TOP_LEVEL_VARIABLE', 22, "top level variable");

  static const ElementKind FUNCTION_TYPE_ALIAS =
      ElementKind('FUNCTION_TYPE_ALIAS', 23, "function type alias");

  static const ElementKind TYPE_PARAMETER =
      ElementKind('TYPE_PARAMETER', 24, "type parameter");

  static const ElementKind TYPE_ALIAS =
      ElementKind('TYPE_ALIAS', 25, "type alias");

  static const ElementKind UNIVERSE = ElementKind('UNIVERSE', 26, "<universe>");

  static const List<ElementKind> values = [
    CLASS,
    COMPILATION_UNIT,
    CONSTRUCTOR,
    DYNAMIC,
    ENUM,
    ERROR,
    EXPORT,
    FIELD,
    FUNCTION,
    GENERIC_FUNCTION_TYPE,
    GETTER,
    IMPORT,
    LABEL,
    LIBRARY,
    LOCAL_VARIABLE,
    METHOD,
    NAME,
    NEVER,
    PARAMETER,
    PREFIX,
    SETTER,
    TOP_LEVEL_VARIABLE,
    FUNCTION_TYPE_ALIAS,
    TYPE_PARAMETER,
    UNIVERSE
  ];

  /// The name of this element kind.
  final String name;

  /// The ordinal value of the element kind.
  final int ordinal;

  /// The name displayed in the UI for this kind of element.
  final String displayName;

  /// Initialize a newly created element kind to have the given [displayName].
  const ElementKind(this.name, this.ordinal, this.displayName);

  @override
  int get hashCode => ordinal;

  @override
  int compareTo(ElementKind other) => ordinal - other.ordinal;

  @override
  String toString() => name;

  /// Return the kind of the given [element], or [ERROR] if the element is
  /// `null`. This is a utility method that can reduce the need for null checks
  /// in other places.
  static ElementKind of(Element? element) {
    if (element == null) {
      return ERROR;
    }
    return element.kind;
  }
}

/// The location of an element within the element model.
///
/// Clients may not extend, implement or mix-in this class.
abstract class ElementLocation {
  /// Return the path to the element whose location is represented by this
  /// object. Clients must not modify the returned array.
  List<String> get components;

  /// Return an encoded representation of this location that can be used to
  /// create a location that is equal to this location.
  String get encoding;
}

/// An object that can be used to visit an element structure.
///
/// Clients may not extend, implement or mix-in this class. There are classes
/// that implement this interface that provide useful default behaviors in
/// `package:analyzer/dart/element/visitor.dart`. A couple of the most useful
/// include
/// * SimpleElementVisitor which implements every visit method by doing nothing,
/// * RecursiveElementVisitor which will cause every node in a structure to be
///   visited, and
/// * ThrowingElementVisitor which implements every visit method by throwing an
///   exception.
abstract class ElementVisitor<R> {
  R? visitCompilationUnitElement(CompilationUnitElement element);

  R? visitFieldElement(FieldElement element);

  R? visitFieldFormalParameterElement(FieldFormalParameterElement element);

  R? visitFunctionElement(FunctionElement element);

  R? visitGenericFunctionTypeElement(GenericFunctionTypeElement element);

  R? visitLabelElement(LabelElement element);

  R? visitLocalVariableElement(LocalVariableElement element);

  R? visitMethodElement(MethodElement element);

  R? visitMultiplyDefinedElement(MultiplyDefinedElement element);

  R? visitParameterElement(ParameterElement element);

  R? visitPrefixElement(PrefixElement element);

  R? visitPropertyAccessorElement(PropertyAccessorElement element);

  R? visitSuperFormalParameterElement(SuperFormalParameterElement element);

  R? visitTopLevelVariableElement(TopLevelVariableElement element);

  R? visitTypeAliasElement(TypeAliasElement element);

  R? visitTypeParameterElement(TypeParameterElement element);
}

/// An element representing an executable object, including functions, methods,
/// constructors, getters, and setters.
///
/// Clients may not extend, implement or mix-in this class.
abstract class ExecutableElement implements FunctionTypedElement {
  ExecutableElement get declaration;

  @override
  Element get enclosingElement;

  /// Return `true` if this executable element did not have an explicit return
  /// type specified for it in the original source.
  bool get hasImplicitReturnType;

  /// Return `true` if this executable element is an operator. The test may be
  /// based on the name of the executable element, in which case the result will
  /// be correct when the name is legal.
  bool get isOperator;

  /// Return `true` if this element is a static element. A static element is an
  /// element that is not associated with a particular instance, but rather with
  /// an entire library or class.
  bool get isStatic;
}

/// A field defined within a class.
///
/// When the 'extension-methods' experiment is enabled, these elements can also
/// be contained within an extension element.
///
/// Clients may not extend, implement or mix-in this class.
abstract class FieldElement implements PropertyInducingElement {
  @override
  FieldElement get declaration;

  /// Return `true` if this field is abstract. Executable fields are abstract if
  /// they are declared with the `abstract` keyword.
  bool get isAbstract;

  /// Return `true` if this field was explicitly marked as being covariant.
  bool get isCovariant;

  /// Return `true` if this element is an enum constant.
  bool get isEnumConstant;

  /// Return `true` if this field was explicitly marked as being external.
  bool get isExternal;

  /// Return `true` if this element is a static element. A static element is an
  /// element that is not associated with a particular instance, but rather with
  /// an entire library or class.
  @override
  bool get isStatic;
}

/// A field formal parameter defined within a constructor element.
///
/// Clients may not extend, implement or mix-in this class.
abstract class FieldFormalParameterElement implements ParameterElement {
  /// Return the field element associated with this field formal parameter, or
  /// `null` if the parameter references a field that doesn't exist.
  FieldElement? get field;
}

/// A (non-method) function. This can be either a top-level function, a local
/// function, a closure, or the initialization expression for a field or
/// variable.
///
/// Clients may not extend, implement or mix-in this class.
abstract class FunctionElement implements ExecutableElement, LocalElement {
  /// The name of the method that can be implemented by a class to allow its
  /// instances to be invoked as if they were a function.
  static final String CALL_METHOD_NAME = "call";

  /// The name of the synthetic function defined for libraries that are
  /// deferred.
  static final String LOAD_LIBRARY_NAME = "loadLibrary";

  /// The name of the function used as an entry point.
  static const String MAIN_FUNCTION_NAME = "main";

  /// The name of the method that will be invoked if an attempt is made to
  /// invoke an undefined method on an object.
  static final String NO_SUCH_METHOD_METHOD_NAME = "noSuchMethod";

  /// Return `true` if the function is an entry point, i.e. a top-level function
  /// and has the name `main`.
  bool get isEntryPoint;
}

/// An element that has a [FunctionType] as its [type].
///
/// This also provides convenient access to the parameters and return type.
///
/// Clients may not extend, implement or mix-in this class.
abstract class FunctionTypedElement
    implements TypeParameterizedElement, Element {
  /// Return a list containing all of the parameters defined by this executable
  /// element.
  List<ParameterElement> get parameters;

  /// Return the return type defined by this element.
  DartType get returnType;

  /// Return the type defined by this element.
  FunctionType get type;
}

/// The pseudo-declaration that defines a generic function type.
///
/// Clients may not extend, implement, or mix-in this class.
abstract class GenericFunctionTypeElement implements FunctionTypedElement {}

/// A combinator that causes some of the names in a namespace to be hidden when
/// being imported.
///
/// Clients may not extend, implement or mix-in this class.
abstract class HideElementCombinator implements NamespaceCombinator {
  /// Return a list containing the names that are not to be made visible in the
  /// importing library even if they are defined in the imported library.
  List<String> get hiddenNames;
}

/// A label associated with a statement.
///
/// Clients may not extend, implement or mix-in this class.
abstract class LabelElement implements Element {
  @override
  ExecutableElement get enclosingElement;

  @override
  String get name;
}

/// An element that can be (but is not required to be) defined within a method
/// or function (an [ExecutableElement]).
///
/// Clients may not extend, implement or mix-in this class.
abstract class LocalElement implements Element {}

/// A local variable.
///
/// Clients may not extend, implement or mix-in this class.
abstract class LocalVariableElement implements PromotableElement {
  /// Return `true` if this variable has an initializer at declaration.
  bool get hasInitializer;

  @override
  String get name;
}

/// An element that represents a method defined within a class.
///
/// When the 'extension-methods' experiment is enabled, these elements can also
/// be contained within an extension element.
///
/// Clients may not extend, implement or mix-in this class.
abstract class MethodElement implements ClassMemberElement, ExecutableElement {
  @override
  MethodElement get declaration;
}

/// A pseudo-element that represents multiple elements defined within a single
/// scope that have the same name. This situation is not allowed by the
/// language, so objects implementing this interface always represent an error.
/// As a result, most of the normal operations on elements do not make sense
/// and will return useless results.
///
/// Clients may not extend, implement or mix-in this class.
abstract class MultiplyDefinedElement implements Element {
  /// Return a list containing all of the elements that were defined within the
  /// scope to have the same name.
  List<Element> get conflictingElements;
}

/// An [ExecutableElement], with the additional information of a list of
/// [ExecutableElement]s from which this element was composed.
///
/// Clients may not extend, implement or mix-in this class.
abstract class MultiplyInheritedExecutableElement implements ExecutableElement {
  /// Return a list containing all of the executable elements defined within
  /// this executable element.
  List<ExecutableElement> get inheritedElements;
}

/// An object that controls how namespaces are combined.
///
/// Clients may not extend, implement or mix-in this class.
abstract class NamespaceCombinator {}

/// A parameter defined within an executable element.
///
/// Clients may not extend, implement or mix-in this class.
abstract class ParameterElement implements PromotableElement {
  @override
  ParameterElement get declaration;

  /// Return the Dart code of the default value, or `null` if no default value.
  String? get defaultValueCode;

  /// Return `true` if this parameter has a default value.
  bool get hasDefaultValue;

  /// Return `true` if this parameter is covariant, meaning it is allowed to
  /// have a narrower type in an override.
  bool get isCovariant;

  /// Return `true` if this parameter is an initializing formal parameter.
  bool get isInitializingFormal;

  /// Return `true` if this parameter is a named parameter. Named parameters
  /// that are annotated with the `@required` annotation are considered
  /// optional.  Named parameters that are annotated with the `required` syntax
  /// are considered required.
  bool get isNamed;

  /// Return `true` if this parameter is a required parameter. Required
  /// parameters are always positional, unless the experiment 'non-nullable' is
  /// enabled, in which case named parameters can also be required.
  ///
  /// Note: regardless of the state of the 'non-nullable' experiment, this will
  /// return `false` for a named parameter that is annotated with the
  /// `@required` annotation.
  // TODO(brianwilkerson) Rename this to `isRequired`.
  bool get isNotOptional;

  /// Return `true` if this parameter is an optional parameter. Optional
  /// parameters can either be positional or named.  Named parameters that are
  /// annotated with the `@required` annotation are considered optional.  Named
  /// parameters that are annotated with the `required` syntax are considered
  /// required.
  bool get isOptional;

  /// Return `true` if this parameter is both an optional and named parameter.
  /// Named parameters that are annotated with the `@required` annotation are
  /// considered optional.  Named parameters that are annotated with the
  /// `required` syntax are considered required.
  bool get isOptionalNamed;

  /// Return `true` if this parameter is both an optional and positional
  /// parameter.
  bool get isOptionalPositional;

  /// Return `true` if this parameter is a positional parameter. Positional
  /// parameters can either be required or optional.
  bool get isPositional;

  /// Return `true` if this parameter is both a required and named parameter.
  /// Named parameters that are annotated with the `@required` annotation are
  /// considered optional.  Named parameters that are annotated with the
  /// `required` syntax are considered required.
  bool get isRequiredNamed;

  /// Return `true` if this parameter is both a required and positional
  /// parameter.
  bool get isRequiredPositional;

  @override
  String get name;

  /// Return a list containing all of the parameters defined by this parameter.
  /// A parameter will only define other parameters if it is a function typed
  /// parameter.
  List<ParameterElement> get parameters;

  /// Return a list containing all of the type parameters defined by this
  /// parameter. A parameter will only define other parameters if it is a
  /// function typed parameter.
  List<TypeParameterElement> get typeParameters;

  /// Append the type, name and possibly the default value of this parameter to
  /// the given [buffer].
  void appendToWithoutDelimiters(
    StringBuffer buffer, {
    bool withNullability = false,
  });
}

/// A prefix used to import one or more libraries into another library.
///
/// Clients may not extend, implement or mix-in this class.
abstract class PrefixElement {
  String get name;

  /// Return the name lookup scope for this import prefix. It consists of
  /// elements imported into the enclosing library with this prefix. The
  /// namespace combinators of the import directives are taken into account.
  Scope get scope;
}

/// A variable that might be subject to type promotion.  This might be a local
/// variable or a parameter.
///
/// Clients may not extend, implement or mix-in this class.
abstract class PromotableElement implements LocalElement, VariableElement {
  // Promotable elements are guaranteed to have a name.
  @override
  String get name;
}

/// A getter or a setter. Note that explicitly defined property accessors
/// implicitly define a synthetic field. Symmetrically, synthetic accessors are
/// implicitly created for explicitly defined fields. The following rules apply:
///
/// * Every explicit field is represented by a non-synthetic [FieldElement].
/// * Every explicit field induces a getter and possibly a setter, both of which
///   are represented by synthetic [PropertyAccessorElement]s.
/// * Every explicit getter or setter is represented by a non-synthetic
///   [PropertyAccessorElement].
/// * Every explicit getter or setter (or pair thereof if they have the same
///   name) induces a field that is represented by a synthetic [FieldElement].
///
/// Clients may not extend, implement or mix-in this class.
abstract class PropertyAccessorElement implements ExecutableElement {
  /// Return the accessor representing the getter that corresponds to (has the
  /// same name as) this setter, or `null` if this accessor is not a setter or
  /// if there is no corresponding getter.
  PropertyAccessorElement? get correspondingGetter;

  /// Return the accessor representing the setter that corresponds to (has the
  /// same name as) this getter, or `null` if this accessor is not a getter or
  /// if there is no corresponding setter.
  PropertyAccessorElement? get correspondingSetter;

  @override
  PropertyAccessorElement get declaration;

  @override
  Element get enclosingElement;

  /// Return `true` if this accessor represents a getter.
  bool get isGetter;

  /// Return `true` if this accessor represents a setter.
  bool get isSetter;

  /// Return the field or top-level variable associated with this accessor. If
  /// this accessor was explicitly defined (is not synthetic) then the variable
  /// associated with it will be synthetic.
  PropertyInducingElement get variable;
}

/// A variable that has an associated getter and possibly a setter. Note that
/// explicitly defined variables implicitly define a synthetic getter and that
/// non-`final` explicitly defined variables implicitly define a synthetic
/// setter. Symmetrically, synthetic fields are implicitly created for
/// explicitly defined getters and setters. The following rules apply:
///
/// * Every explicit variable is represented by a non-synthetic
///   [PropertyInducingElement].
/// * Every explicit variable induces a getter and possibly a setter, both of
///   which are represented by synthetic [PropertyAccessorElement]s.
/// * Every explicit getter or setter is represented by a non-synthetic
///   [PropertyAccessorElement].
/// * Every explicit getter or setter (or pair thereof if they have the same
///   name) induces a variable that is represented by a synthetic
///   [PropertyInducingElement].
///
/// Clients may not extend, implement or mix-in this class.
abstract class PropertyInducingElement implements VariableElement {
  @override
  String get displayName;

  /// Return the getter associated with this variable. If this variable was
  /// explicitly defined (is not synthetic) then the getter associated with it
  /// will be synthetic.
  PropertyAccessorElement? get getter;

  /// Return `true` if this variable has an initializer at declaration.
  bool get hasInitializer;

  @override
  String get name;

  /// Return the setter associated with this variable, or `null` if the variable
  /// is effectively `final` and therefore does not have a setter associated
  /// with it. (This can happen either because the variable is explicitly
  /// defined as being `final` or because the variable is induced by an
  /// explicit getter that does not have a corresponding setter.) If this
  /// variable was explicitly defined (is not synthetic) then the setter
  /// associated with it will be synthetic.
  PropertyAccessorElement? get setter;
}

/// A combinator that cause some of the names in a namespace to be visible (and
/// the rest hidden) when being imported.
///
/// Clients may not extend, implement or mix-in this class.
abstract class ShowElementCombinator implements NamespaceCombinator {
  /// Return the offset of the character immediately following the last
  /// character of this node.
  int get end;

  /// Return the offset of the 'show' keyword of this element.
  int get offset;

  /// Return a list containing the names that are to be made visible in the
  /// importing library if they are defined in the imported library.
  List<String> get shownNames;
}

/// A super formal parameter defined within a constructor element.
///
/// Clients may not extend, implement or mix-in this class.
abstract class SuperFormalParameterElement implements ParameterElement {
  /// The associated super-constructor parameter, from the super-constructor
  /// that is referenced by the implicit or explicit super-constructor
  /// invocation.
  ///
  /// Can be `null` for erroneous code - not existing super-constructor,
  /// no corresponding parameter in the super-constructor.
  ParameterElement? get superConstructorParameter;
}

/// A top-level variable.
///
/// Clients may not extend, implement or mix-in this class.
abstract class TopLevelVariableElement implements PropertyInducingElement {
  @override
  TopLevelVariableElement get declaration;

  /// Return `true` if this field was explicitly marked as being external.
  bool get isExternal;
}

/// A type alias (`typedef`).
///
/// Clients may not extend, implement or mix-in this class.
abstract class TypeAliasElement
    implements TypeParameterizedElement, TypeDefiningElement {
  /// If the aliased type has structure, return the corresponding element.
  /// For example it could be [GenericFunctionTypeElement].
  ///
  /// If there is no structure, return `null`.
  Element? get aliasedElement;

  /// Return the aliased type.
  ///
  /// If non-function type aliases feature is enabled for the enclosing library,
  /// this type might be just anything. If the feature is disabled, return
  /// a [FunctionType].
  DartType get aliasedType;

  @override
  CompilationUnitElement get enclosingElement;

  @override
  String get name;

  /// Produces the type resulting from instantiating this typedef with the given
  /// [typeArguments] and [nullabilitySuffix].
  ///
  /// Note that this always instantiates the typedef itself, so for a
  /// [TypeAliasElement] the returned [DartType] might still be a generic
  /// type, with type formals. For example, if the typedef is:
  ///     typedef F<T> = void Function<U>(T, U);
  /// then `F<int>` will produce `void Function<U>(int, U)`.
  DartType instantiate({
    required List<DartType> typeArguments,
    required NullabilitySuffix nullabilitySuffix,
  });
}

/// An element that defines a type.
///
/// Clients may not extend, implement or mix-in this class.
abstract class TypeDefiningElement implements Element {}

/// A type parameter.
///
/// Clients may not extend, implement or mix-in this class.
abstract class TypeParameterElement implements TypeDefiningElement {
  /// Return the type representing the bound associated with this parameter, or
  /// `null` if this parameter does not have an explicit bound. Being able to
  /// distinguish between an implicit and explicit bound is needed by the
  /// instantiate to bounds algorithm.
  DartType? get bound;

  @override
  TypeParameterElement get declaration;

  @override
  String get displayName;

  @override
  String get name;

  /// Create the [TypeParameterType] with the given [nullabilitySuffix] for
  /// this type parameter.
  TypeParameterType instantiate({
    required NullabilitySuffix nullabilitySuffix,
  });
}

/// An element that has type parameters, such as a class or a typedef. This also
/// includes functions and methods if support for generic methods is enabled.
///
/// Clients may not extend, implement or mix-in this class.
abstract class TypeParameterizedElement {
  /// If the element defines a type, indicates whether the type may safely
  /// appear without explicit type parameters as the bounds of a type parameter
  /// declaration.
  ///
  /// If the element does not define a type, returns `true`.
  bool get isSimplyBounded;

  /// Return a list containing all of the type parameters declared by this
  /// element directly. This does not include type parameters that are declared
  /// by any enclosing elements.
  List<TypeParameterElement> get typeParameters;
}

/// A pseudo-elements that represents names that are undefined. This situation
/// is not allowed by the language, so objects implementing this interface
/// always represent an error. As a result, most of the normal operations on
/// elements do not make sense and will return useless results.
///
/// Clients may not extend, implement or mix-in this class.
abstract class UndefinedElement implements Element {}

/// A variable. There are more specific subclasses for more specific kinds of
/// variables.
///
/// Clients may not extend, implement or mix-in this class.
abstract class VariableElement implements Element {
  @override
  VariableElement get declaration;

  @override
  String get name;

  /// Return the declared type of this variable.
  DartType get type;

  /// Return a representation of the value of this variable, forcing the value
  /// to be computed if it had not previously been computed, or `null` if either
  /// this variable was not declared with the 'const' modifier or if the value
  /// of this variable could not be computed because of errors.
  DartObject? computeConstantValue();
}
