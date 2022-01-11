// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartfx/src/lexer/tokens/error_token.dart';
import 'package:dartfx/src/lexer/tokens/token.dart';

import '../messages/codes.dart'
    show Message, MessageCode, templateExperimentNotEnabled;
import 'block_kind.dart';
import 'formal_parameter_kind.dart';
import 'identifier_context.dart';
import 'member_kind.dart';

abstract class UnescapeErrorListener {
  void handleUnescapeError(
      Message message, covariant location, int offset, int length);
}

/// A parser event listener that does nothing except throw exceptions
/// on parser errors.
///
/// Events are methods that begin with one of: `begin`, `end`, or `handle`.
///
/// Events starting with `begin` and `end` come in pairs. Normally, a
/// `beginFoo` event is followed by an `endFoo` event. There's a few exceptions
/// documented below.
///
/// Events starting with `handle` are used when isn't possible to have a begin
/// event.
class Listener implements UnescapeErrorListener {
  Uri? get uri => null;

  void logEvent(String name) {}

  void beginArguments(Token token) {}

  void endArguments(int count, Token beginToken, Token endToken) {
    logEvent("Arguments");
  }

  void beginBlock(Token token, BlockKind blockKind) {}

  void endBlock(
      int count, Token beginToken, Token endToken, BlockKind blockKind) {
    logEvent("Block");
  }

  /// Called to handle a block that has been parsed but is not associated
  /// with any top level function declaration. Substructures:
  /// - block
  void handleInvalidTopLevelBlock(Token token) {}

  void beginCaseExpression(Token caseKeyword) {}

  void endCaseExpression(Token colon) {
    logEvent("CaseExpression");
  }

  /// Begins a not-further-categorized top-level declaration.
  ///
  /// Ended by [endTopLevelDeclaration].
  void beginUncategorizedTopLevelDeclaration(Token token) {}

  void beginCombinators(Token token) {}

  void endCombinators(int count) {
    logEvent("Combinators");
  }

  void beginCompilationUnit(Token token) {}

  void endCompilationUnit(int count, Token token) {
    logEvent("CompilationUnit");
  }

  void beginConstLiteral(Token token) {}

  void endConstLiteral(Token token) {
    logEvent("ConstLiteral");
  }

  void beginDoWhileStatement(Token token) {}

  void endDoWhileStatement(
      Token doKeyword, Token whileKeyword, Token endToken) {
    logEvent("DoWhileStatement");
  }

  void beginDoWhileStatementBody(Token token) {}

  void endDoWhileStatementBody(Token token) {
    logEvent("DoWhileStatementBody");
  }

  void beginWhileStatementBody(Token token) {}

  void endWhileStatementBody(Token token) {
    logEvent("WhileStatementBody");
  }

  /// Called by [Parser] after parsing an extraneous expression as error
  /// recovery. For a stack-based listener, the suggested action is to discard
  /// an expression from the stack.
  void handleExtraneousExpression(Token token, Message message) {
    logEvent("ExtraneousExpression");
  }

  void handleExpressionStatement(Token token) {
    logEvent("ExpressionStatement");
  }

  void beginFormalParameter(Token token, MemberKind kind, Token? requiredToken,
      Token? covariantToken, Token? varFinalOrConst) {}

  void endFormalParameter(Token nameToken, Token? initializerStart,
      Token? initializerEnd, FormalParameterKind kind, MemberKind memberKind) {
    logEvent("FormalParameter");
  }

  void handleNoFormalParameters(Token token, MemberKind kind) {
    logEvent("NoFormalParameters");
  }

  void beginFormalParameters(Token token, MemberKind kind) {}

  void endFormalParameters(
      int count, Token beginToken, Token endToken, MemberKind kind) {
    logEvent("FormalParameters");
  }

  /// Marks that the grammar term `forInitializerStatement` has been parsed and
  /// it was an empty statement.
  void handleForInitializerEmptyStatement(Token token) {
    logEvent("ForInitializerEmptyStatement");
  }

  /// Marks that the grammar term `forInitializerStatement` has been parsed and
  /// it was an expression statement.
  void handleForInitializerExpressionStatement(Token token, bool forIn) {
    logEvent("ForInitializerExpressionStatement");
  }

