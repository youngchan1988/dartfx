///
/// Author: YoungChan
/// Date: 2022-01-05 11:44:13
/// LastEditors: YoungChan
/// LastEditTime: 2022-01-05 11:44:14
/// Description: description
/// Copyright: ©2022 NEW CORE Technology Co. Ltd.
///

import 'string_token.dart';
import 'token.dart';

/// A token representing a comment.
class CommentToken extends StringToken {
  /// The token that contains this comment.
  SimpleToken? parent;

  /// Initialize a newly created token to represent a token of the given [type]
  /// with the given [value] at the given [offset].
  CommentToken(
      {required TokenType type, required String value, required int offset})
      : super(type: type, value: value, offset: offset);

  @override
  CommentToken copy() =>
      CommentToken(type: type, value: value(), offset: offset);

  /// Remove this comment token from the list.
  ///
  /// This is used when we decide to interpret the comment as syntax.
  void remove() {
    Token? previous = this.previous;
    if (previous != null) {
      previous.setNextWithoutSettingPrevious(next);
      next?.previous = previous;
    } else {
      assert(parent!.precedingComments == this);
      parent!.precedingComments = next as CommentToken?;
    }
  }
}
