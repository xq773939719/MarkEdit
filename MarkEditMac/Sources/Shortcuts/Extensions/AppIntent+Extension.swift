//
//  AppIntent+Extension.swift
//  MarkEditMac
//
//  Created by cyan on 3/10/23.
//

import AppIntents

extension AppIntent {
  /// Returns the current active editor, or nil if not applicable.
  @MainActor var currentEditor: EditorViewController? {
    let orderedControllers = EditorReusePool.shared.viewControllers().sorted {
      let lhs = $0.view.window?.orderedIndex ?? .max
      let rhs = $1.view.window?.orderedIndex ?? .max
      return lhs < rhs
    }

    return orderedControllers.first { $0.view.window != nil } ?? (NSApp as? Application)?.currentEditor
  }
}