  /// Marks that the grammar term `forInitializerStatement` has been parsed and
  /// it was a `localVariableDeclaration`.
  void handleForInitializerLocalVariableDeclaration(Token token, bool forIn) {
    logEvent("ForInitializerLocalVariableDeclaration");
  }

  /// Marks the start of a for statement which is ended by either
  /// [endForStatement] or [endForIn].
  void beginForStatement(Token token) {}

  /// Marks the end of parsing the control structure of a for statement
  /// or for control flow entry up to and including the closing parenthesis.
  /// `for` `(` initialization `;` condition `;` updaters `)`
  void handleForLoopParts(Token forKeyword, Token leftParen,
      Token leftSeparator, int updateExpressionCount) {}

  void endForStatement(Token endToken) {
    logEvent("ForStatement");
  }

  void beginForStatementBody(Token token) {}

  void endForStatementBody(Token token) {
    logEvent("ForStatementBody");
  }

  /// Marks the end of parsing the control structure of a for-in statement
  /// or for control flow entry up to and including the closing parenthesis.
  /// `for` `(` (type)? identifier `in` iterator `)`
  void handleForInLoopParts(Token? awaitToken, Token forToken,
      Token leftParenthesis, Token inKeyword) {}

  // One of the two possible corresponding end events for [beginForStatement].
  void endForIn(Token endToken) {
    logEvent("ForIn");
  }

  void beginForInExpression(Token token) {}

  void endForInExpression(Token token) {
    logEvent("ForInExpression");
  }

  void beginForInBody(Token token) {}

  void endForInBody(Token token) {
    logEvent("ForInBody");
  }

  /// Handle the beginning of a named function expression which isn't legal
  /// syntax in Dart.  Useful for recovering from Javascript code being pasted
  /// into a Dart program, as it will interpret `function foo() {}` as a named
  /// function expression with return type `function` and name `foo`.
  ///
  /// Substructures:
  /// - Type variables
  void beginNamedFunctionExpression(Token token) {}

  /// A named function expression which isn't legal syntax in Dart.
  /// Useful for recovering from Javascript code being pasted into a Dart
  /// program, as it will interpret `function foo() {}` as a named function
  /// expression with return type `function` and name `foo`.
  ///
  /// Substructures:
  /// - Type variables
  /// - Modifiers
  /// - Return type
  /// - Name
  /// - Formals
  /// - Initializers
  /// - Async modifier
  /// - Function body (block or arrow expression).
  void endNamedFunctionExpression(Token endToken) {
    logEvent("NamedFunctionExpression");
  }

  /// Handle the beginning of a local function declaration.  Substructures:
  /// - Metadata
  /// - Type variables
  void beginLocalFunctionDeclaration(Token token) {}

  /// A function declaration.
  ///
  /// Substructures:
  /// - Metadata
  /// - Type variables
  /// - Return type
  /// - Name
  /// - Type variables
  /// - Formals
  /// - Initializers
  /// - Async modifier
  /// - Function body (block or arrow expression).
  void endLocalFunctionDeclaration(Token endToken) {
    logEvent("FunctionDeclaration");
  }

  /// This method is invoked when the parser sees that a function has a
  /// block function body.  This method is not invoked for empty or expression
  /// function bodies, see the corresponding methods [handleEmptyFunctionBody]
  /// and [handleExpressionFunctionBody].
  void beginBlockFunctionBody(Token token) {}

  /// This method is invoked by the parser after it finished parsing a block
  /// function body.  This method is not invoked for empty or expression
  /// function bodies, see the corresponding methods [handleEmptyFunctionBody]
  /// and [handleExpressionFunctionBody].  The [beginToken] is the '{' token,
  /// and the [endToken] is the '}' token of the block.  The number of
  /// statements is given as the [count] parameter.
  void endBlockFunctionBody(int count, Token beginToken, Token endToken) {
    logEvent("BlockFunctionBody");
  }

  void handleNoFunctionBody(Token token) {
    logEvent("NoFunctionBody");
  }

  /// Handle the end of a function body that was skipped by the parser.
  ///
  /// The boolean [isExpressionBody] indicates whether the function body that
  /// was skipped used "=>" syntax.
  void handleFunctionBodySkipped(Token token, bool isExpressionBody) {}

  void beginFunctionName(Token token) {}

  void endFunctionName(Token beginToken, Token token) {
    logEvent("FunctionName");
  }

  void handleIdentifierList(int count) {
    logEvent("IdentifierList");
  }

