// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Modified by the dartfx project authors.
// Copyright (c) 2022, the dartfx project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartfx/src/lexer/tokens/error_token.dart';
import 'package:dartfx/src/lexer/tokens/token.dart';
import 'package:dartfx/src/parser/formal_parameter_kind.dart';

import '../messages/codes.dart';
import 'block_kind.dart';
import 'identifier_context.dart';
import 'listener.dart';
import 'member_kind.dart';

class ForwardingListener implements Listener {
  Listener? listener;
  bool forwardErrors = true;

  ForwardingListener([this.listener]);

  @override
  Uri? get uri => listener?.uri;

  @override
  void beginArguments(Token token) {
    listener?.beginArguments(token);
  }

  @override
  void beginBinaryExpression(Token token) {
    listener?.beginBinaryExpression(token);
  }

  @override
  void beginBlock(Token token, BlockKind blockKind) {
    listener?.beginBlock(token, blockKind);
  }

  @override
  void beginBlockFunctionBody(Token token) {
    listener?.beginBlockFunctionBody(token);
  }

  @override
  void beginCaseExpression(Token caseKeyword) {
    listener?.beginCaseExpression(caseKeyword);
  }

  @override
  void beginCombinators(Token token) {
    listener?.beginCombinators(token);
  }

  @override
  void beginCompilationUnit(Token token) {
    listener?.beginCompilationUnit(token);
  }

  @override
  void beginConditionalExpression(Token question) {
    listener?.beginConditionalExpression(question);
  }

  @override
  void beginConstLiteral(Token token) {
    listener?.beginConstLiteral(token);
  }

  @override
  void beginDoWhileStatement(Token token) {
    listener?.beginDoWhileStatement(token);
  }

  @override
  void beginDoWhileStatementBody(Token token) {
    listener?.beginDoWhileStatementBody(token);
  }

  @override
  void beginElseStatement(Token token) {
    listener?.beginElseStatement(token);
  }

  @override
  void beginUncategorizedTopLevelDeclaration(Token token) {
    listener?.beginUncategorizedTopLevelDeclaration(token);
  }

  @override
  void beginForControlFlow(Token? awaitToken, Token forToken) {
    listener?.beginForControlFlow(awaitToken, forToken);
  }

  @override
  void beginForInBody(Token token) {
    listener?.beginForInBody(token);
  }

  @override
  void beginForInExpression(Token token) {
    listener?.beginForInExpression(token);
  }

  @override
  void beginFormalParameter(Token token, MemberKind kind, Token? requiredToken,
      Token? covariantToken, Token? varFinalOrConst) {
    listener?.beginFormalParameter(
        token, kind, requiredToken, covariantToken, varFinalOrConst);
  }

  @override
  void beginFormalParameterDefaultValueExpression() {
    listener?.beginFormalParameterDefaultValueExpression();
  }

  @override
  void beginFormalParameters(Token token, MemberKind kind) {
    listener?.beginFormalParameters(token, kind);
  }

  @override
  void beginForStatement(Token token) {
    listener?.beginForStatement(token);
  }

  @override
  void beginForStatementBody(Token token) {
    listener?.beginForStatementBody(token);
  }

  @override
  void beginFunctionExpression(Token token) {
    listener?.beginFunctionExpression(token);
  }

  @override
  void beginFunctionName(Token token) {
    listener?.beginFunctionName(token);
  }

  @override
  void beginFunctionType(Token beginToken) {
    listener?.beginFunctionType(beginToken);
  }

  @override
  void beginFunctionTypedFormalParameter(Token token) {
    listener?.beginFunctionTypedFormalParameter(token);
  }

  @override
  void beginIfControlFlow(Token ifToken) {
    listener?.beginIfControlFlow(ifToken);
  }

  @override
  void beginIfStatement(Token token) {
    listener?.beginIfStatement(token);
  }

  @override
  void beginLabeledStatement(Token token, int labelCount) {
    listener?.beginLabeledStatement(token, labelCount);
  }

  @override
  void beginLiteralString(Token token) {
    listener?.beginLiteralString(token);
  }

