// Copyright (c) 2016, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartfx/src/ast/element.dart';
import 'package:dartfx/src/ast/type.dart';
import 'package:dartfx/src/ast/ast.dart';
import 'package:dartfx/src/ast/ast_factory.dart';
import 'package:dartfx/src/lexer/tokens/token.dart';

import 'ast.dart';

/// The instance of [AstFactoryImpl].
final AstFactoryImpl astFactory = AstFactoryImpl();

/// Concrete implementation of [AstFactory] based on the standard AST
/// implementation.
class AstFactoryImpl extends AstFactory {
  @override
  AdjacentStringsImpl adjacentStrings(List<StringLiteral> strings) =>
      AdjacentStringsImpl(strings);

  @override
  AnnotationImpl annotation(
          {required Token atSign,
          required Identifier name,
          TypeArgumentList? typeArguments,
          Token? period,
          SimpleIdentifier? constructorName,
          ArgumentList? arguments}) =>
      AnnotationImpl(
          atSign,
          name as IdentifierImpl,
          typeArguments as TypeArgumentListImpl?,
          period,
          constructorName as SimpleIdentifierImpl?,
          arguments as ArgumentListImpl?);

  @override
  ArgumentListImpl argumentList(Token leftParenthesis,
          List<Expression> arguments, Token rightParenthesis) =>
      ArgumentListImpl(leftParenthesis, arguments, rightParenthesis);

  @override
  AssignmentExpressionImpl assignmentExpression(
          Expression leftHandSide, Token operator, Expression rightHandSide) =>
      AssignmentExpressionImpl(leftHandSide as ExpressionImpl, operator,
          rightHandSide as ExpressionImpl);

  @override
  BinaryExpressionImpl binaryExpression(
          Expression leftOperand, Token operator, Expression rightOperand) =>
      BinaryExpressionImpl(leftOperand as ExpressionImpl, operator,
          rightOperand as ExpressionImpl);

  @override
  BlockImpl block(
          Token leftBracket, List<Statement> statements, Token rightBracket) =>
      BlockImpl(leftBracket, statements, rightBracket);

  @override
  CommentImpl blockComment(List<Token> tokens) =>
      CommentImpl.createBlockComment(tokens);

  @override
  BlockFunctionBodyImpl blockFunctionBody(
          Token? keyword, Token? star, Block block) =>
      BlockFunctionBodyImpl(keyword, star, block as BlockImpl);

  @override
  BooleanLiteralImpl booleanLiteral(Token literal, bool value) =>
      BooleanLiteralImpl(literal, value);

  @override
  BreakStatementImpl breakStatement(
          Token breakKeyword, SimpleIdentifier? label, Token semicolon) =>
      BreakStatementImpl(
          breakKeyword, label as SimpleIdentifierImpl?, semicolon);

  @override
  CascadeExpressionImpl cascadeExpression(
          Expression target, List<Expression> cascadeSections) =>
      CascadeExpressionImpl(target as ExpressionImpl, cascadeSections);

  @override
  CatchClauseImpl catchClause(
          Token? onKeyword,
          TypeAnnotation? exceptionType,
          Token? catchKeyword,
          Token? leftParenthesis,
          SimpleIdentifier? exceptionParameter,
          Token? comma,
          SimpleIdentifier? stackTraceParameter,
          Token? rightParenthesis,
          Block body) =>
      CatchClauseImpl(
          onKeyword,
          exceptionType as TypeAnnotationImpl?,
          catchKeyword,
          leftParenthesis,
          exceptionParameter as SimpleIdentifierImpl?,
          comma,
          stackTraceParameter as SimpleIdentifierImpl?,
          rightParenthesis,
          body as BlockImpl);

  @override
  CommentReferenceImpl commentReference(
          Token? newKeyword, CommentReferableExpression expression) =>
      CommentReferenceImpl(
          newKeyword, expression as CommentReferableExpressionImpl);

  @override
  CompilationUnitImpl compilationUnit(
          {required Token beginToken,
          ScriptTag? scriptTag,
          List<Directive>? directives,
          List<CompilationUnitMember>? declarations,
          required Token endToken}) =>
      CompilationUnitImpl(beginToken, scriptTag as ScriptTagImpl?, directives,
          declarations, endToken);