  void beginTypeList(Token token) {}

  void endTypeList(int count) {
    logEvent("TypeList");
  }

  void beginIfStatement(Token token) {}

  void endIfStatement(Token ifToken, Token? elseToken) {
    logEvent("IfStatement");
  }

  void beginThenStatement(Token token) {}

  void endThenStatement(Token token) {
    logEvent("ThenStatement");
  }

  void beginElseStatement(Token token) {}

  void endElseStatement(Token token) {
    logEvent("ElseStatement");
  }

  void handleDottedName(int count, Token firstIdentifier) {
    logEvent("DottedName");
  }

  void beginInitializedIdentifier(Token token) {}

  void endInitializedIdentifier(Token nameToken) {
    logEvent("InitializedIdentifier");
  }

  void beginVariableInitializer(Token token) {}

  /// Handle the end of a variable initializer. Substructures:
  /// - Initializer expression.
  void endVariableInitializer(Token assignmentOperator) {
    logEvent("VariableInitializer");
  }

  /// Used when a variable has no initializer.
  void handleNoVariableInitializer(Token token) {
    logEvent("NoVariableInitializer");
  }

  void beginInitializer(Token token) {}

  void endInitializer(Token token) {
    logEvent("ConstructorInitializer");
  }

  void handleNoInitializers() {
    logEvent("NoInitializers");
  }

  /// Called after the listener has recovered from an invalid expression. The
  /// parser will resume parsing from [token]. Exactly where the parser will
  /// resume parsing is unspecified.
  void handleInvalidExpression(Token token) {
    logEvent("InvalidExpression");
  }

  /// Called after the listener has recovered from an invalid function
  /// body. The parser expected an open curly brace `{` and will resume parsing
  /// from [token] as if a function body had preceded it.
  void handleInvalidFunctionBody(Token token) {
    logEvent("InvalidFunctionBody");
  }

  /// Called after the listener has recovered from an invalid type. The parser
  /// expected an identifier, and will resume parsing type arguments from
  /// [token].
  void handleInvalidTypeReference(Token token) {
    logEvent("InvalidTypeReference");
  }

  void handleLabel(Token token) {
    logEvent("Label");
  }

  void beginLabeledStatement(Token token, int labelCount) {}

  void endLabeledStatement(int labelCount) {
    logEvent("LabeledStatement");
  }

  void handleLiteralMapEntry(Token colon, Token endToken) {
    logEvent("LiteralMapEntry");
  }

  void beginLiteralString(Token token) {}

  void handleInterpolationExpression(Token leftBracket, Token? rightBracket) {}

  void endLiteralString(int interpolationCount, Token endToken) {
    logEvent("LiteralString");
  }

  void handleStringJuxtaposition(Token startToken, int literalCount) {
    logEvent("StringJuxtaposition");
  }

  /// Called for class-like members (class, mixin, extension), but each member
  /// should also have a more specific begin/end pair, e.g.
  /// [beginFactoryMethod]/[endClassFactoryMethod]/[endMixinFactoryMethod]/
  /// [endExtensionFactoryMethod].
  void beginMember() {}

  /// Handle an invalid member declaration. Substructures:
  /// - metadata
  void handleInvalidMember(Token endToken) {
    logEvent("InvalidMember");
  }

  /// This event is added for convenience to the listener.
  /// Members will actually be begin/end'ed by more specific
  /// events as well.
  /// Normally listeners should probably override
  /// [endClassFields], [endMixinFields], [endExtensionFields],
  /// [endClassMethod], [endMixinMethod], [endExtensionMethod],
  /// [endClassConstructor], [endMixinConstructor],
  /// or [endExtensionConstructor] instead.
  void endMember() {
    logEvent("Member");
  }

  void beginOptionalFormalParameters(Token token) {}

  void endOptionalFormalParameters(
      int count, Token beginToken, Token endToken) {
    logEvent("OptionalFormalParameters");
  }

  void beginReturnStatement(Token token) {}

  /// This method is invoked when a function has the empty body.
  void handleEmptyFunctionBody(Token semicolon) {
    logEvent("EmptyFunctionBody");
  }

  /// This method is invoked when parser finishes parsing the corresponding
  /// expression of the expression function body.
  void handleExpressionFunctionBody(Token arrowToken, Token? endToken) {
    logEvent("ExpressionFunctionBody");
  }

