// Copyright (c) 2014, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartfx/src/lexer/tokens/token.dart';
import 'line_info.dart';
import 'precedence.dart';
import 'syntactic_entity.dart';
import 'element.dart';
import 'type.dart';
import 'visitor.dart';

/// Defines the AST model. The AST (Abstract Syntax Tree) model describes the
/// syntactic (as opposed to semantic) structure of Dart code. The semantic
/// structure of the code is modeled by the
/// [element model](../dart_element_element/dart_element_element-library.html).
///
/// An AST consists of nodes (instances of a subclass of [AstNode]). The nodes
/// are organized in a tree structure in which the children of a node are the
/// smaller syntactic units from which the node is composed. For example, a
/// binary expression consists of two sub-expressions (the operands) and an
/// operator. The two expressions are represented as nodes. The operator is not
/// represented as a node.
///
/// The AST is constructed by the parser based on the sequence of tokens
/// produced by the scanner. Most nodes provide direct access to the tokens used
/// to build the node. For example, the token for the operator in a binary
/// expression can be accessed from the node representing the binary expression.
///
/// While any node can theoretically be the root of an AST structure, almost all
/// of the AST structures known to the analyzer have a [CompilationUnit] as the
/// root of the structure. A compilation unit represents all of the Dart code in
/// a single file.
///
/// An AST can be either unresolved or resolved. When an AST is unresolved
/// certain properties will not have been computed and the accessors for those
/// properties will return `null`. The documentation for those getters should
/// describe that this is a possibility.
///
/// When an AST is resolved, the identifiers in the AST will be associated with
/// the elements that they refer to and every expression in the AST will have a
/// type associated with it.

/// Two or more string literals that are implicitly concatenated because of
/// being adjacent (separated only by whitespace).
///
/// While the grammar only allows adjacent strings when all of the strings are
/// of the same kind (single line or multi-line), this class doesn't enforce
/// that restriction.
///
///    adjacentStrings ::=
///        [StringLiteral] [StringLiteral]+
///
/// Clients may not extend, implement or mix-in this class.
abstract class AdjacentStrings implements StringLiteral {
  /// Return the strings that are implicitly concatenated.
  NodeList<StringLiteral> get strings;
}

/// An AST node that can be annotated with both a documentation comment and a
/// list of annotations.
///
/// Clients may not extend, implement or mix-in this class.
abstract class AnnotatedNode implements AstNode {
  /// Return the documentation comment associated with this node, or `null` if
  /// this node does not have a documentation comment associated with it.
  Comment? get documentationComment;

  /// Return the first token following the comment and metadata.
  Token get firstTokenAfterCommentAndMetadata;

  /// Return the annotations associated with this node.
  NodeList<Annotation> get metadata;

  /// Return a list containing the comment and annotations associated with this
  /// node, sorted in lexical order.
  List<AstNode> get sortedCommentAndAnnotations;
}

/// An annotation that can be associated with an AST node.
///
///    metadata ::=
///        annotation*
///
///    annotation ::=
///        '@' metadatum
///
///    metadatum ::=
///        [Identifier]
///      | qualifiedName
///      | constructorDesignation argumentPart
///
/// Clients may not extend, implement or mix-in this class.
abstract class Annotation implements AstNode {
  /// Return the arguments to the constructor being invoked, or `null` if this
  /// annotation is not the invocation of a constructor.
  ArgumentList? get arguments;

  /// Return the at sign that introduced the annotation.
  Token get atSign;

  /// Return the name of the constructor being invoked, or `null` if this
  /// annotation is not the invocation of a named constructor.
  SimpleIdentifier? get constructorName;

  /// Return the element associated with this annotation, or `null` if the AST
  /// structure has not been resolved or if this annotation could not be
  /// resolved.
  Element? get element;

  /// Return the element annotation representing this annotation in the element
  /// model; `null` when the AST has not been resolved.
  ElementAnnotation? get elementAnnotation;

  /// Return the name of the class defining the constructor that is being
  /// invoked or the name of the field that is being referenced.
  Identifier get name;

  @override
  AstNode get parent;

  /// Return the period before the constructor name, or `null` if this
  /// annotation is not the invocation of a named constructor.
  Token? get period;

  /// Returns the type arguments to the constructor being invoked, or `null` if
  /// (a) this annotation is not the invocation of a constructor or (b) this
  /// annotation does not specify type arguments explicitly.
  ///
  /// Note that type arguments are only valid if [Feature.generic_metadata] is
  /// enabled.
  TypeArgumentList? get typeArguments;
}

/// A list of arguments in the invocation of an executable element (that is, a
/// function, method, or constructor).
///
///    argumentList ::=
///        '(' arguments? ')'
///
///    arguments ::=
///        [NamedExpression] (',' [NamedExpression])*
///      | [Expression] (',' [Expression])* (',' [NamedExpression])*
///
/// Clients may not extend, implement or mix-in this class.
abstract class ArgumentList implements AstNode {
  /// Return the expressions producing the values of the arguments.
  ///
  /// Although the language requires that positional arguments appear before
  /// named arguments, this class allows them to be intermixed.
  NodeList<Expression> get arguments;

  /// Return the left parenthesis.
  Token get leftParenthesis;

  /// Return the right parenthesis.
  Token get rightParenthesis;
}

/// An assignment expression.
///
///    assignmentExpression ::=
///        [Expression] operator [Expression]
///
/// Clients may not extend, implement or mix-in this class.
abstract class AssignmentExpression
    implements
        NullShortableExpression,
        MethodReferenceExpression,
        CompoundAssignmentExpression {
  /// Return the expression used to compute the left hand side.
  Expression get leftHandSide;

  /// Return the assignment operator being applied.
  Token get operator;

  /// Return the expression used to compute the right hand side.
  Expression get rightHandSide;
}

/// A node in the AST structure for a Dart program.
///
/// Clients may not extend, implement or mix-in this class.
abstract class AstNode implements SyntacticEntity {
  /// A comparator that can be used to sort AST nodes in lexical order.
  ///
  /// In other words, `compare` will return a negative value if the offset of
  /// the first node is less than the offset of the second node, zero (0) if
  /// the nodes have the same offset, and a positive value if the offset of the
  /// first node is greater than the offset of the second node.
  static Comparator<AstNode> LEXICAL_ORDER =
      (AstNode first, AstNode second) => first.offset - second.offset;

  /// Return the first token included in this node's source range.
  Token get beginToken;

  /// Return an iterator that can be used to iterate through all the entities
  /// (either AST nodes or tokens) that make up the contents of this node,
  /// including doc comments but excluding other comments.
  Iterable<SyntacticEntity> get childEntities;

  /// Return the offset of the character immediately following the last
  /// character of this node's source range.
  ///
  /// This is equivalent to `node.getOffset() + node.getLength()`. For a
  /// compilation unit this will be equal to the length of the unit's source.
  /// For synthetic nodes this will be equivalent to the node's offset (because
  /// the length is zero (0) by definition).
  @override
  int get end;

  /// Return the last token included in this node's source range.
  Token get endToken;

  @override
  int get length;

  @override
  int get offset;

  /// Return this node's parent node, or `null` if this node is the root of an
  /// AST structure.
  ///
  /// Note that the relationship between an AST node and its parent node may
  /// change over the lifetime of a node.
  AstNode? get parent;

  /// Return the node at the root of this node's AST structure.
  ///
  /// Note that this method's performance is linear with respect to the depth
  /// of the node in the AST structure (O(depth)).
  AstNode get root;

  /// Use the given [visitor] to visit this node.
  ///
  /// Return the value returned by the visitor as a result of visiting this
  /// node.
  E? accept<E>(AstVisitor<E> visitor);

  /// Return the token before [target] or `null` if it cannot be found.
  Token? findPrevious(Token target);

  /// Return the value of the property with the given [name], or `null` if this
  /// node does not have a property with the given name.
  E? getProperty<E>(String name);

  /// Set the value of the property with the given [name] to the given [value].
  /// If the value is `null`, the property will effectively be removed.
  void setProperty(String name, Object? value);

  /// Return either this node or the most immediate ancestor of this node for
  /// which the [predicate] returns `true`, or `null` if there is no such node.
  E? thisOrAncestorMatching<E extends AstNode>(
    bool Function(AstNode) predicate,
  );

  /// Return either this node or the most immediate ancestor of this node that
  /// has the given type, or `null` if there is no such node.
  E? thisOrAncestorOfType<E extends AstNode>();

  /// Return a textual description of this node in a form approximating valid
  /// source.
  ///
  /// The returned string will not be valid source primarily in the case where
  /// the node itself is not well-formed.
  String toSource();

  /// Use the given [visitor] to visit all of the children of this node.
  ///
  /// The children will be visited in lexical order.
  void visitChildren(AstVisitor visitor);
}

/// A binary (infix) expression.
///
///    binaryExpression ::=
///        [Expression] [Token] [Expression]
///
/// Clients may not extend, implement or mix-in this class.
abstract class BinaryExpression
    implements Expression, MethodReferenceExpression {
  /// Return the expression used to compute the left operand.
  Expression get leftOperand;

  /// Return the binary operator being applied.
  Token get operator;

  /// Return the expression used to compute the right operand.
  Expression get rightOperand;

  /// The function type of the invocation, or `null` if the AST structure has
  /// not been resolved, or if the invocation could not be resolved.
  FunctionType? get staticInvokeType;
}

/// A sequence of statements.
///
///    block ::=
///        '{' statement* '}'
///
/// Clients may not extend, implement or mix-in this class.
abstract class Block implements Statement {
  /// Return the left curly bracket.
  Token get leftBracket;

  /// Return the right curly bracket.
  Token get rightBracket;

  /// Return the statements contained in the block.
  NodeList<Statement> get statements;
}

/// A function body that consists of a block of statements.
///
///    blockFunctionBody ::=
///        ('async' | 'async' '*' | 'sync' '*')? [Block]
///
/// Clients may not extend, implement or mix-in this class.
abstract class BlockFunctionBody implements FunctionBody {
  /// Return the block representing the body of the function.
  Block get block;
}

/// A boolean literal expression.
///
///    booleanLiteral ::=
///        'false' | 'true'
///
/// Clients may not extend, implement or mix-in this class.
abstract class BooleanLiteral implements Literal {
  /// Return the token representing the literal.
  Token get literal;

  /// Return the value of the literal.
  bool get value;
}

/// A break statement.
///
///    breakStatement ::=
///        'break' [SimpleIdentifier]? ';'
///
/// Clients may not extend, implement or mix-in this class.
abstract class BreakStatement implements Statement {
  /// Return the token representing the 'break' keyword.
  Token get breakKeyword;

  /// Return the label associated with the statement, or `null` if there is no
  /// label.
  SimpleIdentifier? get label;

  /// Return the semicolon terminating the statement.
  Token get semicolon;

  /// Return the node from which this break statement is breaking.
  ///
  /// This will be either a [Statement] (in the case of breaking out of a
  /// loop), a [SwitchMember] (in the case of a labeled break statement whose
  /// label matches a label on a switch case in an enclosing switch statement),
  /// or `null` if the AST has not yet been resolved or if the target could not
  /// be resolved. Note that if the source code has errors, the target might be
  /// invalid (e.g. trying to break to a switch case).
  AstNode? get target;
}

/// A sequence of cascaded expressions: expressions that share a common target.
///
/// There are three kinds of expressions that can be used in a cascade
/// expression: [IndexExpression], [MethodInvocation] and [PropertyAccess].
///
///    cascadeExpression ::=
///        [Expression] cascadeSection*
///
///    cascadeSection ::=
///        ('..' | '?..') (cascadeSelector arguments*)
///        (assignableSelector arguments*)*
///        (assignmentOperator expressionWithoutCascade)?
///
///    cascadeSelector ::=
///        '[ ' expression '] '
///      | identifier
///
/// Clients may not extend, implement or mix-in this class.
abstract class CascadeExpression
    implements Expression, NullShortableExpression {
  /// Return the cascade sections sharing the common target.
  NodeList<Expression> get cascadeSections;

  /// Whether this cascade is null aware (as opposed to non-null).
  bool get isNullAware;

  /// Return the target of the cascade sections.
  Expression get target;
}