  @override
  ConditionalExpressionImpl conditionalExpression(
          Expression condition,
          Token question,
          Expression thenExpression,
          Token colon,
          Expression elseExpression) =>
      ConditionalExpressionImpl(
          condition as ExpressionImpl,
          question,
          thenExpression as ExpressionImpl,
          colon,
          elseExpression as ExpressionImpl);

  @override
  ContinueStatementImpl continueStatement(
          Token continueKeyword, SimpleIdentifier? label, Token semicolon) =>
      ContinueStatementImpl(
          continueKeyword, label as SimpleIdentifierImpl?, semicolon);

  @override
  DeclaredIdentifierImpl declaredIdentifier(
          Comment? comment,
          List<Annotation>? metadata,
          Token? keyword,
          TypeAnnotation? type,
          SimpleIdentifier identifier) =>
      DeclaredIdentifierImpl(comment as CommentImpl?, metadata, keyword,
          type as TypeAnnotationImpl?, identifier as SimpleIdentifierImpl);

  @override
  DefaultFormalParameterImpl defaultFormalParameter(
          NormalFormalParameter parameter,
          ParameterKind kind,
          Token? separator,
          Expression? defaultValue) =>
      DefaultFormalParameterImpl(parameter as NormalFormalParameterImpl, kind,
          separator, defaultValue as ExpressionImpl?);

  @override
  CommentImpl documentationComment(List<Token> tokens,
          [List<CommentReference>? references]) =>
      CommentImpl.createDocumentationCommentWithReferences(
          tokens, references ?? <CommentReference>[]);

  @override
  DoStatementImpl doStatement(
          Token doKeyword,
          Statement body,
          Token whileKeyword,
          Token leftParenthesis,
          Expression condition,
          Token rightParenthesis,
          Token semicolon) =>
      DoStatementImpl(
          doKeyword,
          body as StatementImpl,
          whileKeyword,
          leftParenthesis,
          condition as ExpressionImpl,
          rightParenthesis,
          semicolon);

  @override
  DottedNameImpl dottedName(List<SimpleIdentifier> components) =>
      DottedNameImpl(components);

  @override
  DoubleLiteralImpl doubleLiteral(Token literal, double value) =>
      DoubleLiteralImpl(literal, value);

  @override
  EmptyFunctionBodyImpl emptyFunctionBody(Token semicolon) =>
      EmptyFunctionBodyImpl(semicolon);

  @override
  EmptyStatementImpl emptyStatement(Token semicolon) =>
      EmptyStatementImpl(semicolon);

  @override
  CommentImpl endOfLineComment(List<Token> tokens) =>
      CommentImpl.createEndOfLineComment(tokens);

  @override
  ExpressionFunctionBodyImpl expressionFunctionBody2({
    Token? keyword,
    Token? star,
    required Token functionDefinition,
    required Expression expression,
    Token? semicolon,
  }) =>
      ExpressionFunctionBodyImpl(keyword, star, functionDefinition,
          expression as ExpressionImpl, semicolon);

  @override
  ExpressionStatementImpl expressionStatement(
          Expression expression, Token? semicolon) =>
      ExpressionStatementImpl(expression as ExpressionImpl, semicolon);

  @override
  FieldDeclarationImpl fieldDeclaration2(
          {Comment? comment,
          List<Annotation>? metadata,
          Token? abstractKeyword,
          Token? covariantKeyword,
          Token? externalKeyword,
          Token? staticKeyword,
          required VariableDeclarationList fieldList,
          required Token semicolon}) =>
      FieldDeclarationImpl(
          comment as CommentImpl?,
          metadata,
          abstractKeyword,
          covariantKeyword,
          externalKeyword,
          staticKeyword,
          fieldList as VariableDeclarationListImpl,
          semicolon);

  @override
  FieldFormalParameterImpl fieldFormalParameter2(
          {Comment? comment,
          List<Annotation>? metadata,
          Token? covariantKeyword,
          Token? requiredKeyword,
          Token? keyword,
          TypeAnnotation? type,
          required Token thisKeyword,
          required Token period,
          required SimpleIdentifier identifier,
          TypeParameterList? typeParameters,
          FormalParameterList? parameters,
          Token? question}) =>
      FieldFormalParameterImpl(
          comment as CommentImpl?,
          metadata,
          covariantKeyword,
          requiredKeyword,
          keyword,
          type as TypeAnnotationImpl?,
          thisKeyword,
          period,
          identifier as SimpleIdentifierImpl,
          typeParameters as TypeParameterListImpl?,
          parameters as FormalParameterListImpl?,
          question);