  void endReturnStatement(
      bool hasExpression, Token beginToken, Token endToken) {
    logEvent("ReturnStatement");
  }

  void handleSend(Token beginToken, Token endToken) {
    logEvent("Send");
  }

  void beginSwitchStatement(Token token) {}

  void endSwitchStatement(Token switchKeyword, Token endToken) {
    logEvent("SwitchStatement");
  }

  void beginSwitchBlock(Token token) {}

  void endSwitchBlock(int caseCount, Token beginToken, Token endToken) {
    logEvent("SwitchBlock");
  }

  void beginLiteralSymbol(Token token) {}

  void endLiteralSymbol(Token hashToken, int identifierCount) {
    logEvent("LiteralSymbol");
  }

  void beginProgram(Token token) {}

  void endProgram(Token endToken) {
    logEvent("Program");
  }

  /// This event is added for convenience for the listener.
  /// All top-level declarations will actually be begin/end'ed by more specific
  /// events as well, e.g. [beginClassDeclaration]/[endClassDeclaration],
  /// [beginEnum]/[endEnum] etc.
  ///
  /// Normally listeners should probably override
  /// [endClassDeclaration], [endNamedMixinApplication], [endEnum],
  /// [endTypedef], [endLibraryName], [endImport], [endExport],
  /// [endPart], [endPartOf], [endTopLevelFields], or [endTopLevelMethod]
  /// instead.
  ///
  /// Started by one of [beginExtensionDeclarationPrelude],
  /// [beginClassOrMixinOrNamedMixinApplicationPrelude], [beginTopLevelMember]
  /// or [beginUncategorizedTopLevelDeclaration].
  void endTopLevelDeclaration(Token nextToken) {
    logEvent("TopLevelDeclaration");
  }

  /// Called by the [Parser] when it recovers from an invalid top level
  /// declaration, where [endToken] is the last token in the declaration
  /// This is called after the begin/end metadata star events,
  /// and is followed by [endTopLevelDeclaration].
  ///
  /// Substructures:
  /// - metadata
  void handleInvalidTopLevelDeclaration(Token endToken) {
    logEvent("InvalidTopLevelDeclaration");
  }

  /// Marks the beginning of a top level field or method declaration.
  /// See also [endTopLevelFields] and [endTopLevelMethod].
  ///
  /// Ended by [endTopLevelDeclaration].
  void beginTopLevelMember(Token token) {}

  /// Marks the beginning of a fields declaration.
  /// Note that this is ended with [endTopLevelFields], [endClassFields],
  /// [endMixinFields] or [endExtensionFields].
  void beginFields(Token? varFinalOrConst, Token lastConsumed) {}

  /// Handle the end of a top level variable declaration.  Substructures:
  /// - Metadata
  /// - Type
  /// - Repeated [count] times:
  ///   - Variable name (identifier)
  ///   - Field initializer
  ///
  /// Started by [beginFields].
  void endTopLevelFields(
      Token? varFinalOrConst, int count, Token beginToken, Token endToken) {
    logEvent("TopLevelFields");
  }

  void beginTopLevelMethod(Token lastConsumed, Token? externalToken) {}

  /// Handle the end of a top level method.  Substructures:
  /// - metadata
  /// - modifiers
  /// - return type
  /// - identifier
  /// - type variables
  /// - formal parameters
  /// - async marker
  /// - body
  void endTopLevelMethod(Token beginToken, Token endToken) {
    logEvent("TopLevelMethod");
  }

  void handleCaseMatch(Token caseKeyword, Token colon) {
    logEvent("CaseMatch");
  }

  void handleType(Token beginToken, Token? questionMark) {
    logEvent("Type");
  }

  void handleNoName(Token token) {
    logEvent("NoName");
  }

  void beginFunctionType(Token beginToken) {}

  /// Handle the end of a generic function type declaration.
  ///
  /// Substructures:
  /// - Type variables
  /// - Return type
  /// - Formal parameters
  void endFunctionType(Token functionToken, Token? questionMark) {
    logEvent("FunctionType");
  }

  void beginTypeArguments(Token token) {}

  void endTypeArguments(int count, Token beginToken, Token endToken) {
    logEvent("TypeArguments");
  }

  /// After endTypeArguments has been called,
  /// this event is called if those type arguments are invalid.
  void handleInvalidTypeArguments(Token token) {
    logEvent("NoTypeArguments");
  }