/// A catch clause within a try statement.
///
///    onPart ::=
///        catchPart [Block]
///      | 'on' type catchPart? [Block]
///
///    catchPart ::=
///        'catch' '(' [SimpleIdentifier] (',' [SimpleIdentifier])? ')'
///
/// Clients may not extend, implement or mix-in this class.
abstract class CatchClause implements AstNode {
  /// Return the body of the catch block.
  Block get body;

  /// Return the token representing the 'catch' keyword, or `null` if there is
  /// no 'catch' keyword.
  Token? get catchKeyword;

  /// Return the comma separating the exception parameter from the stack trace
  /// parameter, or `null` if there is no stack trace parameter.
  Token? get comma;

  /// Return the parameter whose value will be the exception that was thrown, or
  /// `null` if there is no 'catch' keyword.
  SimpleIdentifier? get exceptionParameter;

  /// Return the type of exceptions caught by this catch clause, or `null` if
  /// this catch clause catches every type of exception.
  TypeAnnotation? get exceptionType;

  /// Return the left parenthesis, or `null` if there is no 'catch' keyword.
  Token? get leftParenthesis;

  /// Return the token representing the 'on' keyword, or `null` if there is no
  /// 'on' keyword.
  Token? get onKeyword;

  /// Return the right parenthesis, or `null` if there is no 'catch' keyword.
  Token? get rightParenthesis;

  /// Return the parameter whose value will be the stack trace associated with
  /// the exception, or `null` if there is no stack trace parameter.
  SimpleIdentifier? get stackTraceParameter;
}

/// A node that declares a name within the scope of a class declarations.
///
/// When the 'extension-methods' experiment is enabled, these nodes can also be
/// located inside extension declarations.
///
/// Clients may not extend, implement or mix-in this class.
abstract class ClassMember implements Declaration {}

/// An element in a list, map or set literal.
///
///    collectionElement ::=
///        [Expression]
///      | [IfElement]
///      | [ForElement]
///      | [MapLiteralEntry]
///      | [SpreadElement]
///
/// Clients may not extend, implement or mix-in this class.
abstract class CollectionElement implements AstNode {}

/// A combinator associated with an import or export directive.
///
///    combinator ::=
///        [HideCombinator]
///      | [ShowCombinator]
///
/// Clients may not extend, implement or mix-in this class.
abstract class Combinator implements AstNode {
  /// Return the 'hide' or 'show' keyword specifying what kind of processing is
  /// to be done on the names.
  Token get keyword;
}

/// A comment within the source code.
///
///    comment ::=
///        endOfLineComment
///      | blockComment
///      | documentationComment
///
///    endOfLineComment ::=
///        '//' (CHARACTER - EOL)* EOL
///
///    blockComment ::=
///        '/ *' CHARACTER* '&#42;/'
///
///    documentationComment ::=
///        '/ **' (CHARACTER | [CommentReference])* '&#42;/'
///      | ('///' (CHARACTER - EOL)* EOL)+
///
/// Clients may not extend, implement or mix-in this class.
abstract class Comment implements AstNode {
  /// Return `true` if this is a block comment.
  bool get isBlock;

  /// Return `true` if this is a documentation comment.
  bool get isDocumentation;

  /// Return `true` if this is an end-of-line comment.
  bool get isEndOfLine;

  /// Return the references embedded within the documentation comment.
  NodeList<CommentReference> get references;

  /// Return the tokens representing the comment.
  List<Token> get tokens;
}

/// An interface for an [Expression] which can make up a [CommentReference].
///
///    commentReferableExpression ::=
///        [ConstructorReference]
///      | [FunctionReference]
///      | [PrefixedIdentifier]
///      | [PropertyAccess]
///      | [SimpleIdentifier]
///      | [TypeLiteral]
///
/// This interface should align closely with dartdoc's notion of
/// comment-referable expressions at:
/// https://github.com/dart-lang/dartdoc/blob/master/lib/src/comment_references/parser.dart
abstract class CommentReferableExpression implements Expression {}

/// A reference to a Dart element that is found within a documentation comment.
///
///    commentReference ::=
///        '[' 'new'? [CommentReferableExpression] ']'
///
/// Clients may not extend, implement or mix-in this class.
abstract class CommentReference implements AstNode {
  /// The comment-referable expression being referenced.
  CommentReferableExpression get expression;

  /// Return the identifier being referenced.
  @Deprecated('Use expression instead')
  Identifier get identifier;

  /// Return the token representing the 'new' keyword, or `null` if there was no
  /// 'new' keyword.
  Token? get newKeyword;
}

/// A compilation unit.
///
/// While the grammar restricts the order of the directives and declarations
/// within a compilation unit, this class does not enforce those restrictions.
/// In particular, the children of a compilation unit will be visited in lexical
/// order even if lexical order does not conform to the restrictions of the
/// grammar.
///
///    compilationUnit ::=
///        directives declarations
///
///    directives ::=
///        [ScriptTag]? [LibraryDirective]? namespaceDirective* [PartDirective]*
///      | [PartOfDirective]
///
///    namespaceDirective ::=
///        [ImportDirective]
///      | [ExportDirective]
///
///    declarations ::=
///        [CompilationUnitMember]*
///
/// Clients may not extend, implement or mix-in this class.
abstract class CompilationUnit implements AstNode {
  /// Return the declarations contained in this compilation unit.
  NodeList<CompilationUnitMember> get declarations;

  /// Return the element associated with this compilation unit, or `null` if the
  /// AST structure has not been resolved.
  CompilationUnitElement? get declaredElement;

  /// Return the directives contained in this compilation unit.
  NodeList<Directive> get directives;

  /// Return the line information for this compilation unit.
  LineInfo? get lineInfo;

  /// Return the script tag at the beginning of the compilation unit, or `null`
  /// if there is no script tag in this compilation unit.
  ScriptTag? get scriptTag;

  /// Return a list containing all of the directives and declarations in this
  /// compilation unit, sorted in lexical order.
  List<AstNode> get sortedDirectivesAndDeclarations;
}

/// A node that declares one or more names within the scope of a compilation
/// unit.
///
///    compilationUnitMember ::=
///        [ClassDeclaration]
///      | [MixinDeclaration]
///      | [ExtensionDeclaration]
///      | [EnumDeclaration]
///      | [TypeAlias]
///      | [FunctionDeclaration]
///      | [TopLevelVariableDeclaration]
///
/// Clients may not extend, implement or mix-in this class.
abstract class CompilationUnitMember implements Declaration {}

/// A potentially compound assignment.
///
/// A compound assignment is any node in which a single expression is used to
/// specify both where to access a value to be operated on (the "read") and to
/// specify where to store the result of the operation (the "write"). This
/// happens in an [AssignmentExpression] when the assignment operator is a
/// compound assignment operator, and in a [PrefixExpression] or
/// [PostfixExpression] when the operator is an increment operator.
///
/// Clients may not extend, implement or mix-in this class.
abstract class CompoundAssignmentExpression implements Expression {
  /// The element that is used to read the value.
  ///
  /// If this node is not a compound assignment, this element is `null`.
  ///
  /// In valid code this element can be a [LocalVariableElement], a
  /// [ParameterElement], or a [PropertyAccessorElement] getter.
  ///
  /// In invalid code this element is `null`, for example `int += 2`. For
  /// recovery [writeElement] is filled, and can be used for navigation.
  ///
  /// This element is `null` if the AST structure has not been resolved, or
  /// if the target could not be resolved.
  Element? get readElement;

  /// The type of the value read with the [readElement].
  ///
  /// If this node is not a compound assignment, this type is `null`.
  ///
  /// In invalid code, e.g. `int += 2`, this type is `dynamic`.
  ///
  /// This type is `null` if the AST structure has not been resolved.
  ///
  /// If the target could not be resolved, this type is `dynamic`.
  DartType? get readType;

  /// The element that is used to write the result.
  ///
  /// In valid code this is a [LocalVariableElement], [ParameterElement], or a
  /// [PropertyAccessorElement] setter.
  ///
  /// In invalid code, for recovery, we might use other elements, for example a
  /// [PropertyAccessorElement] getter `myGetter = 0` even though the getter
  /// cannot be used to write a value. We do this to help the user to navigate
  /// to the getter, and maybe add the corresponding setter.
  ///
  /// If this node is a compound assignment, e. g. `x += 2`, both [readElement]
  /// and [writeElement] could be not `null`.
  ///
  /// This element is `null` if the AST structure has not been resolved, or
  /// if the target could not be resolved.
  Element? get writeElement;

  /// The types of assigned values must be subtypes of this type.
  ///
  /// If the target could not be resolved, this type is `dynamic`.
  DartType? get writeType;
}

/// A conditional expression.
///
///    conditionalExpression ::=
///        [Expression] '?' [Expression] ':' [Expression]
///
/// Clients may not extend, implement or mix-in this class.
abstract class ConditionalExpression implements Expression {
  /// Return the token used to separate the then expression from the else
  /// expression.
  Token get colon;

  /// Return the condition used to determine which of the expressions is
  /// executed next.
  Expression get condition;

  /// Return the expression that is executed if the condition evaluates to
  /// `false`.
  Expression get elseExpression;

  /// Return the token used to separate the condition from the then expression.
  Token get question;

  /// Return the expression that is executed if the condition evaluates to
  /// `true`.
  Expression get thenExpression;
}

/// A continue statement.
///
///    continueStatement ::=
///        'continue' [SimpleIdentifier]? ';'
///
/// Clients may not extend, implement or mix-in this class.
abstract class ContinueStatement implements Statement {
  /// Return the token representing the 'continue' keyword.
  Token get continueKeyword;

  /// Return the label associated with the statement, or `null` if there is no
  /// label.
  SimpleIdentifier? get label;

  /// Return the semicolon terminating the statement.
  Token get semicolon;

  /// Return the node to which this continue statement is continuing.
  ///
  /// This will be either a [Statement] (in the case of continuing a loop), a
  /// [SwitchMember] (in the case of continuing from one switch case to
  /// another), or `null` if the AST has not yet been resolved or if the target
  /// could not be resolved. Note that if the source code has errors, the
  /// target might be invalid (e.g. the target may be in an enclosing
  /// function).
  AstNode? get target;
}

/// A node that represents the declaration of one or more names.
///
/// Each declared name is visible within a name scope.
///
/// Clients may not extend, implement or mix-in this class.
abstract class Declaration implements AnnotatedNode {
  /// Return the element associated with this declaration, or `null` if either
  /// this node corresponds to a list of declarations or if the AST structure
  /// has not been resolved.
  Element? get declaredElement;
}

/// The declaration of a single identifier.
///
///    declaredIdentifier ::=
///        [Annotation] finalConstVarOrType [SimpleIdentifier]
///
/// Clients may not extend, implement or mix-in this class.
abstract class DeclaredIdentifier implements Declaration {
  @override
  LocalVariableElement? get declaredElement;

  /// Return the name of the variable being declared.
  SimpleIdentifier get identifier;

  /// Return the token representing either the 'final', 'const' or 'var'
  /// keyword, or `null` if no keyword was used.
  Token? get keyword;

  /// Return the name of the declared type of the parameter, or `null` if the
  /// parameter does not have a declared type.
  TypeAnnotation? get type;
}

/// A formal parameter with a default value.
///
/// There are two kinds of parameters that are both represented by this class:
/// named formal parameters and positional formal parameters.
///
///    defaultFormalParameter ::=
///        [NormalFormalParameter] ('=' [Expression])?
///
///    defaultNamedParameter ::=
///        [NormalFormalParameter] (':' [Expression])?
///
/// Clients may not extend, implement or mix-in this class.
abstract class DefaultFormalParameter implements FormalParameter {
  /// Return the expression computing the default value for the parameter, or
  /// `null` if there is no default value.
  Expression? get defaultValue;