  @override
  void beginLiteralSymbol(Token token) {
    listener?.beginLiteralSymbol(token);
  }

  @override
  void beginLocalFunctionDeclaration(Token token) {
    listener?.beginLocalFunctionDeclaration(token);
  }

  @override
  void beginMember() {
    listener?.beginMember();
  }

  @override
  void beginNamedFunctionExpression(Token token) {
    listener?.beginNamedFunctionExpression(token);
  }

  @override
  void beginOptionalFormalParameters(Token token) {
    listener?.beginOptionalFormalParameters(token);
  }

  @override
  void beginProgram(Token token) {
    listener?.beginProgram(token);
  }

  @override
  void beginReturnStatement(Token token) {
    listener?.beginReturnStatement(token);
  }

  @override
  void beginSwitchBlock(Token token) {
    listener?.beginSwitchBlock(token);
  }

  @override
  void beginSwitchCase(int labelCount, int expressionCount, Token firstToken) {
    listener?.beginSwitchCase(labelCount, expressionCount, firstToken);
  }

  @override
  void beginSwitchStatement(Token token) {
    listener?.beginSwitchStatement(token);
  }

  @override
  void handleThenControlFlow(Token token) {
    listener?.handleThenControlFlow(token);
  }

  @override
  void beginThenStatement(Token token) {
    listener?.beginThenStatement(token);
  }

  @override
  void beginTypeArguments(Token token) {
    listener?.beginTypeArguments(token);
  }

  @override
  void beginTypeList(Token token) {
    listener?.beginTypeList(token);
  }

  @override
  void beginTypeVariable(Token token) {
    listener?.beginTypeVariable(token);
  }

  @override
  void beginTypeVariables(Token token) {
    listener?.beginTypeVariables(token);
  }

  @override
  void beginVariableInitializer(Token token) {
    listener?.beginVariableInitializer(token);
  }

  @override
  void beginWhileStatement(Token token) {
    listener?.beginWhileStatement(token);
  }

  @override
  void beginWhileStatementBody(Token token) {
    listener?.beginWhileStatementBody(token);
  }

  @override
  void endArguments(int count, Token beginToken, Token endToken) {
    listener?.endArguments(count, beginToken, endToken);
  }

  @override
  void endBinaryExpression(Token token) {
    listener?.endBinaryExpression(token);
  }

  @override
  void handleEndingBinaryExpression(Token token) {
    listener?.handleEndingBinaryExpression(token);
  }

  @override
  void endBlock(
      int count, Token beginToken, Token endToken, BlockKind blockKind) {
    listener?.endBlock(count, beginToken, endToken, blockKind);
  }

  @override
  void endBlockFunctionBody(int count, Token beginToken, Token endToken) {
    listener?.endBlockFunctionBody(count, beginToken, endToken);
  }

  @override
  void endCaseExpression(Token colon) {
    listener?.endCaseExpression(colon);
  }

  @override
  void endCombinators(int count) {
    listener?.endCombinators(count);
  }

  @override
  void endCompilationUnit(int count, Token token) {
    listener?.endCompilationUnit(count, token);
  }

  @override
  void endConditionalExpression(Token question, Token colon) {
    listener?.endConditionalExpression(question, colon);
  }

  @override
  void endConstLiteral(Token token) {
    listener?.endConstLiteral(token);
  }

  @override
  void endDoWhileStatement(
      Token doKeyword, Token whileKeyword, Token endToken) {
    listener?.endDoWhileStatement(doKeyword, whileKeyword, endToken);
  }

  @override
  void endDoWhileStatementBody(Token token) {
    listener?.endDoWhileStatementBody(token);
  }

  @override
  void endElseStatement(Token token) {
    listener?.endElseStatement(token);
  }

  @override
  void endForControlFlow(Token token) {
    listener?.endForControlFlow(token);
  }

  @override
  void endForIn(Token endToken) {
    listener?.endForIn(endToken);
  }

  @override
  void endForInBody(Token token) {
    listener?.endForInBody(token);
  }

  @override
  void endForInControlFlow(Token token) {
    listener?.endForInControlFlow(token);
  }

  @override
  void endForInExpression(Token token) {
    listener?.endForInExpression(token);
  }