  void handleNoTypeArguments(Token token) {
    logEvent("NoTypeArguments");
  }

  /// Handle the begin of a type formal parameter (e.g. "X extends Y").
  /// Substructures:
  /// - Metadata
  /// - Name (identifier)
  void beginTypeVariable(Token token) {}

  /// Called when [beginTypeVariable] has been called for all of the variables
  /// in a group, and before [endTypeVariable] has been called for any of the
  /// variables in that same group.
  void handleTypeVariablesDefined(Token token, int count) {}

  /// Handle the end of a type formal parameter (e.g. "X extends Y")
  /// where [index] is the index of the type variable in the list of
  /// type variables being declared.
  ///
  /// Substructures:
  /// - Type bound
  ///
  /// See [beginTypeVariable] for additional substructures.
  void endTypeVariable(
      Token token, int index, Token? extendsOrSuper, Token? variance) {
    logEvent("TypeVariable");
  }

  void beginTypeVariables(Token token) {}

  void endTypeVariables(Token beginToken, Token endToken) {
    logEvent("TypeVariables");
  }

  void beginFunctionExpression(Token token) {}

  /// Handle the end of a function expression (e.g. "() { ... }").
  /// Substructures:
  /// - Type variables
  /// - Formal parameters
  /// - Async marker
  /// - Body
  void endFunctionExpression(Token beginToken, Token token) {
    logEvent("FunctionExpression");
  }

  /// Handle the start of a variables declaration.  Substructures:
  /// - Metadata
  /// - Type
  void beginVariablesDeclaration(Token token, Token? varFinalOrConst) {}

  void endVariablesDeclaration(int count, Token? endToken) {
    logEvent("VariablesDeclaration");
  }

  void beginWhileStatement(Token token) {}

  void endWhileStatement(Token whileKeyword, Token endToken) {
    logEvent("WhileStatement");
  }

  void handleAssignmentExpression(Token token) {
    logEvent("AssignmentExpression");
  }

  /// Called when the parser encounters a binary operator, in between the LHS
  /// and RHS subexpressions.
  ///
  /// Not called when the binary operator is `.`, `?.`, or `..`.
  void beginBinaryExpression(Token token) {}

  void endBinaryExpression(Token token) {
    logEvent("BinaryExpression");
  }

  /// Called for `.`, `?.` and `..`.
  void handleEndingBinaryExpression(Token token) {
    // TODO(jensj): push implementation into subclasses
    endBinaryExpression(token);
  }

  /// Called when the parser encounters a `?` operator and begins parsing a
  /// conditional expression.
  void beginConditionalExpression(Token question) {}

  /// Called when the parser encounters a `:` operator in a conditional
  /// expression.
  void handleConditionalExpressionColon() {}

  /// Called when the parser finishes processing a conditional expression.
  void endConditionalExpression(Token question, Token colon) {
    logEvent("ConditionalExpression");
  }

  /// Called before parsing a "for" control flow list, set, or map entry.
  /// Ended by either [endForControlFlow] or [endForInControlFlow].
  void beginForControlFlow(Token? awaitToken, Token forToken) {}

  /// Called after parsing a "for" control flow list, set, or map entry.
  /// One of the two possible corresponding end events for
  /// [beginForControlFlow].
  void endForControlFlow(Token token) {
    logEvent('endForControlFlow');
  }

  /// Called after parsing a "for-in" control flow list, set, or map entry.
  /// One of the two possible corresponding end events for
  /// [beginForControlFlow].
  void endForInControlFlow(Token token) {
    logEvent('endForInControlFlow');
  }

  /// Called before parsing an `if` control flow list, set, or map entry.
  /// Ended by either [endIfControlFlow] or [endIfElseControlFlow].
  void beginIfControlFlow(Token ifToken) {}

  /// Called before parsing the `then` portion of an `if` control flow list,
  /// set, or map entry.
  void handleThenControlFlow(Token token) {}

  /// Called before parsing the `else` portion of an `if` control flow list,
  /// set, or map entry.
  void handleElseControlFlow(Token elseToken) {
    logEvent("ElseControlFlow");
  }

  /// Called after parsing an `if` control flow list, set, or map entry.
  /// Substructures:
  /// - if conditional expression
  /// - expression
  /// One of the two possible corresponding end events for
  /// [beginIfControlFlow].
  void endIfControlFlow(Token token) {
    logEvent("endIfControlFlow");
  }