  /// Return the formal parameter with which the default value is associated.
  NormalFormalParameter get parameter;

  /// Return the token separating the parameter from the default value, or
  /// `null` if there is no default value.
  Token? get separator;
}

/// A node that represents a directive.
///
///    directive ::=
///        [ExportDirective]
///      | [ImportDirective]
///      | [LibraryDirective]
///      | [PartDirective]
///      | [PartOfDirective]
///
/// Clients may not extend, implement or mix-in this class.
abstract class Directive implements AnnotatedNode {
  /// Return the element associated with this directive, or `null` if the AST
  /// structure has not been resolved or if this directive could not be
  /// resolved.
  Element? get element;

  /// Return the token representing the keyword that introduces this directive
  /// ('import', 'export', 'library' or 'part').
  Token get keyword;
}

/// A do statement.
///
///    doStatement ::=
///        'do' [Statement] 'while' '(' [Expression] ')' ';'
///
/// Clients may not extend, implement or mix-in this class.
abstract class DoStatement implements Statement {
  /// Return the body of the loop.
  Statement get body;

  /// Return the condition that determines when the loop will terminate.
  Expression get condition;

  /// Return the token representing the 'do' keyword.
  Token get doKeyword;

  /// Return the left parenthesis.
  Token get leftParenthesis;

  /// Return the right parenthesis.
  Token get rightParenthesis;

  /// Return the semicolon terminating the statement.
  Token get semicolon;

  /// Return the token representing the 'while' keyword.
  Token get whileKeyword;
}

/// A dotted name, used in a configuration within an import or export directive.
///
///    dottedName ::=
///        [SimpleIdentifier] ('.' [SimpleIdentifier])*
///
/// Clients may not extend, implement or mix-in this class.
abstract class DottedName implements AstNode {
  /// Return the components of the identifier.
  NodeList<SimpleIdentifier> get components;
}

/// A floating point literal expression.
///
///    doubleLiteral ::=
///        decimalDigit+ ('.' decimalDigit*)? exponent?
///      | '.' decimalDigit+ exponent?
///
///    exponent ::=
///        ('e' | 'E') ('+' | '-')? decimalDigit+
///
/// Clients may not extend, implement or mix-in this class.
abstract class DoubleLiteral implements Literal {
  /// Return the token representing the literal.
  Token get literal;

  /// Return the value of the literal.
  double get value;
}

/// An empty function body, which can only appear in constructors or abstract
/// methods.
///
///    emptyFunctionBody ::=
///        ';'
///
/// Clients may not extend, implement or mix-in this class.
abstract class EmptyFunctionBody implements FunctionBody {
  /// Return the token representing the semicolon that marks the end of the
  /// function body.
  Token get semicolon;
}

/// An empty statement.
///
///    emptyStatement ::=
///        ';'
///
/// Clients may not extend, implement or mix-in this class.
abstract class EmptyStatement implements Statement {
  /// Return the semicolon terminating the statement.
  Token get semicolon;
}

/// A node that represents an expression.
///
///    expression ::=
///        [AssignmentExpression]
///      | [ConditionalExpression] cascadeSection*
///      | [ThrowExpression]
///
/// Clients may not extend, implement or mix-in this class.
abstract class Expression implements CollectionElement {
  /// An expression _e_ is said to _occur in a constant context_,
  /// * if _e_ is an element of a constant list literal, or a key or value of an
  ///   entry of a constant map literal.
  /// * if _e_ is an actual argument of a constant object expression or of a
  ///   metadata annotation.
  /// * if _e_ is the initializing expression of a constant variable
  ///   declaration.
  /// * if _e_ is a switch case expression.
  /// * if _e_ is an immediate subexpression of an expression _e1_ which occurs
  ///   in a constant context, unless _e1_ is a `throw` expression or a function
  ///   literal.
  ///
  /// This roughly means that everything which is inside a syntactically
  /// constant expression is in a constant context. A `throw` expression is
  /// currently not allowed in a constant expression, but extensions affecting
  /// that status may be considered. A similar situation arises for function
  /// literals.
  ///
  /// Note that the default value of an optional formal parameter is _not_ a
  /// constant context. This choice reserves some freedom to modify the
  /// semantics of default values.
  bool get inConstantContext;

  /// Return `true` if this expression is syntactically valid for the LHS of an
  /// [AssignmentExpression].
  bool get isAssignable;

  /// Return the precedence of this expression.
  ///
  /// The precedence is a positive integer value that defines how the source
  /// code is parsed into an AST. For example `a * b + c` is parsed as `(a * b)
  /// + c` because the precedence of `*` is greater than the precedence of `+`.
  Precedence get precedence;

  /// If this expression is an argument to an invocation, and the AST structure
  /// has been resolved, and the function being invoked is known based on static
  /// type information, and this expression corresponds to one of the parameters
  /// of the function being invoked, then return the parameter element
  /// representing the parameter to which the value of this expression will be
  /// bound. Otherwise, return `null`.
  ParameterElement? get staticParameterElement;

  /// Return the static type of this expression, or `null` if the AST structure
  /// has not been resolved.
  DartType? get staticType;

  /// If this expression is a parenthesized expression, return the result of
  /// unwrapping the expression inside the parentheses. Otherwise, return this
  /// expression.
  Expression get unParenthesized;
}

/// A function body consisting of a single expression.
///
///    expressionFunctionBody ::=
///        'async'? '=>' [Expression] ';'
///
/// Clients may not extend, implement or mix-in this class.
abstract class ExpressionFunctionBody implements FunctionBody {
  /// Return the expression representing the body of the function.
  Expression get expression;

  /// Return the token introducing the expression that represents the body of the
  /// function.
  Token get functionDefinition;

  /// Return the semicolon terminating the statement.
  Token? get semicolon;
}

/// An expression used as a statement.
///
///    expressionStatement ::=
///        [Expression]? ';'
///
/// Clients may not extend, implement or mix-in this class.
abstract class ExpressionStatement implements Statement {
  /// Return the expression that comprises the statement.
  Expression get expression;

  /// Return the semicolon terminating the statement, or `null` if the
  /// expression is a function expression and therefore isn't followed by a
  /// semicolon.
  Token? get semicolon;
}

/// The declaration of one or more fields of the same type.
///
///    fieldDeclaration ::=
///        'static' 'const' <type>? <staticFinalDeclarationList>
///      | 'static' 'final' <type>? <staticFinalDeclarationList>
///      | 'static' 'late' 'final' <type>? <initializedIdentifierList>
///      | 'static' 'late'? <varOrType> <initializedIdentifierList>
///      | 'covariant' 'late'? <varOrType> <initializedIdentifierList>
///      | 'late'? 'final' <type>? <initializedIdentifierList>
///      | 'late'? <varOrType> <initializedIdentifierList>
///      | 'external' ('static'? <finalVarOrType> | 'covariant' <varOrType>)
///            <identifierList>
///      | 'abstract' (<finalVarOrType> | 'covariant' <varOrType>)
///            <identifierList>
///
/// (Note: there is no <fieldDeclaration> production in the grammar; this is a
/// subset of the grammar production <declaration>, which encompasses everything
/// that can appear inside a class declaration except methods).
///
/// Prior to the 'extension-methods' experiment, these nodes were always
/// children of a class declaration. When the experiment is enabled, these nodes
/// can also be children of an extension declaration.
///
/// Clients may not extend, implement or mix-in this class.
abstract class FieldDeclaration implements ClassMember {
  /// The `abstract` keyword, or `null` if the keyword was not used.
  Token? get abstractKeyword;

  /// The 'covariant' keyword, or `null` if the keyword was not used.
  Token? get covariantKeyword;

  /// The `external` keyword, or `null` if the keyword was not used.
  Token? get externalKeyword;

  /// Return the fields being declared.
  VariableDeclarationList get fields;

  /// Return `true` if the fields are declared to be static.
  bool get isStatic;

  /// Return the semicolon terminating the declaration.
  Token get semicolon;

  /// Return the token representing the 'static' keyword, or `null` if the
  /// fields are not static.
  Token? get staticKeyword;
}

/// A field formal parameter.
///
///    fieldFormalParameter ::=
///        ('final' [TypeAnnotation] | 'const' [TypeAnnotation] | 'var' | [TypeAnnotation])?
///        'this' '.' [SimpleIdentifier] ([TypeParameterList]? [FormalParameterList])?
///
/// Clients may not extend, implement or mix-in this class.
abstract class FieldFormalParameter implements NormalFormalParameter {
  @override
  SimpleIdentifier get identifier;

  /// Return the token representing either the 'final', 'const' or 'var'
  /// keyword, or `null` if no keyword was used.
  Token? get keyword;

  /// Return the parameters of the function-typed parameter, or `null` if this
  /// is not a function-typed field formal parameter.
  FormalParameterList? get parameters;

  /// Return the token representing the period.
  Token get period;

  /// If the parameter is function-typed, and has the question mark, then its
  /// function type is nullable. Having a nullable function type means that the
  /// parameter can be null.
  Token? get question;

  /// Return the token representing the 'this' keyword.
  Token get thisKeyword;

  /// Return the declared type of the parameter, or `null` if the parameter does
  /// not have a declared type.
  ///
  /// Note that if this is a function-typed field formal parameter this is the
  /// return type of the function.
  TypeAnnotation? get type;

  /// Return the type parameters associated with this method, or `null` if this
  /// method is not a generic method.
  TypeParameterList? get typeParameters;
}

/// The parts of a for-each loop that control the iteration.
///
/// Clients may not extend, implement or mix-in this class.
abstract class ForEachParts implements ForLoopParts {
  /// Return the token representing the 'in' keyword.
  Token get inKeyword;

  /// Return the expression evaluated to produce the iterator.
  Expression get iterable;
}

/// The parts of a for-each loop that control the iteration when the loop
/// variable is declared as part of the for loop.
///
///   forLoopParts ::=
///       [DeclaredIdentifier] 'in' [Expression]
///
/// Clients may not extend, implement or mix-in this class.
abstract class ForEachPartsWithDeclaration implements ForEachParts {
  /// Return the declaration of the loop variable.
  DeclaredIdentifier get loopVariable;
}

/// The parts of a for-each loop that control the iteration when the loop
/// variable is declared outside of the for loop.
///
///   forLoopParts ::=
///       [SimpleIdentifier] 'in' [Expression]
///
/// Clients may not extend, implement or mix-in this class.
abstract class ForEachPartsWithIdentifier implements ForEachParts {
  /// Return the loop variable.
  SimpleIdentifier get identifier;
}

/// The basic structure of a for element.
///
/// Clients may not extend, implement or mix-in this class.
abstract class ForElement implements CollectionElement {
  /// Return the token representing the 'await' keyword, or `null` if there was
  /// no 'await' keyword.
  Token? get awaitKeyword;

  /// Return the body of the loop.
  CollectionElement get body;

  /// Return the token representing the 'for' keyword.
  Token get forKeyword;

  /// Return the parts of the for element that control the iteration.
  ForLoopParts get forLoopParts;

  /// Return the left parenthesis.
  Token get leftParenthesis;

  /// Return the right parenthesis.
  Token get rightParenthesis;
}

/// The parts of a for or for-each loop that control the iteration.
///
///   forLoopParts ::=
///       [VariableDeclaration] ';' [Expression]? ';' expressionList?
///     | [Expression]? ';' [Expression]? ';' expressionList?
///     | [DeclaredIdentifier] 'in' [Expression]
///     | [SimpleIdentifier] 'in' [Expression]
///
///   expressionList ::=
///       [Expression] (',' [Expression])*
///
/// Clients may not extend, implement or mix-in this class.
abstract class ForLoopParts implements AstNode {}

