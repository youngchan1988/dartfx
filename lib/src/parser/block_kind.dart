// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

class BlockKind {
  final String name;

  final bool useNameForMissingBlock;

  const BlockKind._(this.name, this.useNameForMissingBlock);

  /// Returns the name to use for this block if it is missing in
  /// [templateExpectedClassOrMixinBody].
  ///
  /// If `null` the generic [templateExpectedButGot] is used instead.
  String? get missingBlockName => useNameForMissingBlock ? name : null;

  String toString() => 'BlockKind($name)';

  static const BlockKind finallyClause =
      const BlockKind._('finally clause', /* useNameForMissingBlock = */ true);
  static const BlockKind functionBody =
      const BlockKind._('function body', /* useNameForMissingBlock = */ false);
  static const BlockKind invalid =
      const BlockKind._('invalid', /* useNameForMissingBlock = */ false);
  static const BlockKind statement =
      const BlockKind._('statement', /* useNameForMissingBlock = */ false);
  static const BlockKind switchStatement = const BlockKind._(
      'switch statement', /* useNameForMissingBlock = */ false);
}