  /// Called after parsing an if-else control flow list, set, or map entry.
  /// Substructures:
  /// - if conditional expression
  /// - then expression
  /// - else expression
  /// One of the two possible corresponding end events for
  /// [beginIfControlFlow].
  void endIfElseControlFlow(Token token) {
    logEvent("endIfElseControlFlow");
  }

  /// Handle the start of a function typed formal parameter.  Substructures:
  /// - type variables
  void beginFunctionTypedFormalParameter(Token token) {}

  /// Handle the end of a function typed formal parameter.  Substructures:
  /// - type variables
  /// - return type
  /// - formal parameters
  void endFunctionTypedFormalParameter(Token nameToken, Token? question) {
    logEvent("FunctionTypedFormalParameter");
  }

  /// Handle an identifier token.
  ///
  /// [context] indicates what kind of construct the identifier appears in.
  void handleIdentifier(Token token, IdentifierContext context) {
    logEvent("Identifier");
  }

  void handleIndexedExpression(
      Token? question, Token openSquareBracket, Token closeSquareBracket) {
    logEvent("IndexedExpression");
  }

  void handleLiteralBool(Token token) {
    logEvent("LiteralBool");
  }

  void handleBreakStatement(
      bool hasTarget, Token breakKeyword, Token endToken) {
    logEvent("BreakStatement");
  }

  void handleContinueStatement(
      bool hasTarget, Token continueKeyword, Token endToken) {
    logEvent("ContinueStatement");
  }

  void handleEmptyStatement(Token token) {
    logEvent("EmptyStatement");
  }

  /** Called with either the token containing a double literal, or
    * an immediately preceding "unary plus" token.
    */
  void handleLiteralDouble(Token token) {
    logEvent("LiteralDouble");
  }

  /** Called with either the token containing an integer literal,
    * or an immediately preceding "unary plus" token.
    */
  void handleLiteralInt(Token token) {
    logEvent("LiteralInt");
  }

  void handleLiteralList(
      int count, Token leftBracket, Token? constKeyword, Token rightBracket) {
    logEvent("LiteralList");
  }

  void handleLiteralSetOrMap(
    int count,
    Token leftBrace,
    Token? constKeyword,
    Token rightBrace,
    // TODO(danrubel): hasSetEntry parameter exists for replicating existing
    // behavior and will be removed once unified collection has been enabled
    bool hasSetEntry,
  ) {
    logEvent('LiteralSetOrMap');
  }

  void handleLiteralNull(Token token) {
    logEvent("LiteralNull");
  }

  void handleNamedArgument(Token colon) {
    logEvent("NamedArgument");
  }

  void handleNoArguments(Token token) {
    logEvent("NoArguments");
  }

  void handleNoType(Token lastConsumed) {
    logEvent("NoType");
  }

  void handleNoTypeVariables(Token token) {
    logEvent("NoTypeVariables");
  }

  void handleSymbolVoid(Token token) {
    logEvent("SymbolVoid");
  }

  /// Handle the end of a construct of the form "operator <token>".
  void handleOperatorName(Token operatorKeyword, Token token) {
    logEvent("OperatorName");
  }

  /// Handle the end of a construct of the form "operator <token>"
  /// where <token> is not a valid operator token.
  void handleInvalidOperatorName(Token operatorKeyword, Token token) {
    logEvent("InvalidOperatorName");
  }

  /// Handle the condition in a control structure:
  /// - if statement
  /// - do while loop
  /// - switch statement
  /// - while loop
  void handleParenthesizedCondition(Token token) {
    logEvent("ParenthesizedCondition");
  }

  /// Handle a parenthesized expression.
  /// These may be within the condition expression of a control structure
  /// but will not be the condition of a control structure.
  void handleParenthesizedExpression(Token token) {
    logEvent("ParenthesizedExpression");
  }

  /// Handle a construct of the form "identifier.identifier" occurring in a part
  /// of the grammar where expressions in general are not allowed.
  /// Substructures:
  /// - Qualified identifier (before the period)
  /// - Identifier (after the period)
  void handleQualified(Token period) {
    logEvent("Qualified");
  }

  void handleStringPart(Token token) {
    logEvent("StringPart");
  }