/// A node representing a parameter to a function.
///
///    formalParameter ::=
///        [NormalFormalParameter]
///      | [DefaultFormalParameter]
///
/// Clients may not extend, implement or mix-in this class.
abstract class FormalParameter implements AstNode {
  /// The 'covariant' keyword, or `null` if the keyword was not used.
  Token? get covariantKeyword;

  /// Return the element representing this parameter, or `null` if this
  /// parameter has not been resolved.
  ParameterElement? get declaredElement;

  /// Return the name of the parameter being declared, or `null` if the
  /// parameter doesn't have a name, such as when it's part of a generic
  /// function type.
  SimpleIdentifier? get identifier;

  /// Return `true` if this parameter is a named parameter.
  ///
  /// Named parameters can either be required or optional.
  bool get isNamed;

  /// Return `true` if this parameter is an optional parameter.
  ///
  /// Optional parameters can either be positional or named.
  bool get isOptional;

  /// Return `true` if this parameter is both an optional and named parameter.
  bool get isOptionalNamed;

  /// Return `true` if this parameter is both an optional and positional
  /// parameter.
  bool get isOptionalPositional;

  /// Return `true` if this parameter is a positional parameter.
  ///
  /// Positional parameters can either be required or optional.
  bool get isPositional;

  /// Return `true` if this parameter is a required parameter.
  ///
  /// Required parameters can either be positional or named.
  ///
  /// Note: this will return `false` for a named parameter that is annotated
  /// with the `@required` annotation.
  bool get isRequired;

  /// Return `true` if this parameter is both a required and named parameter.
  ///
  /// Note: this will return `false` for a named parameter that is annotated
  /// with the `@required` annotation.
  bool get isRequiredNamed;

  /// Return `true` if this parameter is both a required and positional
  /// parameter.
  bool get isRequiredPositional;

  /// Return the annotations associated with this parameter.
  NodeList<Annotation> get metadata;

  /// The 'required' keyword, or `null` if the keyword was not used.
  Token? get requiredKeyword;
}

/// The formal parameter list of a method declaration, function declaration, or
/// function type alias.
///
/// While the grammar requires all optional formal parameters to follow all of
/// the normal formal parameters and at most one grouping of optional formal
/// parameters, this class does not enforce those constraints. All parameters
/// are flattened into a single list, which can have any or all kinds of
/// parameters (normal, named, and positional) in any order.
///
///    formalParameterList ::=
///        '(' ')'
///      | '(' normalFormalParameters (',' optionalFormalParameters)? ')'
///      | '(' optionalFormalParameters ')'
///
///    normalFormalParameters ::=
///        [NormalFormalParameter] (',' [NormalFormalParameter])*
///
///    optionalFormalParameters ::=
///        optionalPositionalFormalParameters
///      | namedFormalParameters
///
///    optionalPositionalFormalParameters ::=
///        '[' [DefaultFormalParameter] (',' [DefaultFormalParameter])* ']'
///
///    namedFormalParameters ::=
///        '{' [DefaultFormalParameter] (',' [DefaultFormalParameter])* '}'
///
/// Clients may not extend, implement or mix-in this class.
abstract class FormalParameterList implements AstNode {
  /// Return the left square bracket ('[') or left curly brace ('{') introducing
  /// the optional parameters, or `null` if there are no optional parameters.
  Token? get leftDelimiter;

  /// Return the left parenthesis.
  Token get leftParenthesis;

  /// Return a list containing the elements representing the parameters in this
  /// list.
  ///
  /// The list will contain `null`s if the parameters in this list have not
  /// been resolved.
  List<ParameterElement?> get parameterElements;

  /// Return the parameters associated with the method.
  NodeList<FormalParameter> get parameters;

  /// Return the right square bracket (']') or right curly brace ('}')
  /// terminating the optional parameters, or `null` if there are no optional
  /// parameters.
  Token? get rightDelimiter;

  /// Return the right parenthesis.
  Token get rightParenthesis;
}

/// The parts of a for loop that control the iteration.
///
///   forLoopParts ::=
///       [VariableDeclaration] ';' [Expression]? ';' expressionList?
///     | [Expression]? ';' [Expression]? ';' expressionList?
///
/// Clients may not extend, implement or mix-in this class.
abstract class ForParts implements ForLoopParts {
  /// Return the condition used to determine when to terminate the loop, or
  /// `null` if there is no condition.
  Expression? get condition;

  /// Return the semicolon separating the initializer and the condition.
  Token get leftSeparator;

  /// Return the semicolon separating the condition and the updater.
  Token get rightSeparator;

  /// Return the list of expressions run after each execution of the loop body.
  NodeList<Expression> get updaters;
}

/// The parts of a for loop that control the iteration when there are one or
/// more variable declarations as part of the for loop.
///
///   forLoopParts ::=
///       [VariableDeclarationList] ';' [Expression]? ';' expressionList?
///
/// Clients may not extend, implement or mix-in this class.
abstract class ForPartsWithDeclarations implements ForParts {
  /// Return the declaration of the loop variables.
  VariableDeclarationList get variables;
}

/// The parts of a for loop that control the iteration when there are no
/// variable declarations as part of the for loop.
///
///   forLoopParts ::=
///       [Expression]? ';' [Expression]? ';' expressionList?
///
/// Clients may not extend, implement or mix-in this class.
abstract class ForPartsWithExpression implements ForParts {
  /// Return the initialization expression, or `null` if there is no
  /// initialization expression.
  Expression? get initialization;
}

/// A for or for-each statement.
///
///    forStatement ::=
///        'for' '(' forLoopParts ')' [Statement]
///
///    forLoopParts ::=
///       [VariableDeclaration] ';' [Expression]? ';' expressionList?
///     | [Expression]? ';' [Expression]? ';' expressionList?
///     | [DeclaredIdentifier] 'in' [Expression]
///     | [SimpleIdentifier] 'in' [Expression]
///
/// This is the class that is used to represent a for loop when either the
/// 'control-flow-collections' or 'spread-collections' experiments are enabled.
/// If neither of those experiments are enabled, then either `ForStatement` or
/// `ForEachStatement` will be used.
///
/// Clients may not extend, implement or mix-in this class.
abstract class ForStatement implements Statement {
  /// Return the token representing the 'await' keyword, or `null` if there is
  /// no 'await' keyword.
  Token? get awaitKeyword;

  /// Return the body of the loop.
  Statement get body;

  /// Return the token representing the 'for' keyword.
  Token get forKeyword;

  /// Return the parts of the for element that control the iteration.
  ForLoopParts get forLoopParts;

  /// Return the left parenthesis.
  Token get leftParenthesis;

  /// Return the right parenthesis.
  Token get rightParenthesis;
}

/// A node representing the body of a function or method.
///
///    functionBody ::=
///        [BlockFunctionBody]
///      | [EmptyFunctionBody]
///      | [ExpressionFunctionBody]
///      | [NativeFunctionBody]
///
/// Clients may not extend, implement or mix-in this class.
abstract class FunctionBody implements AstNode {
  /// Return `true` if this function body is asynchronous.
  bool get isAsynchronous;

  /// Return `true` if this function body is a generator.
  bool get isGenerator;

  /// Return `true` if this function body is synchronous.
  bool get isSynchronous;

  /// Return the token representing the 'async' or 'sync' keyword, or `null` if
  /// there is no such keyword.
  Token? get keyword;

  /// Return the star following the 'async' or 'sync' keyword, or `null` if
  /// there is no star.
  Token? get star;

  /// If [variable] is a local variable or parameter declared anywhere within
  /// the top level function or method containing this [FunctionBody], return a
  /// boolean indicating whether [variable] is potentially mutated within a
  /// local function other than the function in which it is declared.
  ///
  /// If [variable] is not a local variable or parameter declared within the top
  /// level function or method containing this [FunctionBody], return `false`.
  ///
  /// Throws an exception if resolution has not yet been performed.
  bool isPotentiallyMutatedInClosure(VariableElement variable);

  /// If [variable] is a local variable or parameter declared anywhere within
  /// the top level function or method containing this [FunctionBody], return a
  /// boolean indicating whether [variable] is potentially mutated within the
  /// scope of its declaration.
  ///
  /// If [variable] is not a local variable or parameter declared within the top
  /// level function or method containing this [FunctionBody], return `false`.
  ///
  /// Throws an exception if resolution has not yet been performed.
  bool isPotentiallyMutatedInScope(VariableElement variable);
}

/// A top-level function declaration.
///
///    functionDeclaration ::=
///        'external' functionSignature
///      | functionSignature [FunctionBody]
///
///    functionSignature ::=
///        [Type]? ('get' | 'set')? [SimpleIdentifier] [FormalParameterList]
///
/// Clients may not extend, implement or mix-in this class.
abstract class FunctionDeclaration implements NamedCompilationUnitMember {
  @override
  ExecutableElement? get declaredElement;

  /// Return the token representing the 'external' keyword, or `null` if this is
  /// not an external function.
  Token? get externalKeyword;

  /// Return the function expression being wrapped.
  FunctionExpression get functionExpression;

  @override
  SimpleIdentifier get name;

  /// Return the token representing the 'get' or 'set' keyword, or `null` if
  /// this is a function declaration rather than a property declaration.
  Token? get propertyKeyword;

  /// Return the return type of the function, or `null` if no return type was
  /// declared.
  TypeAnnotation? get returnType;
}

/// A [FunctionDeclaration] used as a statement.
///
/// Clients may not extend, implement or mix-in this class.
abstract class FunctionDeclarationStatement implements Statement {
  /// Return the function declaration being wrapped.
  FunctionDeclaration get functionDeclaration;
}

/// A function expression.
///
///    functionExpression ::=
///        [TypeParameterList]? [FormalParameterList] [FunctionBody]
///
/// Clients may not extend, implement or mix-in this class.
abstract class FunctionExpression implements Expression {
  /// Return the body of the function.
  FunctionBody get body;

  /// Return the element associated with the function, or `null` if the AST
  /// structure has not been resolved.
  ExecutableElement? get declaredElement;

  /// Return the parameters associated with the function, or `null` if the
  /// function is part of a top-level getter.
  FormalParameterList? get parameters;

  /// Return the type parameters associated with this method, or `null` if this
  /// method is not a generic method.
  TypeParameterList? get typeParameters;
}

/// The invocation of a function resulting from evaluating an expression.
///
/// Invocations of methods and other forms of functions are represented by
/// [MethodInvocation] nodes. Invocations of getters and setters are represented
/// by either [PrefixedIdentifier] or [PropertyAccess] nodes.
///
///    functionExpressionInvocation ::=
///        [Expression] [TypeArgumentList]? [ArgumentList]
///
/// Clients may not extend, implement or mix-in this class.
abstract class FunctionExpressionInvocation
    implements NullShortableExpression, InvocationExpression {
  /// Return the expression producing the function being invoked.
  @override
  Expression get function;

  /// Return the element associated with the function being invoked based on
  /// static type information, or `null` if the AST structure has not been
  /// resolved or the function could not be resolved.
  ExecutableElement? get staticElement;
}

/// An expression representing a reference to a function, possibly with type
/// arguments applied to it, e.g. the expression `print` in `var x = print;`.
///
/// Clients may not extend, implement or mix-in this class.
abstract class FunctionReference
    implements Expression, CommentReferableExpression {
  /// The function being referenced.
  ///
  /// In error-free code, this will be either a SimpleIdentifier (indicating a
  /// function that is in scope), a PrefixedIdentifier (indicating a either
  /// function imported via prefix or a static method in a class), or a
  /// PropertyAccess (indicating a static method in a class imported via
  /// prefix).  In code with errors, this could be other kinds of expressions
  /// (e.g. `(...)<int>` parses as a FunctionReference whose referent is a
  /// ParenthesizedExpression.
  Expression get function;

  /// The type arguments being applied to the function, or `null` if there are
  /// no type arguments.
  TypeArgumentList? get typeArguments;

  /// The actual type arguments being applied to the function, either explicitly
  /// specified in [typeArguments], or inferred.
  ///
  /// If the AST has been resolved, never returns `null`, returns an empty list
  /// if the function does not have type parameters.
  ///
  /// Returns `null` if the AST structure has not been resolved.
  List<DartType>? get typeArgumentTypes;
}

