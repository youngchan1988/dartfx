///
/// Author: YoungChan
/// Date: 2022-01-06 20:30:00
/// LastEditors: YoungChan
/// LastEditTime: 2022-01-06 20:30:00
/// Description: description
/// Copyright: ©2022 NEW CORE Technology Co. Ltd.
///
// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

enum DeclarationKind {
  /// A top level declaration.
  TopLevel,

  /// A class declaration. Not including a named mixin declaration.
  Class,

  /// A mixin declaration. Not including a named mixin declaration.
  Mixin,

  /// An extension declaration.
  Extension,

  /// An enum.
  Enum,
}