  @override
  ForEachPartsWithDeclarationImpl forEachPartsWithDeclaration(
          {required DeclaredIdentifier loopVariable,
          required Token inKeyword,
          required Expression iterable}) =>
      ForEachPartsWithDeclarationImpl(loopVariable as DeclaredIdentifierImpl,
          inKeyword, iterable as ExpressionImpl);

  @override
  ForEachPartsWithIdentifierImpl forEachPartsWithIdentifier(
          {required SimpleIdentifier identifier,
          required Token inKeyword,
          required Expression iterable}) =>
      ForEachPartsWithIdentifierImpl(identifier as SimpleIdentifierImpl,
          inKeyword, iterable as ExpressionImpl);

  @override
  ForElementImpl forElement(
          {Token? awaitKeyword,
          required Token forKeyword,
          required Token leftParenthesis,
          required ForLoopParts forLoopParts,
          required Token rightParenthesis,
          required CollectionElement body}) =>
      ForElementImpl(
          awaitKeyword,
          forKeyword,
          leftParenthesis,
          forLoopParts as ForLoopPartsImpl,
          rightParenthesis,
          body as CollectionElementImpl);

  @override
  FormalParameterListImpl formalParameterList(
          Token leftParenthesis,
          List<FormalParameter> parameters,
          Token? leftDelimiter,
          Token? rightDelimiter,
          Token rightParenthesis) =>
      FormalParameterListImpl(leftParenthesis, parameters, leftDelimiter,
          rightDelimiter, rightParenthesis);

  @override
  ForPartsWithDeclarationsImpl forPartsWithDeclarations(
          {required VariableDeclarationList variables,
          required Token leftSeparator,
          Expression? condition,
          required Token rightSeparator,
          List<Expression>? updaters}) =>
      ForPartsWithDeclarationsImpl(
          variables as VariableDeclarationListImpl,
          leftSeparator,
          condition as ExpressionImpl?,
          rightSeparator,
          updaters);

  @override
  ForPartsWithExpressionImpl forPartsWithExpression(
          {Expression? initialization,
          required Token leftSeparator,
          Expression? condition,
          required Token rightSeparator,
          List<Expression>? updaters}) =>
      ForPartsWithExpressionImpl(
          initialization as ExpressionImpl?,
          leftSeparator,
          condition as ExpressionImpl?,
          rightSeparator,
          updaters);

  @override
  ForStatementImpl forStatement(
      {Token? awaitKeyword,
      required Token forKeyword,
      required Token leftParenthesis,
      required ForLoopParts forLoopParts,
      required Token rightParenthesis,
      required Statement body}) {
    return ForStatementImpl(
        awaitKeyword,
        forKeyword,
        leftParenthesis,
        forLoopParts as ForLoopPartsImpl,
        rightParenthesis,
        body as StatementImpl);
  }

  @override
  FunctionDeclarationImpl functionDeclaration(
          Comment? comment,
          List<Annotation>? metadata,
          Token? externalKeyword,
          TypeAnnotation? returnType,
          Token? propertyKeyword,
          SimpleIdentifier name,
          FunctionExpression functionExpression) =>
      FunctionDeclarationImpl(
          comment as CommentImpl?,
          metadata,
          externalKeyword,
          returnType as TypeAnnotationImpl?,
          propertyKeyword,
          name as SimpleIdentifierImpl,
          functionExpression as FunctionExpressionImpl);

  @override
  FunctionDeclarationStatementImpl functionDeclarationStatement(
          FunctionDeclaration functionDeclaration) =>
      FunctionDeclarationStatementImpl(
          functionDeclaration as FunctionDeclarationImpl);

  @override
  FunctionExpressionImpl functionExpression(TypeParameterList? typeParameters,
          FormalParameterList? parameters, FunctionBody body) =>
      FunctionExpressionImpl(typeParameters as TypeParameterListImpl?,
          parameters as FormalParameterListImpl?, body as FunctionBodyImpl);