/// A function type alias.
///
///    functionTypeAlias ::=
///        functionPrefix [TypeParameterList]? [FormalParameterList] ';'
///
///    functionPrefix ::=
///        [TypeAnnotation]? [SimpleIdentifier]
///
/// Clients may not extend, implement or mix-in this class.
abstract class FunctionTypeAlias implements TypeAlias {
  @override
  TypeAliasElement? get declaredElement;

  /// Return the parameters associated with the function type.
  FormalParameterList get parameters;

  /// Return the return type of the function type being defined, or `null` if no
  /// return type was given.
  TypeAnnotation? get returnType;

  /// Return the type parameters for the function type, or `null` if the
  /// function type does not have any type parameters.
  TypeParameterList? get typeParameters;
}

/// A function-typed formal parameter.
///
///    functionSignature ::=
///        [TypeAnnotation]? [SimpleIdentifier] [TypeParameterList]?
///        [FormalParameterList] '?'?
///
/// Clients may not extend, implement or mix-in this class.
abstract class FunctionTypedFormalParameter implements NormalFormalParameter {
  @override
  SimpleIdentifier get identifier;

  /// Return the parameters of the function-typed parameter.
  FormalParameterList get parameters;

  /// Return the question mark indicating that the function type is nullable, or
  /// `null` if there is no question mark. Having a nullable function type means
  /// that the parameter can be null.
  Token? get question;

  /// Return the return type of the function, or `null` if the function does not
  /// have a return type.
  TypeAnnotation? get returnType;

  /// Return the type parameters associated with this function, or `null` if
  /// this function is not a generic function.
  TypeParameterList? get typeParameters;
}

/// An anonymous function type.
///
///    functionType ::=
///        [TypeAnnotation]? 'Function' [TypeParameterList]?
///        [FormalParameterList] '?'?
///
/// where the FormalParameterList is being used to represent the following
/// grammar, despite the fact that FormalParameterList can represent a much
/// larger grammar than the one below. This is done in order to simplify the
/// implementation.
///
///    parameterTypeList ::=
///        () |
///        ( normalParameterTypes ,? ) |
///        ( normalParameterTypes , optionalParameterTypes ) |
///        ( optionalParameterTypes )
///    namedParameterTypes ::=
///        { namedParameterType (, namedParameterType)* ,? }
///    namedParameterType ::=
///        [TypeAnnotation]? [SimpleIdentifier]
///    normalParameterTypes ::=
///        normalParameterType (, normalParameterType)*
///    normalParameterType ::=
///        [TypeAnnotation] [SimpleIdentifier]?
///    optionalParameterTypes ::=
///        optionalPositionalParameterTypes | namedParameterTypes
///    optionalPositionalParameterTypes ::=
///        [ normalParameterTypes ,? ]
///
/// Clients may not extend, implement or mix-in this class.
abstract class GenericFunctionType implements TypeAnnotation {
  /// Return the keyword 'Function'.
  Token get functionKeyword;

  /// Return the parameters associated with the function type.
  FormalParameterList get parameters;

  /// Return the return type of the function type being defined, or `null` if
  /// no return type was given.
  TypeAnnotation? get returnType;

  /// Return the type parameters for the function type, or `null` if the
  /// function type does not have any type parameters.
  TypeParameterList? get typeParameters;
}

/// A generic type alias.
///
///    functionTypeAlias ::=
///        metadata 'typedef' [SimpleIdentifier] [TypeParameterList]? = [FunctionType] ';'
///
/// Clients may not extend, implement or mix-in this class.
abstract class GenericTypeAlias implements TypeAlias {
  /// Return the equal sign separating the name being defined from the function
  /// type.
  Token get equals;

  /// Return the type of function being defined by the alias.
  ///
  /// When the non-function type aliases feature is enabled and the denoted
  /// type is not a [GenericFunctionType], return `null`.
  GenericFunctionType? get functionType;

  /// Return the type being defined by the alias.
  TypeAnnotation get type;

  /// Return the type parameters for the function type, or `null` if the
  /// function type does not have any type parameters.
  TypeParameterList? get typeParameters;
}

/// A combinator that restricts the names being imported to those that are not
/// in a given list.
///
///    hideCombinator ::=
///        'hide' [SimpleIdentifier] (',' [SimpleIdentifier])*
///
/// Clients may not extend, implement or mix-in this class.
abstract class HideCombinator implements Combinator {
  /// Return the list of names from the library that are hidden by this
  /// combinator.
  NodeList<SimpleIdentifier> get hiddenNames;
}

/// A node that represents an identifier.
///
///    identifier ::=
///        [SimpleIdentifier]
///      | [PrefixedIdentifier]
///
/// Clients may not extend, implement or mix-in this class.
abstract class Identifier implements Expression, CommentReferableExpression {
  /// Return the lexical representation of the identifier.
  String get name;

  /// Return the element associated with this identifier based on static type
  /// information, or `null` if the AST structure has not been resolved or if
  /// this identifier could not be resolved.
  ///
  /// One example of the latter case is an identifier that is not defined
  /// within the scope in which it appears.
  Element? get staticElement;

  /// Return `true` if the given [name] is visible only within the library in
  /// which it is declared.
  static bool isPrivateName(String name) => name.isNotEmpty && name[0] == "_";
}

/// The basic structure of an if element.
///
/// Clients may not extend, implement or mix-in this class.
abstract class IfElement implements CollectionElement {
  /// Return the condition used to determine which of the statements is executed
  /// next.
  Expression get condition;

  /// Return the statement that is executed if the condition evaluates to
  /// `false`, or `null` if there is no else statement.
  CollectionElement? get elseElement;

  /// Return the token representing the 'else' keyword, or `null` if there is no
  /// else statement.
  Token? get elseKeyword;

  /// Return the token representing the 'if' keyword.
  Token get ifKeyword;

  /// Return the left parenthesis.
  Token get leftParenthesis;

  /// Return the right parenthesis.
  Token get rightParenthesis;

  /// Return the statement that is executed if the condition evaluates to
  /// `true`.
  CollectionElement get thenElement;
}

/// An if statement.
///
///    ifStatement ::=
///        'if' '(' [Expression] ')' [Statement] ('else' [Statement])?
///
/// Clients may not extend, implement or mix-in this class.
abstract class IfStatement implements Statement {
  /// Return the condition used to determine which of the statements is executed
  /// next.
  Expression get condition;

  /// Return the token representing the 'else' keyword, or `null` if there is no
  /// else statement.
  Token? get elseKeyword;

  /// Return the statement that is executed if the condition evaluates to
  /// `false`, or `null` if there is no else statement.
  Statement? get elseStatement;

  /// Return the token representing the 'if' keyword.
  Token get ifKeyword;

  /// Return the left parenthesis.
  Token get leftParenthesis;

  /// Return the right parenthesis.
  Token get rightParenthesis;

  /// Return the statement that is executed if the condition evaluates to
  /// `true`.
  Statement get thenStatement;
}

/// An expression representing an implicit 'call' method reference.
///
/// Objects of this type are not produced directly by the parser (because the
/// parser cannot tell whether an expression refers to a callable type); they
/// are produced at resolution time.
///
/// Clients may not extend, implement or mix-in this class.
abstract class ImplicitCallReference implements MethodReferenceExpression {
  /// Return the expression from which a `call` method is being referenced.
  Expression get expression;

  /// Return the element associated with the implicit 'call' reference based on
  /// the static types.
  @override
  MethodElement get staticElement;

  /// The type arguments being applied to the tear-off, or `null` if there are
  /// no type arguments.
  TypeArgumentList? get typeArguments;

  /// The actual type arguments being applied to the tear-off, either explicitly
  /// specified in [typeArguments], or inferred.
  ///
  /// Returns an empty list if the 'call' method does not have type parameters.
  List<DartType> get typeArgumentTypes;
}

/// An index expression.
///
///    indexExpression ::=
///        [Expression] '[' [Expression] ']'
///
/// Clients may not extend, implement or mix-in this class.
abstract class IndexExpression
    implements NullShortableExpression, MethodReferenceExpression {
  /// Return the expression used to compute the index.
  Expression get index;

  /// Return `true` if this expression is cascaded.
  ///
  /// If it is, then the target of this expression is not stored locally but is
  /// stored in the nearest ancestor that is a [CascadeExpression].
  bool get isCascaded;

  /// Whether this index expression is null aware (as opposed to non-null).
  bool get isNullAware;

  /// Return the left square bracket.
  Token get leftBracket;

  /// Return the period (".." | "?..") before a cascaded index expression, or
  /// `null` if this index expression is not part of a cascade expression.
  Token? get period;

  /// Return the question mark before the left bracket, or `null` if there is no
  /// question mark.
  Token? get question;

  /// Return the expression used to compute the object being indexed.
  ///
  /// If this index expression is not part of a cascade expression, then this
  /// is the same as [target]. If this index expression is part of a cascade
  /// expression, then the target expression stored with the cascade expression
  /// is returned.
  Expression get realTarget;

  /// Return the right square bracket.
  Token get rightBracket;

  /// Return the expression used to compute the object being indexed, or `null`
  /// if this index expression is part of a cascade expression.
  ///
  /// Use [realTarget] to get the target independent of whether this is part of
  /// a cascade expression.
  Expression? get target;

  /// Return `true` if this expression is computing a right-hand value (that is,
  /// if this expression is in a context where the operator '[]' will be
  /// invoked).
  ///
  /// Note that [inGetterContext] and [inSetterContext] are not opposites, nor
  /// are they mutually exclusive. In other words, it is possible for both
  /// methods to return `true` when invoked on the same node.
  // TODO(brianwilkerson) Convert this to a getter.
  bool inGetterContext();

  /// Return `true` if this expression is computing a left-hand value (that is,
  /// if this expression is in a context where the operator '[]=' will be
  /// invoked).
  ///
  /// Note that [inGetterContext] and [inSetterContext] are not opposites, nor
  /// are they mutually exclusive. In other words, it is possible for both
  /// methods to return `true` when invoked on the same node.
  // TODO(brianwilkerson) Convert this to a getter.
  bool inSetterContext();
}

/// An integer literal expression.
///
///    integerLiteral ::=
///        decimalIntegerLiteral
///      | hexadecimalIntegerLiteral
///
///    decimalIntegerLiteral ::=
///        decimalDigit+
///
///    hexadecimalIntegerLiteral ::=
///        '0x' hexadecimalDigit+
///      | '0X' hexadecimalDigit+
///
/// Clients may not extend, implement or mix-in this class.
abstract class IntegerLiteral implements Literal {
  /// Return the token representing the literal.
  Token get literal;

  /// Return the value of the literal, or `null` when [literal] does not
  /// represent a valid `int` value, for example because of overflow.
  int? get value;
}

/// A node within a [StringInterpolation].
///
///    interpolationElement ::=
///        [InterpolationExpression]
///      | [InterpolationString]
///
/// Clients may not extend, implement or mix-in this class.
abstract class InterpolationElement implements AstNode {}

/// An expression embedded in a string interpolation.
///
///    interpolationExpression ::=
///        '$' [SimpleIdentifier]
///      | '$' '{' [Expression] '}'
///
/// Clients may not extend, implement or mix-in this class.
abstract class InterpolationExpression implements InterpolationElement {
  /// Return the expression to be evaluated for the value to be converted into a
  /// string.
  Expression get expression;

  /// Return the token used to introduce the interpolation expression; either
  /// '$' if the expression is a simple identifier or '${' if the expression is
  /// a full expression.
  Token get leftBracket;

