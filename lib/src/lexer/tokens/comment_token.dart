// Copyright (c) 2013, the Dart project authors. Please see the AUTHORS file
// for details (https://github.com/dart-lang/sdk/blob/main/AUTHORS). All rights
//reserved. Use of this source code is governed by a BSD-style license that can
// be found in the LICENSE file.

// Modified by the dartfx project authors.
// Copyright (c) 2022, the dartfx project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

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