  void beginSwitchCase(int labelCount, int expressionCount, Token firstToken) {}

  void endSwitchCase(
      int labelCount,
      int expressionCount,
      Token? defaultKeyword,
      Token? colonAfterDefault,
      int statementCount,
      Token firstToken,
      Token endToken) {
    logEvent("SwitchCase");
  }

  void handleUnaryPostfixAssignmentExpression(Token token) {
    logEvent("UnaryPostfixAssignmentExpression");
  }

  void handleUnaryPrefixExpression(Token token) {
    logEvent("UnaryPrefixExpression");
  }

  void handleUnaryPrefixAssignmentExpression(Token token) {
    logEvent("UnaryPrefixAssignmentExpression");
  }

  void beginFormalParameterDefaultValueExpression() {}

  void endFormalParameterDefaultValueExpression() {
    logEvent("FormalParameterDefaultValueExpression");
  }

  void handleValuedFormalParameter(Token equals, Token token) {
    logEvent("ValuedFormalParameter");
  }

  void handleFormalParameterWithoutValue(Token token) {
    logEvent("FormalParameterWithoutValue");
  }

  /// The parser noticed a syntax error, but was able to recover from it. The
  /// error should be reported using the [message], and the code between the
  /// beginning of the [startToken] and the end of the [endToken] should be
  /// highlighted. The [startToken] and [endToken] can be the same token.
  void handleRecoverableError(
      Message message, Token startToken, Token endToken) {}

  /// The parser encountered an [ErrorToken] representing an error
  /// from the scanner but recovered from it. By default, the error is reported
  /// by calling [handleRecoverableError] with the message associated
  /// with the error [token].
  void handleErrorToken(ErrorToken token) {
    handleRecoverableError(token.assertionMessage, token, token);
  }

  @override
  void handleUnescapeError(
      Message message, Token location, int stringOffset, int length) {
    handleRecoverableError(message, location, location);
  }

  /// Signals to the listener that the previous statement contained a semantic
  /// error (described by the given [message]). This method can also be called
  /// after [handleExpressionFunctionBody], in which case it signals that the
  /// implicit return statement of the function contained a semantic error.
  void handleInvalidStatement(Token token, Message message) {
    handleRecoverableError(message, token, token);
  }

  /// A single comment reference has been found
  /// where [referenceSource] is the text between the `[` and `]`
  /// and [referenceOffset] is the character offset in the token stream.
  ///
  /// This event is generated by the parser when the parser's
  /// `parseCommentReferences` method is called. For further processing,
  /// a listener may scan the [referenceSource] and then pass the resulting
  /// token stream to the parser's `parseOneCommentReference` method.
  void handleCommentReferenceText(String referenceSource, int referenceOffset) {
    logEvent("CommentReferenceText");
  }

  /// A single comment reference has been parsed.
  /// * [newKeyword] may be null.
  /// * [firstToken] and [firstPeriod] are either both tokens or both
  ///   `null`.
  /// * [secondToken] and [secondPeriod] are either both tokens or both `null`.
  /// * [thirdToken] can be an identifier or an operator.
  ///
  /// This event is generated by the parser when the parser's
  /// `parseOneCommentReference` method is called.
  void handleCommentReference(
      Token? newKeyword,
      Token? firstToken,
      Token? firstPeriod,
      Token? secondToken,
      Token? secondPeriod,
      Token thirdToken) {}

  /// This event is generated by the parser when the parser's
  /// `parseOneCommentReference` method is called.
  void handleNoCommentReference() {}

  /// An expression was encountered consisting of type arguments applied to a
  /// subexpression.  This could validly represent any of the following:
  /// - A type literal (`var x = List<int>;`)
  /// - A function tear-off with type arguments (`var x = f<int>;` or
  ///   `var x = importPrefix.f<int>;`)
  /// - A static method tear-off with type arguments (`var x = ClassName.m<int>`
  ///   or `var x = importPrefix.ClassName.m<int>;`)
  /// - An instance method tear-off with type arguments (`var x = EXPR.m<int>;`)
  ///
  /// Or, in the event of invalid code, it could represent type arguments
  /// erroneously applied to some other expression type (e.g.
  /// `var x = (f)<int>;`).  The client is responsible for reporting an error if
  /// this occurs.
  void handleTypeArgumentApplication(Token openAngleBracket) {}
}