  /// Return the right curly bracket, or `null` if the expression is an
  /// identifier without brackets.
  Token? get rightBracket;
}

/// A non-empty substring of an interpolated string.
///
///    interpolationString ::=
///        characters
///
/// Clients may not extend, implement or mix-in this class.
abstract class InterpolationString implements InterpolationElement {
  /// Return the characters that will be added to the string.
  Token get contents;

  /// Return the offset of the after-last contents character.
  int get contentsEnd;

  /// Return the offset of the first contents character.
  int get contentsOffset;

  /// Return the value of the literal.
  String get value;
}

/// The invocation of a function or method; either a
/// [FunctionExpressionInvocation] or a [MethodInvocation].
///
/// Clients may not extend, implement or mix-in this class.
abstract class InvocationExpression implements Expression {
  /// Return the list of arguments to the method.
  ArgumentList get argumentList;

  /// The expression that identifies the function or method being invoked.
  /// For example:
  ///
  ///     (o.m)<TArgs>(args); // target will be `o.m`
  ///     o.m<TArgs>(args);   // target will be `m`
  ///
  /// In either case, the [function.staticType] will be the
  /// [staticInvokeType] before applying type arguments `TArgs`.
  Expression get function;

  /// Return the function type of the invocation based on the static type
  /// information, or `null` if the AST structure has not been resolved, or if
  /// the invoke could not be resolved.
  ///
  /// This will usually be a [FunctionType], but it can also be `dynamic` or
  /// `Function`. In the case of interface types that have a `call` method, we
  /// store the type of that `call` method here as parameterized.
  DartType? get staticInvokeType;

  /// Return the type arguments to be applied to the method being invoked, or
  /// `null` if no type arguments were provided.
  TypeArgumentList? get typeArguments;

  /// Return the actual type arguments of the invocation, either explicitly
  /// specified in [typeArguments], or inferred.
  ///
  /// If the AST has been resolved, never returns `null`, returns an empty list
  /// if the [function] does not have type parameters.
  ///
  /// Return `null` if the AST structure has not been resolved.
  List<DartType>? get typeArgumentTypes;
}

/// A label on either a [LabeledStatement] or a [NamedExpression].
///
///    label ::=
///        [SimpleIdentifier] ':'
///
/// Clients may not extend, implement or mix-in this class.
abstract class Label implements AstNode {
  /// Return the colon that separates the label from the statement.
  Token get colon;

  /// Return the label being associated with the statement.
  SimpleIdentifier get label;
}

/// A statement that has a label associated with them.
///
///    labeledStatement ::=
///       [Label]+ [Statement]
///
/// Clients may not extend, implement or mix-in this class.
abstract class LabeledStatement implements Statement {
  /// Return the labels being associated with the statement.
  NodeList<Label> get labels;

  /// Return the statement with which the labels are being associated.
  Statement get statement;
}

/// A list literal.
///
///    listLiteral ::=
///        'const'? [TypeAnnotationList]? '[' elements? ']'
///
///    elements ::=
///        [CollectionElement] (',' [CollectionElement])* ','?
///
/// Clients may not extend, implement or mix-in this class.
abstract class ListLiteral implements TypedLiteral {
  /// Return the syntactic elements used to compute the elements of the list.
  NodeList<CollectionElement> get elements;

  /// Return the left square bracket.
  Token get leftBracket;

  /// Return the right square bracket.
  Token get rightBracket;
}

/// A node that represents a literal expression.
///
///    literal ::=
///        [BooleanLiteral]
///      | [DoubleLiteral]
///      | [IntegerLiteral]
///      | [ListLiteral]
///      | [NullLiteral]
///      | [SetOrMapLiteral]
///      | [StringLiteral]
///
/// Clients may not extend, implement or mix-in this class.
abstract class Literal implements Expression {}

/// A single key/value pair in a map literal.
///
///    mapLiteralEntry ::=
///        [Expression] ':' [Expression]
///
/// Clients may not extend, implement or mix-in this class.
abstract class MapLiteralEntry implements CollectionElement {
  /// Return the expression computing the key with which the value will be
  /// associated.
  Expression get key;

  /// Return the colon that separates the key from the value.
  Token get separator;

  /// Return the expression computing the value that will be associated with the
  /// key.
  Expression get value;
}

/// A method declaration.
///
///    methodDeclaration ::=
///        methodSignature [FunctionBody]
///
///    methodSignature ::=
///        'external'? ('abstract' | 'static')? [Type]? ('get' | 'set')?
///        methodName [TypeParameterList] [FormalParameterList]
///
///    methodName ::=
///        [SimpleIdentifier]
///      | 'operator' [SimpleIdentifier]
///
/// Prior to the 'extension-methods' experiment, these nodes were always
/// children of a class declaration. When the experiment is enabled, these nodes
/// can also be children of an extension declaration.
///
/// Clients may not extend, implement or mix-in this class.
abstract class MethodDeclaration implements ClassMember {
  /// Return the body of the method.
  FunctionBody get body;

  @override
  ExecutableElement? get declaredElement;

  /// Return the token for the 'external' keyword, or `null` if the constructor
  /// is not external.
  Token? get externalKeyword;

  /// Return `true` if this method declares an operator.
  bool get isOperator;

  /// Return the name of the method.
  SimpleIdentifier get name;

  /// Return the token representing the 'operator' keyword, or `null` if this
  /// method does not declare an operator.
  Token? get operatorKeyword;

  /// Return the parameters associated with the method, or `null` if this method
  /// declares a getter.
  FormalParameterList? get parameters;

  /// Return the token representing the 'get' or 'set' keyword, or `null` if
  /// this is a method declaration rather than a property declaration.
  Token? get propertyKeyword;

  /// Return the return type of the method, or `null` if no return type was
  /// declared.
  TypeAnnotation? get returnType;

  /// Return the type parameters associated with this method, or `null` if this
  /// method is not a generic method.
  TypeParameterList? get typeParameters;
}

/// The invocation of either a function or a method.
///
/// Invocations of functions resulting from evaluating an expression are
/// represented by [FunctionExpressionInvocation] nodes. Invocations of getters
/// and setters are represented by either [PrefixedIdentifier] or
/// [PropertyAccess] nodes.
///
///    methodInvocation ::=
///        ([Expression] '.')? [SimpleIdentifier] [TypeArgumentList]? [ArgumentList]
///
/// Clients may not extend, implement or mix-in this class.
abstract class MethodInvocation
    implements NullShortableExpression, InvocationExpression {
  /// Return `true` if this expression is cascaded.
  ///
  /// If it is, then the target of this expression is not stored locally but is
  /// stored in the nearest ancestor that is a [CascadeExpression].
  bool get isCascaded;

  /// Whether this method invocation is null aware (as opposed to non-null).
  bool get isNullAware;

  /// Return the name of the method being invoked.
  SimpleIdentifier get methodName;

  /// Return the operator that separates the target from the method name, or
  /// `null` if there is no target.
  ///
  /// In an ordinary method invocation this will be period ('.'). In a cascade
  /// section this will be the cascade operator ('..').
  Token? get operator;

  /// Return the expression used to compute the receiver of the invocation.
  ///
  /// If this invocation is not part of a cascade expression, then this is the
  /// same as [target]. If this invocation is part of a cascade expression,
  /// then the target stored with the cascade expression is returned.
  Expression? get realTarget;

  /// Return the expression producing the object on which the method is defined,
  /// or `null` if there is no target (that is, the target is implicitly `this`)
  /// or if this method invocation is part of a cascade expression.
  ///
  /// Use [realTarget] to get the target independent of whether this is part of
  /// a cascade expression.
  Expression? get target;
}

/// An expression that implicitly makes reference to a method.
///
/// Clients may not extend, implement or mix-in this class.
abstract class MethodReferenceExpression implements Expression {
  /// Return the element associated with the expression based on the static
  /// types, or `null` if the AST structure has not been resolved, or there is
  /// no meaningful static element to return (e.g. because this is a
  /// non-compound assignment expression, or because the method referred to
  /// could not be resolved).
  MethodElement? get staticElement;
}

/// A node that declares a single name within the scope of a compilation unit.
///
/// Clients may not extend, implement or mix-in this class.
abstract class NamedCompilationUnitMember implements CompilationUnitMember {
  /// Return the name of the member being declared.
  SimpleIdentifier get name;
}

/// An expression that has a name associated with it. They are used in method
/// invocations when there are named parameters.
///
///    namedExpression ::=
///        [Label] [Expression]
///
/// Clients may not extend, implement or mix-in this class.
abstract class NamedExpression implements Expression {
  /// Return the element representing the parameter being named by this
  /// expression, or `null` if the AST structure has not been resolved or if
  /// there is no parameter with the same name as this expression.
  ParameterElement? get element;

  /// Return the expression with which the name is associated.
  Expression get expression;

  /// Return the name associated with the expression.
  Label get name;
}

/// A named type, which can optionally include type arguments.
///
///    namedType ::=
///        [Identifier] typeArguments?
///
/// Clients may not extend, implement or mix-in this class.
abstract class NamedType implements TypeAnnotation {
  /// Return `true` if this type is a deferred type.
  ///
  /// 15.1 Static Types: A type <i>T</i> is deferred iff it is of the form
  /// </i>p.T</i> where <i>p</i> is a deferred prefix.
  bool get isDeferred;

  /// Return the name of the type.
  Identifier get name;

  /// Return the type arguments associated with the type, or `null` if there are
  /// no type arguments.
  TypeArgumentList? get typeArguments;
}

/// A list of AST nodes that have a common parent.
///
/// Clients may not extend, implement or mix-in this class.
abstract class NodeList<E extends AstNode> implements List<E> {
  /// Return the first token included in this node list's source range, or
  /// `null` if the list is empty.
  Token? get beginToken;

  /// Return the last token included in this node list's source range, or `null`
  /// if the list is empty.
  Token? get endToken;

  /// Return the node that is the parent of each of the elements in the list.
  AstNode get owner;

  /// Return the node at the given [index] in the list or throw a [RangeError]
  /// if [index] is out of bounds.
  @override
  E operator [](int index);

  /// Use the given [visitor] to visit each of the nodes in this list.
  void accept(AstVisitor visitor);
}

/// A formal parameter that is required (is not optional).
///
///    normalFormalParameter ::=
///        [FunctionTypedFormalParameter]
///      | [FieldFormalParameter]
///      | [SimpleFormalParameter]
///
/// Clients may not extend, implement or mix-in this class.
abstract class NormalFormalParameter implements FormalParameter {
  /// Return the documentation comment associated with this parameter, or `null`
  /// if this parameter does not have a documentation comment associated with
  /// it.
  Comment? get documentationComment;

  /// Return a list containing the comment and annotations associated with this
  /// parameter, sorted in lexical order.
  List<AstNode> get sortedCommentAndAnnotations;
}

/// A null literal expression.
///
///    nullLiteral ::=
///        'null'
///
/// Clients may not extend, implement or mix-in this class.
abstract class NullLiteral implements Literal {
  /// Return the token representing the literal.
  Token get literal;
}

/// Abstract interface for expressions that may participate in null-shorting.
abstract class NullShortableExpression implements Expression {
  /// Returns the expression that terminates any null shorting that might occur
  /// in this expression.  This may be called regardless of whether this
  /// expression is itself null-aware.
  ///
  /// For example, the statement `a?.b[c] = d;` contains the following
  /// null-shortable subexpressions:
  /// - `a?.b`
  /// - `a?.b[c]`
  /// - `a?.b[c] = d`
  ///
  /// Calling [nullShortingTermination] on any of these subexpressions yields
  /// the expression `a?.b[c] = d`, indicating that the null-shorting induced by
  /// the `?.` causes the rest of the subexpression `a?.b[c] = d` to be skipped.
  Expression get nullShortingTermination;
}

/// A parenthesized expression.
///
///    parenthesizedExpression ::=
///        '(' [Expression] ')'
///
/// Clients may not extend, implement or mix-in this class.
abstract class ParenthesizedExpression implements Expression {
  /// Return the expression within the parentheses.
  Expression get expression;