  @override
  FunctionExpressionInvocationImpl functionExpressionInvocation(
          Expression function,
          TypeArgumentList? typeArguments,
          ArgumentList argumentList) =>
      FunctionExpressionInvocationImpl(
          function as ExpressionImpl,
          typeArguments as TypeArgumentListImpl?,
          argumentList as ArgumentListImpl);

  @override
  FunctionReferenceImpl functionReference(
          {required Expression function, TypeArgumentList? typeArguments}) =>
      FunctionReferenceImpl(function as ExpressionImpl,
          typeArguments: typeArguments as TypeArgumentListImpl?);

  @override
  FunctionTypeAliasImpl functionTypeAlias(
          Comment? comment,
          List<Annotation>? metadata,
          Token keyword,
          TypeAnnotation? returnType,
          SimpleIdentifier name,
          TypeParameterList? typeParameters,
          FormalParameterList parameters,
          Token semicolon) =>
      FunctionTypeAliasImpl(
          comment as CommentImpl?,
          metadata,
          keyword,
          returnType as TypeAnnotationImpl?,
          name as SimpleIdentifierImpl,
          typeParameters as TypeParameterListImpl?,
          parameters as FormalParameterListImpl,
          semicolon);

  @override
  FunctionTypedFormalParameterImpl functionTypedFormalParameter2(
          {Comment? comment,
          List<Annotation>? metadata,
          Token? covariantKeyword,
          Token? requiredKeyword,
          TypeAnnotation? returnType,
          required SimpleIdentifier identifier,
          TypeParameterList? typeParameters,
          required FormalParameterList parameters,
          Token? question}) =>
      FunctionTypedFormalParameterImpl(
          comment as CommentImpl?,
          metadata,
          covariantKeyword,
          requiredKeyword,
          returnType as TypeAnnotationImpl?,
          identifier as SimpleIdentifierImpl,
          typeParameters as TypeParameterListImpl?,
          parameters as FormalParameterListImpl,
          question);

  @override
  GenericFunctionTypeImpl genericFunctionType(
          TypeAnnotation? returnType,
          Token functionKeyword,
          TypeParameterList? typeParameters,
          FormalParameterList parameters,
          {Token? question}) =>
      GenericFunctionTypeImpl(
          returnType as TypeAnnotationImpl?,
          functionKeyword,
          typeParameters as TypeParameterListImpl?,
          parameters as FormalParameterListImpl,
          question: question);

  @override
  GenericTypeAliasImpl genericTypeAlias(
          Comment? comment,
          List<Annotation>? metadata,
          Token typedefKeyword,
          SimpleIdentifier name,
          TypeParameterList? typeParameters,
          Token equals,
          TypeAnnotation type,
          Token semicolon) =>
      GenericTypeAliasImpl(
          comment as CommentImpl?,
          metadata,
          typedefKeyword,
          name as SimpleIdentifierImpl,
          typeParameters as TypeParameterListImpl?,
          equals,
          type as TypeAnnotationImpl,
          semicolon);

  @override
  HideCombinatorImpl hideCombinator(
          Token keyword, List<SimpleIdentifier> hiddenNames) =>
      HideCombinatorImpl(keyword, hiddenNames);

  @override
  IfElementImpl ifElement(
          {required Token ifKeyword,
          required Token leftParenthesis,
          required Expression condition,
          required Token rightParenthesis,
          required CollectionElement thenElement,
          Token? elseKeyword,
          CollectionElement? elseElement}) =>
      IfElementImpl(
          ifKeyword,
          leftParenthesis,
          condition as ExpressionImpl,
          rightParenthesis,
          thenElement as CollectionElementImpl,
          elseKeyword,
          elseElement as CollectionElementImpl?);

  @override
  IfStatementImpl ifStatement(
          Token ifKeyword,
          Token leftParenthesis,
          Expression condition,
          Token rightParenthesis,
          Statement thenStatement,
          Token? elseKeyword,
          Statement? elseStatement) =>
      IfStatementImpl(
          ifKeyword,
          leftParenthesis,
          condition as ExpressionImpl,
          rightParenthesis,
          thenStatement as StatementImpl,
          elseKeyword,
          elseStatement as StatementImpl?);

  @override
  ImplicitCallReferenceImpl implicitCallReference({
    required Expression expression,
    required MethodElement staticElement,
    required TypeArgumentList? typeArguments,
    required List<DartType> typeArgumentTypes,
  }) =>
      ImplicitCallReferenceImpl(expression as ExpressionImpl,
          staticElement: staticElement,
          typeArguments: typeArguments as TypeArgumentListImpl?,
          typeArgumentTypes: typeArgumentTypes);

