// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Modified by the dartfx project authors.
// Copyright (c) 2022, the dartfx project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartfx/src/ast/type.dart';
import 'package:dartfx/src/ast_impl/type.dart';

/// The builder for a [DartType] represented by a node.
abstract class TypeBuilder implements TypeImpl {
  /// Build the type, and set it for the corresponding node.
  /// Does nothing if the type has been already built.
  ///
  /// Return the built type.
  DartType build();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