  /// Return the left parenthesis.
  Token get leftParenthesis;

  /// Return the right parenthesis.
  Token get rightParenthesis;
}

/// A postfix unary expression.
///
///    postfixExpression ::=
///        [Expression] [Token]
///
/// Clients may not extend, implement or mix-in this class.
abstract class PostfixExpression
    implements
        Expression,
        NullShortableExpression,
        MethodReferenceExpression,
        CompoundAssignmentExpression {
  /// Return the expression computing the operand for the operator.
  Expression get operand;

  /// Return the postfix operator being applied to the operand.
  Token get operator;
}

/// An identifier that is prefixed or an access to an object property where the
/// target of the property access is a simple identifier.
///
///    prefixedIdentifier ::=
///        [SimpleIdentifier] '.' [SimpleIdentifier]
///
/// Clients may not extend, implement or mix-in this class.
abstract class PrefixedIdentifier implements Identifier {
  /// Return the identifier being prefixed.
  SimpleIdentifier get identifier;

  /// Return `true` if this type is a deferred type. If the AST structure has
  /// not been resolved, then return `false`.
  ///
  /// 15.1 Static Types: A type <i>T</i> is deferred iff it is of the form
  /// </i>p.T</i> where <i>p</i> is a deferred prefix.
  bool get isDeferred;

  /// Return the period used to separate the prefix from the identifier.
  Token get period;

  /// Return the prefix associated with the library in which the identifier is
  /// defined.
  SimpleIdentifier get prefix;
}

/// A prefix unary expression.
///
///    prefixExpression ::=
///        [Token] [Expression]
///
/// Clients may not extend, implement or mix-in this class.
abstract class PrefixExpression
    implements
        Expression,
        NullShortableExpression,
        MethodReferenceExpression,
        CompoundAssignmentExpression {
  /// Return the expression computing the operand for the operator.
  Expression get operand;

  /// Return the prefix operator being applied to the operand.
  Token get operator;
}

///The root ast node for a expression.
abstract class Program implements AstNode {
  Expression get expression;
}

/// The access of a property of an object.
///
/// Note, however, that accesses to properties of objects can also be
/// represented as [PrefixedIdentifier] nodes in cases where the target is also
/// a simple identifier.
///
///    propertyAccess ::=
///        [Expression] '.' [SimpleIdentifier]
///
/// Clients may not extend, implement or mix-in this class.
abstract class PropertyAccess
    implements NullShortableExpression, CommentReferableExpression {
  /// Return `true` if this expression is cascaded.
  ///
  /// If it is, then the target of this expression is not stored locally but is
  /// stored in the nearest ancestor that is a [CascadeExpression].
  bool get isCascaded;

  /// Whether this property access is null aware (as opposed to non-null).
  bool get isNullAware;

  /// Return the property access operator.
  Token get operator;

  /// Return the name of the property being accessed.
  SimpleIdentifier get propertyName;

  /// Return the expression used to compute the receiver of the invocation.
  ///
  /// If this invocation is not part of a cascade expression, then this is the
  /// same as [target]. If this invocation is part of a cascade expression,
  /// then the target stored with the cascade expression is returned.
  Expression get realTarget;

  /// Return the expression computing the object defining the property being
  /// accessed, or `null` if this property access is part of a cascade
  /// expression.
  ///
  /// Use [realTarget] to get the target independent of whether this is part of
  /// a cascade expression.
  Expression? get target;
}

/// A return statement.
///
///    returnStatement ::=
///        'return' [Expression]? ';'
///
/// Clients may not extend, implement or mix-in this class.
abstract class ReturnStatement implements Statement {
  /// Return the expression computing the value to be returned, or `null` if no
  /// explicit value was provided.
  Expression? get expression;

  /// Return the token representing the 'return' keyword.
  Token get returnKeyword;

  /// Return the semicolon terminating the statement.
  Token get semicolon;
}

/// A script tag that can optionally occur at the beginning of a compilation
/// unit.
///
///    scriptTag ::=
///        '#!' (~NEWLINE)* NEWLINE
///
/// Clients may not extend, implement or mix-in this class.
abstract class ScriptTag implements AstNode {
  /// Return the token representing this script tag.
  Token get scriptTag;
}

/// A set or map literal.
///
///    setOrMapLiteral ::=
///        'const'? [TypeArgumentList]? '{' elements? '}'
///
///    elements ::=
///        [CollectionElement] ( ',' [CollectionElement] )* ','?
///
/// This is the class that is used to represent either a map or set literal when
/// either the 'control-flow-collections' or 'spread-collections' experiments
/// are enabled. If neither of those experiments are enabled, then `MapLiteral`
/// will be used to represent a map literal and `SetLiteral` will be used for
/// set literals.
///
/// Clients may not extend, implement or mix-in this class.
abstract class SetOrMapLiteral implements TypedLiteral {
  /// Return the syntactic elements used to compute the elements of the set or
  /// map.
  NodeList<CollectionElement> get elements;

  /// Return `true` if this literal represents a map literal.
  ///
  /// This getter will always return `false` if [isSet] returns `true`.
  ///
  /// However, this getter is _not_ the inverse of [isSet]. It is possible for
  /// both getters to return `false` if
  ///
  /// - the AST has not been resolved (because determining the kind of the
  ///   literal is done during resolution),
  /// - the literal is ambiguous (contains one or more spread elements and none
  ///   of those elements can be used to determine the kind of the literal), or
  /// - the literal is invalid because it contains both expressions (for sets)
  ///   and map entries (for maps).
  ///
  /// In both of the latter two cases there will be compilation errors
  /// associated with the literal.
  bool get isMap;

  /// Return `true` if this literal represents a set literal.
  ///
  /// This getter will always return `false` if [isMap] returns `true`.
  ///
  /// However, this getter is _not_ the inverse of [isMap]. It is possible for
  /// both getters to return `false` if
  ///
  /// - the AST has not been resolved (because determining the kind of the
  ///   literal is done during resolution),
  /// - the literal is ambiguous (contains one or more spread elements and none
  ///   of those elements can be used to determine the kind of the literal), or
  /// - the literal is invalid because it contains both expressions (for sets)
  ///   and map entries (for maps).
  ///
  /// In both of the latter two cases there will be compilation errors
  /// associated with the literal.
  bool get isSet;

  /// Return the left curly bracket.
  Token get leftBracket;

  /// Return the right curly bracket.
  Token get rightBracket;
}

/// A simple formal parameter.
///
///    simpleFormalParameter ::=
///        ('final' [TypeAnnotation] | 'var' | [TypeAnnotation])? [SimpleIdentifier]
///
/// Clients may not extend, implement or mix-in this class.
abstract class SimpleFormalParameter implements NormalFormalParameter {
  /// Return the token representing either the 'final', 'const' or 'var'
  /// keyword, or `null` if no keyword was used.
  Token? get keyword;

  /// Return the declared type of the parameter, or `null` if the parameter does
  /// not have a declared type.
  TypeAnnotation? get type;
}

/// A simple identifier.
///
///    simpleIdentifier ::=
///        initialCharacter internalCharacter*
///
///    initialCharacter ::= '_' | '$' | letter
///
///    internalCharacter ::= '_' | '$' | letter | digit
///
/// Clients may not extend, implement or mix-in this class.
abstract class SimpleIdentifier implements Identifier {
  /// Return `true` if this identifier is the "name" part of a prefixed
  /// identifier or a method invocation.
  bool get isQualified;

  /// If the identifier is a tear-off, return the inferred type arguments
  /// applied to the function type of the element to produce its `[staticType]`.
  ///
  /// Return an empty list if the function type does not have type parameters.
  ///
  /// Return an empty list if the context type has type parameters.
  ///
  /// Return `null` if not a tear-off.
  ///
  /// Return `null` if the AST structure has not been resolved.
  List<DartType>? get tearOffTypeArgumentTypes;

  /// Return the token representing the identifier.
  Token get token;

  /// Return `true` if this identifier is the name being declared in a
  /// declaration.
  // TODO(brianwilkerson) Convert this to a getter.
  bool inDeclarationContext();

  /// Return `true` if this expression is computing a right-hand value.
  ///
  /// Note that [inGetterContext] and [inSetterContext] are not opposites, nor
  /// are they mutually exclusive. In other words, it is possible for both
  /// methods to return `true` when invoked on the same node.
  // TODO(brianwilkerson) Convert this to a getter.
  bool inGetterContext();

  /// Return `true` if this expression is computing a left-hand value.
  ///
  /// Note that [inGetterContext] and [inSetterContext] are not opposites, nor
  /// are they mutually exclusive. In other words, it is possible for both
  /// methods to return `true` when invoked on the same node.
  // TODO(brianwilkerson) Convert this to a getter.
  bool inSetterContext();
}

/// A string literal expression that does not contain any interpolations.
///
///    simpleStringLiteral ::=
///        rawStringLiteral
///      | basicStringLiteral
///
///    rawStringLiteral ::=
///        'r' basicStringLiteral
///
///    basicStringLiteral ::=
///        multiLineStringLiteral
///      | singleLineStringLiteral
///
///    multiLineStringLiteral ::=
///        "'''" characters "'''"
///      | '"""' characters '"""'
///
///    singleLineStringLiteral ::=
///        "'" characters "'"
///      | '"' characters '"'
///
/// Clients may not extend, implement or mix-in this class.
abstract class SimpleStringLiteral implements SingleStringLiteral {
  /// Return the token representing the literal.
  Token get literal;

  /// Return the value of the literal.
  String get value;
}

/// A single string literal expression.
///
///    singleStringLiteral ::=
///        [SimpleStringLiteral]
///      | [StringInterpolation]
///
/// Clients may not extend, implement or mix-in this class.
abstract class SingleStringLiteral implements StringLiteral {
  /// Return the offset of the after-last contents character.
  int get contentsEnd;

  /// Return the offset of the first contents character.
  ///
  /// If the string is multiline, then leading whitespaces are skipped.
  int get contentsOffset;

  /// Return `true` if this string literal is a multi-line string.
  bool get isMultiline;

  /// Return `true` if this string literal is a raw string.
  bool get isRaw;

  /// Return `true` if this string literal uses single quotes (' or '''), or
  /// `false` if this string literal uses double quotes (" or """).
  bool get isSingleQuoted;
}

/// A spread element.
///
///    spreadElement:
///        ( '...' | '...?' ) [Expression]
///
/// Clients may not extend, implement or mix-in this class.
abstract class SpreadElement implements CollectionElement {
  /// The expression used to compute the collection being spread.
  Expression get expression;

  /// Whether this is a null-aware spread, as opposed to a non-null spread.
  bool get isNullAware;

  /// The spread operator, either '...' or '...?'.
  Token get spreadOperator;
}

/// A node that represents a statement.
///
///    statement ::=
///        [Block]
///      | [VariableDeclarationStatement]
///      | [ForStatement]
///      | [ForEachStatement]
///      | [WhileStatement]
///      | [DoStatement]
///      | [SwitchStatement]
///      | [IfStatement]
///      | [TryStatement]
///      | [BreakStatement]
///      | [ContinueStatement]
///      | [ReturnStatement]
///      | [ExpressionStatement]
///      | [FunctionDeclarationStatement]
///
/// Clients may not extend, implement or mix-in this class.
abstract class Statement implements AstNode {
  /// If this is a labeled statement, return the unlabeled portion of the
  /// statement, otherwise return the statement itself.
  Statement get unlabeled;
}

/// A string interpolation literal.
///
///    stringInterpolation ::=
///        ''' [InterpolationElement]* '''
///      | '"' [InterpolationElement]* '"'
///
/// Clients may not extend, implement or mix-in this class.
abstract class StringInterpolation implements SingleStringLiteral {
  /// Return the elements that will be composed to produce the resulting string.
  /// The list includes [firstString] and [lastString].
  NodeList<InterpolationElement> get elements;