  @override
  IndexExpressionImpl indexExpressionForCascade2(
          {required Token period,
          Token? question,
          required Token leftBracket,
          required Expression index,
          required Token rightBracket}) =>
      IndexExpressionImpl.forCascade(
          period, question, leftBracket, index as ExpressionImpl, rightBracket);

  @override
  IndexExpressionImpl indexExpressionForTarget2(
          {required Expression target,
          Token? question,
          required Token leftBracket,
          required Expression index,
          required Token rightBracket}) =>
      IndexExpressionImpl.forTarget(target as ExpressionImpl, question,
          leftBracket, index as ExpressionImpl, rightBracket);

  @override
  IntegerLiteralImpl integerLiteral(Token literal, int? value) =>
      IntegerLiteralImpl(literal, value);

  @override
  InterpolationExpressionImpl interpolationExpression(
          Token leftBracket, Expression expression, Token? rightBracket) =>
      InterpolationExpressionImpl(
          leftBracket, expression as ExpressionImpl, rightBracket);

  @override
  InterpolationStringImpl interpolationString(Token contents, String value) =>
      InterpolationStringImpl(contents, value);

  @override
  LabelImpl label(SimpleIdentifier label, Token colon) =>
      LabelImpl(label as SimpleIdentifierImpl, colon);

  @override
  LabeledStatementImpl labeledStatement(
          List<Label> labels, Statement statement) =>
      LabeledStatementImpl(labels, statement as StatementImpl);

  @override
  ListLiteralImpl listLiteral(
      Token? constKeyword,
      TypeArgumentList? typeArguments,
      Token leftBracket,
      List<CollectionElement> elements,
      Token rightBracket) {
    if (elements is List<Expression>) {
      return ListLiteralImpl(
          constKeyword,
          typeArguments as TypeArgumentListImpl?,
          leftBracket,
          elements,
          rightBracket);
    }
    return ListLiteralImpl.experimental(
        constKeyword,
        typeArguments as TypeArgumentListImpl?,
        leftBracket,
        elements,
        rightBracket);
  }

  @override
  MapLiteralEntryImpl mapLiteralEntry(
          Expression key, Token separator, Expression value) =>
      MapLiteralEntryImpl(
          key as ExpressionImpl, separator, value as ExpressionImpl);

  @override
  MethodDeclarationImpl methodDeclaration(
          Comment? comment,
          List<Annotation>? metadata,
          Token? externalKeyword,
          TypeAnnotation? returnType,
          Token? propertyKeyword,
          Token? operatorKeyword,
          SimpleIdentifier name,
          TypeParameterList? typeParameters,
          FormalParameterList? parameters,
          FunctionBody body) =>
      MethodDeclarationImpl(
          comment as CommentImpl?,
          metadata,
          externalKeyword,
          returnType as TypeAnnotationImpl?,
          propertyKeyword,
          operatorKeyword,
          name as SimpleIdentifierImpl,
          typeParameters as TypeParameterListImpl?,
          parameters as FormalParameterListImpl?,
          body as FunctionBodyImpl);

  @override
  MethodInvocationImpl methodInvocation(
          Expression? target,
          Token? operator,
          SimpleIdentifier methodName,
          TypeArgumentList? typeArguments,
          ArgumentList argumentList) =>
      MethodInvocationImpl(
          target as ExpressionImpl?,
          operator,
          methodName as SimpleIdentifierImpl,
          typeArguments as TypeArgumentListImpl?,
          argumentList as ArgumentListImpl);

  @override
  NamedExpressionImpl namedExpression(Label name, Expression expression) =>
      NamedExpressionImpl(name as LabelImpl, expression as ExpressionImpl);

  @override
  NamedTypeImpl namedType({
    required Identifier name,
    TypeArgumentList? typeArguments,
    Token? question,
  }) =>
      NamedTypeImpl(
          name as IdentifierImpl, typeArguments as TypeArgumentListImpl?,
          question: question);

  @override
  NodeListImpl<E> nodeList<E extends AstNode>(AstNode owner) =>
      NodeListImpl<E>(owner as AstNodeImpl);