  @override
  void endFormalParameterDefaultValueExpression() {
    listener?.endFormalParameterDefaultValueExpression();
  }

  @override
  void endFormalParameters(
      int count, Token beginToken, Token endToken, MemberKind kind) {
    listener?.endFormalParameters(count, beginToken, endToken, kind);
  }

  @override
  void endForStatement(Token endToken) {
    listener?.endForStatement(endToken);
  }

  @override
  void endForStatementBody(Token token) {
    listener?.endForStatementBody(token);
  }

  @override
  void endFunctionExpression(Token beginToken, Token token) {
    listener?.endFunctionExpression(beginToken, token);
  }

  @override
  void endFunctionName(Token beginToken, Token token) {
    listener?.endFunctionName(beginToken, token);
  }

  @override
  void endFunctionType(Token functionToken, Token? questionMark) {
    listener?.endFunctionType(functionToken, questionMark);
  }

  @override
  void endFunctionTypedFormalParameter(Token nameToken, Token? question) {
    listener?.endFunctionTypedFormalParameter(nameToken, question);
  }

  @override
  void handleTypeArgumentApplication(Token openAngleBracket) {
    listener?.handleTypeArgumentApplication(openAngleBracket);
  }

  @override
  void endIfControlFlow(Token token) {
    listener?.endIfControlFlow(token);
  }

  @override
  void endIfElseControlFlow(Token token) {
    listener?.endIfElseControlFlow(token);
  }

  @override
  void endIfStatement(Token ifToken, Token? elseToken) {
    listener?.endIfStatement(ifToken, elseToken);
  }

  @override
  void endLabeledStatement(int labelCount) {
    listener?.endLabeledStatement(labelCount);
  }

  @override
  void endLiteralString(int interpolationCount, Token endToken) {
    listener?.endLiteralString(interpolationCount, endToken);
  }

  @override
  void endLiteralSymbol(Token hashToken, int identifierCount) {
    listener?.endLiteralSymbol(hashToken, identifierCount);
  }

  @override
  void endLocalFunctionDeclaration(Token endToken) {
    listener?.endLocalFunctionDeclaration(endToken);
  }

  @override
  void endMember() {
    listener?.endMember();
  }

  @override
  void endNamedFunctionExpression(Token endToken) {
    listener?.endNamedFunctionExpression(endToken);
  }

  @override
  void endOptionalFormalParameters(
      int count, Token beginToken, Token endToken) {
    listener?.endOptionalFormalParameters(count, beginToken, endToken);
  }

  @override
  void endProgram(Token endToken) {
    listener?.endProgram(endToken);
  }

  @override
  void endReturnStatement(
      bool hasExpression, Token beginToken, Token endToken) {
    listener?.endReturnStatement(hasExpression, beginToken, endToken);
  }

  @override
  void endSwitchBlock(int caseCount, Token beginToken, Token endToken) {
    listener?.endSwitchBlock(caseCount, beginToken, endToken);
  }

  @override
  void endSwitchCase(
      int labelCount,
      int expressionCount,
      Token? defaultKeyword,
      Token? colonAfterDefault,
      int statementCount,
      Token firstToken,
      Token endToken) {
    listener?.endSwitchCase(labelCount, expressionCount, defaultKeyword,
        colonAfterDefault, statementCount, firstToken, endToken);
  }

  @override
  void endSwitchStatement(Token switchKeyword, Token endToken) {
    listener?.endSwitchStatement(switchKeyword, endToken);
  }

  @override
  void endThenStatement(Token token) {
    listener?.endThenStatement(token);
  }

  @override
  void endTopLevelDeclaration(Token nextToken) {
    listener?.endTopLevelDeclaration(nextToken);
  }

  @override
  void endTypeArguments(int count, Token beginToken, Token endToken) {
    listener?.endTypeArguments(count, beginToken, endToken);
  }

  @override
  void endTypeList(int count) {
    listener?.endTypeList(count);
  }

  @override
  void endTypeVariable(
      Token token, int index, Token? extendsOrSuper, Token? variance) {
    listener?.endTypeVariable(token, index, extendsOrSuper, variance);
  }