  /// Return the first element in this interpolation, which is always a string.
  /// The string might be empty if there is no text before the first
  /// interpolation expression (such as in `'$foo bar'`).
  InterpolationString get firstString;

  /// Return the last element in this interpolation, which is always a string.
  /// The string might be empty if there is no text after the last
  /// interpolation expression (such as in `'foo $bar'`).
  InterpolationString get lastString;
}

/// A string literal expression.
///
///    stringLiteral ::=
///        [SimpleStringLiteral]
///      | [AdjacentStrings]
///      | [StringInterpolation]
///
/// Clients may not extend, implement or mix-in this class.
abstract class StringLiteral implements Literal {
  /// Return the value of the string literal, or `null` if the string is not a
  /// constant string without any string interpolation.
  String? get stringValue;
}

/// A case in a switch statement.
///
///    switchCase ::=
///        [SimpleIdentifier]* 'case' [Expression] ':' [Statement]*
///
/// Clients may not extend, implement or mix-in this class.
abstract class SwitchCase implements SwitchMember {
  /// Return the expression controlling whether the statements will be executed.
  Expression get expression;
}

/// The default case in a switch statement.
///
///    switchDefault ::=
///        [SimpleIdentifier]* 'default' ':' [Statement]*
///
/// Clients may not extend, implement or mix-in this class.
abstract class SwitchDefault implements SwitchMember {}

/// An element within a switch statement.
///
///    switchMember ::=
///        switchCase
///      | switchDefault
///
/// Clients may not extend, implement or mix-in this class.
abstract class SwitchMember implements AstNode {
  /// Return the colon separating the keyword or the expression from the
  /// statements.
  Token get colon;

  /// Return the token representing the 'case' or 'default' keyword.
  Token get keyword;

  /// Return the labels associated with the switch member.
  NodeList<Label> get labels;

  /// Return the statements that will be executed if this switch member is
  /// selected.
  NodeList<Statement> get statements;
}

/// A switch statement.
///
///    switchStatement ::=
///        'switch' '(' [Expression] ')' '{' [SwitchCase]* [SwitchDefault]? '}'
///
/// Clients may not extend, implement or mix-in this class.
abstract class SwitchStatement implements Statement {
  /// Return the expression used to determine which of the switch members will
  /// be selected.
  Expression get expression;

  /// Return the left curly bracket.
  Token get leftBracket;

  /// Return the left parenthesis.
  Token get leftParenthesis;

  /// Return the switch members that can be selected by the expression.
  NodeList<SwitchMember> get members;

  /// Return the right curly bracket.
  Token get rightBracket;

  /// Return the right parenthesis.
  Token get rightParenthesis;

  /// Return the token representing the 'switch' keyword.
  Token get switchKeyword;
}

/// A symbol literal expression.
///
///    symbolLiteral ::=
///        '#' (operator | (identifier ('.' identifier)*))
///
/// Clients may not extend, implement or mix-in this class.
abstract class SymbolLiteral implements Literal {
  /// Return the components of the literal.
  List<Token> get components;

  /// Return the token introducing the literal.
  Token get poundSign;
}

/// A this expression.
///
///    thisExpression ::=
///        'this'
///
/// Clients may not extend, implement or mix-in this class.
abstract class ThisExpression implements Expression {
  /// Return the token representing the 'this' keyword.
  Token get thisKeyword;
}

/// A throw expression.
///
///    throwExpression ::=
///        'throw' [Expression]
///
/// Clients may not extend, implement or mix-in this class.
abstract class ThrowExpression implements Expression {
  /// Return the expression computing the exception to be thrown.
  Expression get expression;

  /// Return the token representing the 'throw' keyword.
  Token get throwKeyword;
}

/// The declaration of one or more top-level variables of the same type.
///
///    topLevelVariableDeclaration ::=
///        ('final' | 'const') <type>? <staticFinalDeclarationList> ';'
///      | 'late' 'final' <type>? <initializedIdentifierList> ';'
///      | 'late'? <varOrType> <initializedIdentifierList> ';'
///      | 'external' <finalVarOrType> <identifierList> ';'
///
/// (Note: there is no <topLevelVariableDeclaration> production in the grammar;
/// this is a subset of the grammar production <topLevelDeclaration>, which
/// encompasses everything that can appear inside a Dart file after part
/// directives).
///
/// Clients may not extend, implement or mix-in this class.
abstract class TopLevelVariableDeclaration implements CompilationUnitMember {
  /// The `external` keyword, or `null` if the keyword was not used.
  Token? get externalKeyword;

  /// Return the semicolon terminating the declaration.
  Token get semicolon;

  /// Return the top-level variables being declared.
  VariableDeclarationList get variables;
}

/// A try statement.
///
///    tryStatement ::=
///        'try' [Block] ([CatchClause]+ finallyClause? | finallyClause)
///
///    finallyClause ::=
///        'finally' [Block]
///
/// Clients may not extend, implement or mix-in this class.
abstract class TryStatement implements Statement {
  /// Return the body of the statement.
  Block get body;

  /// Return the catch clauses contained in the try statement.
  NodeList<CatchClause> get catchClauses;

  /// Return the finally block contained in the try statement, or `null` if the
  /// statement does not contain a finally clause.
  Block? get finallyBlock;

  /// Return the token representing the 'finally' keyword, or `null` if the
  /// statement does not contain a finally clause.
  Token? get finallyKeyword;

  /// Return the token representing the 'try' keyword.
  Token get tryKeyword;
}

/// The declaration of a type alias.
///
///    typeAlias ::=
///        'typedef' typeAliasBody
///
///    typeAliasBody ::=
///        classTypeAlias
///      | functionTypeAlias
///
/// Clients may not extend, implement or mix-in this class.
abstract class TypeAlias implements NamedCompilationUnitMember {
  @override
  SimpleIdentifier get name;

  /// Return the semicolon terminating the declaration.
  Token get semicolon;

  /// Return the token representing the 'typedef' keyword.
  Token get typedefKeyword;
}

/// A type annotation.
///
///    type ::=
///        [NamedType]
///      | [GenericFunctionType]
///
/// Clients may not extend, implement or mix-in this class.
abstract class TypeAnnotation implements AstNode {
  /// The question mark indicating that the type is nullable, or `null` if there
  /// is no question mark.
  Token? get question;

  /// Return the type being named, or `null` if the AST structure has not been
  /// resolved.
  DartType? get type;
}

/// A list of type arguments.
///
///    typeArguments ::=
///        '<' typeName (',' typeName)* '>'
///
/// Clients may not extend, implement or mix-in this class.
abstract class TypeArgumentList implements AstNode {
  /// Return the type arguments associated with the type.
  NodeList<TypeAnnotation> get arguments;

  /// Return the left bracket.
  Token get leftBracket;

  /// Return the right bracket.
  Token get rightBracket;
}

/// A literal that has a type associated with it.
///
///    typedLiteral ::=
///        [ListLiteral]
///      | [SetOrMapLiteral]
///
/// Clients may not extend, implement or mix-in this class.
abstract class TypedLiteral implements Literal {
  /// Return the token representing the 'const' keyword, or `null` if the
  /// literal is not a constant.
  Token? get constKeyword;

  /// Return `true` if this literal is a constant expression, either because the
  /// keyword `const` was explicitly provided or because no keyword was provided
  /// and this expression is in a constant context.
  bool get isConst;

  /// Return the type argument associated with this literal, or `null` if no
  /// type arguments were declared.
  TypeArgumentList? get typeArguments;
}

/// An expression representing a type, e.g. the expression `int` in
/// `var x = int;`.
///
/// Objects of this type are not produced directly by the parser (because the
/// parser cannot tell whether an identifier refers to a type); they are
/// produced at resolution time.
///
/// The `.staticType` getter returns the type of the expression (which will
/// always be the type `Type`).  To see the type represented by the type literal
/// use `.typeName.type`.
///
/// Clients may not extend, implement or mix-in this class.
abstract class TypeLiteral implements Expression, CommentReferableExpression {
  /// The type represented by this literal.
  NamedType get type;
}

/// A type parameter.
///
///    typeParameter ::=
///        [SimpleIdentifier] ('extends' [TypeAnnotation])?
///
/// Clients may not extend, implement or mix-in this class.
abstract class TypeParameter implements Declaration {
  /// Return the upper bound for legal arguments, or `null` if there is no
  /// explicit upper bound.
  TypeAnnotation? get bound;

  @override
  TypeParameterElement? get declaredElement;

  /// Return the token representing the 'extends' keyword, or `null` if there is
  /// no explicit upper bound.
  Token? get extendsKeyword;

  /// Return the name of the type parameter.
  SimpleIdentifier get name;
}

/// Type parameters within a declaration.
///
///    typeParameterList ::=
///        '<' [TypeParameter] (',' [TypeParameter])* '>'
///
/// Clients may not extend, implement or mix-in this class.
abstract class TypeParameterList implements AstNode {
  /// Return the left angle bracket.
  Token get leftBracket;

  /// Return the right angle bracket.
  Token get rightBracket;

  /// Return the type parameters for the type.
  NodeList<TypeParameter> get typeParameters;
}

/// An identifier that has an initial value associated with it.
///
/// Instances of this class are always children of the class
/// [VariableDeclarationList].
///
///    variableDeclaration ::=
///        [SimpleIdentifier] ('=' [Expression])?
///
/// Clients may not extend, implement or mix-in this class.
// TODO(paulberry): the grammar does not allow metadata to be associated with a
// VariableDeclaration, and currently we don't record comments for it either.
// Consider changing the class hierarchy so that [VariableDeclaration] does not
// extend [Declaration].
abstract class VariableDeclaration implements Declaration {
  @override
  VariableElement? get declaredElement;

  /// Return the equal sign separating the variable name from the initial value,
  /// or `null` if the initial value was not specified.
  Token? get equals;

  /// Return the expression used to compute the initial value for the variable,
  /// or `null` if the initial value was not specified.
  Expression? get initializer;

  /// Return the name of the variable being declared.
  SimpleIdentifier get name;
}

/// The declaration of one or more variables of the same type.
///
///    variableDeclarationList ::=
///        finalConstVarOrType [VariableDeclaration] (',' [VariableDeclaration])*
///
///    finalConstVarOrType ::=
///      'final' 'late'? [TypeAnnotation]?
///      | 'const' [TypeAnnotation]?
///      | 'var'
///      | 'late'? [TypeAnnotation]
///
/// Clients may not extend, implement or mix-in this class.
abstract class VariableDeclarationList implements AnnotatedNode {
  /// Return the token representing the 'final', 'const' or 'var' keyword, or
  /// `null` if no keyword was included.
  Token? get keyword;

  /// Return the type of the variables being declared, or `null` if no type was
  /// provided.
  TypeAnnotation? get type;

  /// Return a list containing the individual variables being declared.
  NodeList<VariableDeclaration> get variables;
}

/// A list of variables that are being declared in a context where a statement
/// is required.
///
///    variableDeclarationStatement ::=
///        [VariableDeclarationList] ';'
///
/// Clients may not extend, implement or mix-in this class.
abstract class VariableDeclarationStatement implements Statement {
  /// Return the semicolon terminating the statement.
  Token get semicolon;

  /// Return the variables being declared.
  VariableDeclarationList get variables;
}

/// A while statement.
///
///    whileStatement ::=
///        'while' '(' [Expression] ')' [Statement]
///
/// Clients may not extend, implement or mix-in this class.
abstract class WhileStatement implements Statement {
  /// Return the body of the loop.
  Statement get body;

  /// Return the expression used to determine whether to execute the body of the
  /// loop.
  Expression get condition;

  /// Return the left parenthesis.
  Token get leftParenthesis;

  /// Return the right parenthesis.
  Token get rightParenthesis;

  /// Return the token representing the 'while' keyword.
  Token get whileKeyword;
}