  @override
  NullLiteralImpl nullLiteral(Token literal) => NullLiteralImpl(literal);

  @override
  ParenthesizedExpressionImpl parenthesizedExpression(Token leftParenthesis,
          Expression expression, Token rightParenthesis) =>
      ParenthesizedExpressionImpl(
          leftParenthesis, expression as ExpressionImpl, rightParenthesis);

  @override
  PostfixExpressionImpl postfixExpression(Expression operand, Token operator) =>
      PostfixExpressionImpl(operand as ExpressionImpl, operator);

  @override
  PrefixedIdentifierImpl prefixedIdentifier(
          SimpleIdentifier prefix, Token period, SimpleIdentifier identifier) =>
      PrefixedIdentifierImpl(prefix as SimpleIdentifierImpl, period,
          identifier as SimpleIdentifierImpl);

  @override
  PrefixExpressionImpl prefixExpression(Token operator, Expression operand) =>
      PrefixExpressionImpl(operator, operand as ExpressionImpl);

  @override
  ProgramImpl program(
          Token beginToken, Token endToken, Expression expression) =>
      ProgramImpl(beginToken, endToken, expression);

  @override
  PropertyAccessImpl propertyAccess(
          Expression? target, Token operator, SimpleIdentifier propertyName) =>
      PropertyAccessImpl(target as ExpressionImpl?, operator,
          propertyName as SimpleIdentifierImpl);

  @override
  ReturnStatementImpl returnStatement(
          Token returnKeyword, Expression? expression, Token semicolon) =>
      ReturnStatementImpl(
          returnKeyword, expression as ExpressionImpl?, semicolon);

  @override
  ScriptTagImpl scriptTag(Token scriptTag) => ScriptTagImpl(scriptTag);

  @override
  SetOrMapLiteralImpl setOrMapLiteral(
          {Token? constKeyword,
          TypeArgumentList? typeArguments,
          required Token leftBracket,
          required List<CollectionElement> elements,
          required Token rightBracket}) =>
      SetOrMapLiteralImpl(constKeyword, typeArguments as TypeArgumentListImpl?,
          leftBracket, elements, rightBracket);

  @override
  SimpleFormalParameterImpl simpleFormalParameter2(
          {Comment? comment,
          List<Annotation>? metadata,
          Token? covariantKeyword,
          Token? requiredKeyword,
          Token? keyword,
          TypeAnnotation? type,
          required SimpleIdentifier? identifier}) =>
      SimpleFormalParameterImpl(
          comment as CommentImpl?,
          metadata,
          covariantKeyword,
          requiredKeyword,
          keyword,
          type as TypeAnnotationImpl?,
          identifier as SimpleIdentifierImpl?);

  @override
  SimpleIdentifierImpl simpleIdentifier(Token token,
      {bool isDeclaration = false}) {
    if (isDeclaration) {
      return DeclaredSimpleIdentifier(token);
    }
    return SimpleIdentifierImpl(token);
  }

  @override
  SimpleStringLiteralImpl simpleStringLiteral(Token literal, String value) =>
      SimpleStringLiteralImpl(literal, value);

  @override
  SpreadElementImpl spreadElement(
          {required Token spreadOperator, required Expression expression}) =>
      SpreadElementImpl(spreadOperator, expression as ExpressionImpl);

  @override
  StringInterpolationImpl stringInterpolation(
          List<InterpolationElement> elements) =>
      StringInterpolationImpl(elements);

  @override
  SwitchCaseImpl switchCase(List<Label> labels, Token keyword,
          Expression expression, Token colon, List<Statement> statements) =>
      SwitchCaseImpl(
          labels, keyword, expression as ExpressionImpl, colon, statements);

  @override
  SwitchDefaultImpl switchDefault(List<Label> labels, Token keyword,
          Token colon, List<Statement> statements) =>
      SwitchDefaultImpl(labels, keyword, colon, statements);

  @override
  SwitchStatementImpl switchStatement(
          Token switchKeyword,
          Token leftParenthesis,
          Expression expression,
          Token rightParenthesis,
          Token leftBracket,
          List<SwitchMember> members,
          Token rightBracket) =>
      SwitchStatementImpl(
          switchKeyword,
          leftParenthesis,
          expression as ExpressionImpl,
          rightParenthesis,
          leftBracket,
          members,
          rightBracket);