  @override
  void endTypeVariables(Token beginToken, Token endToken) {
    listener?.endTypeVariables(beginToken, endToken);
  }

  @override
  void endVariableInitializer(Token assignmentOperator) {
    listener?.endVariableInitializer(assignmentOperator);
  }

  @override
  void endVariablesDeclaration(int count, Token? endToken) {
    listener?.endVariablesDeclaration(count, endToken);
  }

  @override
  void endWhileStatement(Token whileKeyword, Token endToken) {
    listener?.endWhileStatement(whileKeyword, endToken);
  }

  @override
  void endWhileStatementBody(Token token) {
    listener?.endWhileStatementBody(token);
  }

  @override
  void handleAssignmentExpression(Token token) {
    listener?.handleAssignmentExpression(token);
  }

  @override
  void handleBreakStatement(
      bool hasTarget, Token breakKeyword, Token endToken) {
    listener?.handleBreakStatement(hasTarget, breakKeyword, endToken);
  }

  @override
  void handleCaseMatch(Token caseKeyword, Token colon) {
    listener?.handleCaseMatch(caseKeyword, colon);
  }

  @override
  void handleCommentReference(
      Token? newKeyword,
      Token? firstToken,
      Token? firstPeriod,
      Token? secondToken,
      Token? secondPeriod,
      Token thirdToken) {
    listener?.handleCommentReference(newKeyword, firstToken, firstPeriod,
        secondToken, secondPeriod, thirdToken);
  }

  @override
  void handleCommentReferenceText(String referenceSource, int referenceOffset) {
    listener?.handleCommentReferenceText(referenceSource, referenceOffset);
  }

  @override
  void handleConditionalExpressionColon() {
    listener?.handleConditionalExpressionColon();
  }

  @override
  void handleContinueStatement(
      bool hasTarget, Token continueKeyword, Token endToken) {
    listener?.handleContinueStatement(hasTarget, continueKeyword, endToken);
  }

  @override
  void handleDottedName(int count, Token firstIdentifier) {
    listener?.handleDottedName(count, firstIdentifier);
  }

  @override
  void handleElseControlFlow(Token elseToken) {
    listener?.handleElseControlFlow(elseToken);
  }

  @override
  void handleEmptyFunctionBody(Token semicolon) {
    listener?.handleEmptyFunctionBody(semicolon);
  }

  @override
  void handleEmptyStatement(Token token) {
    listener?.handleEmptyStatement(token);
  }

  @override
  void handleErrorToken(ErrorToken token) {
    listener?.handleErrorToken(token);
  }

  @override
  void handleExpressionFunctionBody(Token arrowToken, Token? endToken) {
    listener?.handleExpressionFunctionBody(arrowToken, endToken);
  }

  @override
  void handleExpressionStatement(Token token) {
    listener?.handleExpressionStatement(token);
  }

  @override
  void handleExtraneousExpression(Token token, Message message) {
    listener?.handleExtraneousExpression(token, message);
  }

  @override
  void handleForInitializerEmptyStatement(Token token) {
    listener?.handleForInitializerEmptyStatement(token);
  }

  @override
  void handleForInitializerExpressionStatement(Token token, bool forIn) {
    listener?.handleForInitializerExpressionStatement(token, forIn);
  }

  @override
  void handleForInitializerLocalVariableDeclaration(Token token, bool forIn) {
    listener?.handleForInitializerLocalVariableDeclaration(token, forIn);
  }

  @override
  void handleForInLoopParts(Token? awaitToken, Token forToken,
      Token leftParenthesis, Token inKeyword) {
    listener?.handleForInLoopParts(
        awaitToken, forToken, leftParenthesis, inKeyword);
  }

  @override
  void handleForLoopParts(Token forKeyword, Token leftParen,
      Token leftSeparator, int updateExpressionCount) {
    listener?.handleForLoopParts(
        forKeyword, leftParen, leftSeparator, updateExpressionCount);
  }

  @override
  void handleFormalParameterWithoutValue(Token token) {
    listener?.handleFormalParameterWithoutValue(token);
  }