  @override
  SymbolLiteralImpl symbolLiteral(Token poundSign, List<Token> components) =>
      SymbolLiteralImpl(poundSign, components);

  @override
  ThisExpressionImpl thisExpression(Token thisKeyword) =>
      ThisExpressionImpl(thisKeyword);

  @override
  ThrowExpressionImpl throwExpression(
          Token throwKeyword, Expression expression) =>
      ThrowExpressionImpl(throwKeyword, expression as ExpressionImpl);

  @override
  TopLevelVariableDeclarationImpl topLevelVariableDeclaration(
          Comment? comment,
          List<Annotation>? metadata,
          VariableDeclarationList variableList,
          Token semicolon,
          {Token? externalKeyword}) =>
      TopLevelVariableDeclarationImpl(
          comment as CommentImpl?,
          metadata,
          externalKeyword,
          variableList as VariableDeclarationListImpl,
          semicolon);

  @override
  TryStatementImpl tryStatement(
          Token tryKeyword,
          Block body,
          List<CatchClause> catchClauses,
          Token? finallyKeyword,
          Block? finallyBlock) =>
      TryStatementImpl(tryKeyword, body as BlockImpl, catchClauses,
          finallyKeyword, finallyBlock as BlockImpl?);

  @override
  TypeArgumentListImpl typeArgumentList(Token leftBracket,
          List<TypeAnnotation> arguments, Token rightBracket) =>
      TypeArgumentListImpl(leftBracket, arguments, rightBracket);

  @override
  TypeLiteralImpl typeLiteral({required NamedType typeName}) =>
      TypeLiteralImpl(typeName as NamedTypeImpl);

  @override
  TypeParameterImpl typeParameter(
          Comment? comment,
          List<Annotation>? metadata,
          SimpleIdentifier name,
          Token? extendsKeyword,
          TypeAnnotation? bound) =>
      TypeParameterImpl(
          comment as CommentImpl?,
          metadata,
          name as SimpleIdentifierImpl,
          extendsKeyword,
          bound as TypeAnnotationImpl?);

  TypeParameterImpl typeParameter2(
          {Comment? comment,
          List<Annotation>? metadata,
          required SimpleIdentifier name,
          Token? extendsKeyword,
          TypeAnnotation? bound,
          Token? varianceKeyword}) =>
      TypeParameterImpl(
          comment as CommentImpl?,
          metadata,
          name as SimpleIdentifierImpl,
          extendsKeyword,
          bound as TypeAnnotationImpl?)
        ..varianceKeyword = varianceKeyword;

  @override
  TypeParameterListImpl typeParameterList(Token leftBracket,
          List<TypeParameter> typeParameters, Token rightBracket) =>
      TypeParameterListImpl(leftBracket, typeParameters, rightBracket);

  @override
  VariableDeclarationImpl variableDeclaration(
          SimpleIdentifier name, Token? equals, Expression? initializer) =>
      VariableDeclarationImpl(
          name as SimpleIdentifierImpl, equals, initializer as ExpressionImpl?);

  @override
  VariableDeclarationListImpl variableDeclarationList(
          Comment? comment,
          List<Annotation>? metadata,
          Token? keyword,
          TypeAnnotation? type,
          List<VariableDeclaration> variables) =>
      VariableDeclarationListImpl(comment as CommentImpl?, metadata, keyword,
          type as TypeAnnotationImpl?, variables);

  @override
  VariableDeclarationListImpl variableDeclarationList2(
      {Comment? comment,
      List<Annotation>? metadata,
      Token? lateKeyword,
      Token? keyword,
      TypeAnnotation? type,
      required List<VariableDeclaration> variables}) {
    return VariableDeclarationListImpl(comment as CommentImpl?, metadata,
        keyword, type as TypeAnnotationImpl?, variables);
  }

  @override
  VariableDeclarationStatementImpl variableDeclarationStatement(
          VariableDeclarationList variableList, Token semicolon) =>
      VariableDeclarationStatementImpl(
          variableList as VariableDeclarationListImpl, semicolon);

  @override
  WhileStatementImpl whileStatement(Token whileKeyword, Token leftParenthesis,
          Expression condition, Token rightParenthesis, Statement body) =>
      WhileStatementImpl(whileKeyword, leftParenthesis,
          condition as ExpressionImpl, rightParenthesis, body as StatementImpl);
}