  @override
  void handleFunctionBodySkipped(Token token, bool isExpressionBody) {
    listener?.handleFunctionBodySkipped(token, isExpressionBody);
  }

  @override
  void handleIdentifier(Token token, IdentifierContext context) {
    listener?.handleIdentifier(token, context);
  }

  @override
  void handleIdentifierList(int count) {
    listener?.handleIdentifierList(count);
  }

  @override
  void handleIndexedExpression(
      Token? question, Token openSquareBracket, Token closeSquareBracket) {
    listener?.handleIndexedExpression(
        question, openSquareBracket, closeSquareBracket);
  }

  @override
  void handleInterpolationExpression(Token leftBracket, Token? rightBracket) {
    listener?.handleInterpolationExpression(leftBracket, rightBracket);
  }

  @override
  void handleInvalidExpression(Token token) {
    listener?.handleInvalidExpression(token);
  }

  @override
  void handleInvalidFunctionBody(Token token) {
    listener?.handleInvalidFunctionBody(token);
  }

  @override
  void handleInvalidMember(Token endToken) {
    listener?.handleInvalidMember(endToken);
  }

  @override
  void handleInvalidOperatorName(Token operatorKeyword, Token token) {
    listener?.handleInvalidOperatorName(operatorKeyword, token);
  }

  @override
  void handleInvalidStatement(Token token, Message message) {
    listener?.handleInvalidStatement(token, message);
  }

  @override
  void handleInvalidTopLevelDeclaration(Token endToken) {
    listener?.handleInvalidTopLevelDeclaration(endToken);
  }

  @override
  void handleInvalidTypeArguments(Token token) {
    listener?.handleInvalidTypeArguments(token);
  }

  @override
  void handleInvalidTypeReference(Token token) {
    listener?.handleInvalidTypeReference(token);
  }

  @override
  void handleLabel(Token token) {
    listener?.handleLabel(token);
  }

  @override
  void handleLiteralBool(Token token) {
    listener?.handleLiteralBool(token);
  }

  @override
  void handleLiteralDouble(Token token) {
    listener?.handleLiteralDouble(token);
  }

  @override
  void handleLiteralInt(Token token) {
    listener?.handleLiteralInt(token);
  }

  @override
  void handleLiteralList(
      int count, Token beginToken, Token? constKeyword, Token endToken) {
    listener?.handleLiteralList(count, beginToken, constKeyword, endToken);
  }

  @override
  void handleLiteralMapEntry(Token colon, Token endToken) {
    listener?.handleLiteralMapEntry(colon, endToken);
  }

  @override
  void handleLiteralNull(Token token) {
    listener?.handleLiteralNull(token);
  }

  @override
  void handleLiteralSetOrMap(
    int count,
    Token leftBrace,
    Token? constKeyword,
    Token rightBrace,
    // TODO(danrubel): hasSetEntry parameter exists for replicating existing
    // behavior and will be removed once unified collection has been enabled
    bool hasSetEntry,
  ) {
    listener?.handleLiteralSetOrMap(
        count, leftBrace, constKeyword, rightBrace, hasSetEntry);
  }

  @override
  void handleNamedArgument(Token colon) {
    listener?.handleNamedArgument(colon);
  }

  @override
  void handleNoArguments(Token token) {
    listener?.handleNoArguments(token);
  }

  @override
  void handleNoCommentReference() {
    listener?.handleNoCommentReference();
  }

  @override
  void handleNoFormalParameters(Token token, MemberKind kind) {
    listener?.handleNoFormalParameters(token, kind);
  }

  @override
  void handleNoFunctionBody(Token token) {
    listener?.handleNoFunctionBody(token);
  }

  @override
  void handleNoName(Token token) {
    listener?.handleNoName(token);
  }

  @override
  void handleNoType(Token lastConsumed) {
    listener?.handleNoType(lastConsumed);
  }

  @override
  void handleNoTypeVariables(Token token) {
    listener?.handleNoTypeVariables(token);
  }

  @override
  void handleNoTypeArguments(Token token) {
    listener?.handleNoTypeArguments(token);
  }

  @override
  void handleNoVariableInitializer(Token token) {
    listener?.handleNoVariableInitializer(token);
  }

  @override
  void handleOperatorName(Token operatorKeyword, Token token) {
    listener?.handleOperatorName(operatorKeyword, token);
  }

  @override
  void handleParenthesizedCondition(Token token) {
    listener?.handleParenthesizedCondition(token);
  }

  @override
  void handleParenthesizedExpression(Token token) {
    listener?.handleParenthesizedExpression(token);
  }

  @override
  void handleQualified(Token period) {
    listener?.handleQualified(period);
  }

  @override
  void handleRecoverableError(
      Message message, Token startToken, Token endToken) {
    if (forwardErrors) {
      listener?.handleRecoverableError(message, startToken, endToken);
    }
  }

  @override
  void handleStringJuxtaposition(Token startToken, int literalCount) {
    listener?.handleStringJuxtaposition(startToken, literalCount);
  }

  @override
  void handleStringPart(Token token) {
    listener?.handleStringPart(token);
  }

  @override
  void handleSymbolVoid(Token token) {
    listener?.handleSymbolVoid(token);
  }

  @override
  void handleType(Token beginToken, Token? questionMark) {
    listener?.handleType(beginToken, questionMark);
  }

  @override
  void handleTypeVariablesDefined(Token token, int count) {
    listener?.handleTypeVariablesDefined(token, count);
  }

  @override
  void handleUnaryPostfixAssignmentExpression(Token token) {
    listener?.handleUnaryPostfixAssignmentExpression(token);
  }

  @override
  void handleUnaryPrefixAssignmentExpression(Token token) {
    listener?.handleUnaryPrefixAssignmentExpression(token);
  }

  @override
  void handleUnaryPrefixExpression(Token token) {
    listener?.handleUnaryPrefixExpression(token);
  }

  @override
  void handleUnescapeError(
      Message message, Token location, int offset, int length) {
    listener?.handleUnescapeError(message, location, offset, length);
  }

  @override
  void handleValuedFormalParameter(Token equals, Token token) {
    listener?.handleValuedFormalParameter(equals, token);
  }

  @override
  void logEvent(String name) {
    listener?.logEvent(name);
  }

  @override
  void beginVariablesDeclaration(Token token, Token? varFinalOrConst) {
    listener?.beginVariablesDeclaration(token, varFinalOrConst);
  }

  @override
  void endFormalParameter(Token nameToken, Token? initializerStart,
      Token? initializerEnd, FormalParameterKind kind, MemberKind memberKind) {
    listener?.endFormalParameter(
        nameToken, initializerStart, initializerEnd, kind, memberKind);
  }

  @override
  void handleInvalidTopLevelBlock(Token token) {
    listener?.handleInvalidTopLevelBlock(token);
  }

  @override
  void handleSend(Token beginToken, Token endToken) {
    listener?.handleSend(beginToken, endToken);
  }

  @override
  void beginFields(Token? varFinalOrConst, Token lastConsumed) {
    listener?.beginFields(varFinalOrConst, lastConsumed);
  }

  @override
  void beginTopLevelMember(Token token) {
    listener?.beginTopLevelMember(token);
  }

  @override
  void beginTopLevelMethod(Token lastConsumed, Token? externalToken) {
    listener?.beginTopLevelMethod(lastConsumed, externalToken);
  }

  @override
  void endTopLevelFields(
      Token? varFinalOrConst, int count, Token beginToken, Token endToken) {
    listener?.endTopLevelFields(varFinalOrConst, count, beginToken, endToken);
  }

  @override
  void endTopLevelMethod(Token beginToken, Token endToken) {
    listener?.endTopLevelMethod(beginToken, endToken);
  }

  @override
  void beginInitializedIdentifier(Token token) {
    listener?.beginInitializedIdentifier(token);
  }

  @override
  void beginInitializer(Token token) {
    listener?.beginInitializer(token);
  }

  @override
  void endInitializedIdentifier(Token nameToken) {
    listener?.endInitializedIdentifier(nameToken);
  }

  @override
  void endInitializer(Token token) {
    listener?.endInitializer(token);
  }

  @override
  void handleNoInitializers() {
    listener?.handleNoInitializers();
  }
}
