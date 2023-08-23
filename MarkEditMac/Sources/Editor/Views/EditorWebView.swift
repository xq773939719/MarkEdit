//
//  EditorWebView.swift
//  MarkEditMac
//
//  Created by cyan on 12/16/22.
//

import WebKit
import MarkEditKit

enum EditorWebViewMenuAction {
  case findSelection
  case selectAllOccurrences
}

protocol EditorWebViewActionDelegate: AnyObject {
  func editorWebViewIsReadOnly(_ webView: EditorWebView) -> Bool
  func editorWebView(_ webView: EditorWebView, didSelect menuAction: EditorWebViewMenuAction)
  func editorWebView(
    _ webView: EditorWebView,
    didPerform textAction: EditorTextAction,
    sender: Any?
  )
}

/**
 Lightweight wrapper for WKWebView used in editors.
 */
final class EditorWebView: WKWebView {
  static let baseURL = URL(string: "http://localhost/")
  weak var actionDelegate: EditorWebViewActionDelegate?

  override func willOpenMenu(_ menu: NSMenu, with event: NSEvent) {
    // https://github.com/WebKit/WebKit/blob/main/Source/WebKit/Shared/API/c/WKContextMenuItem.cpp
    menu.items = menu.items.filter { item in
      // Disable Font and Paragraph Direction
      if item.submenu?.items.contains(where: { $0.tag == 41 || $0.tag == 52 }) == true {
        return false
      }

      // Hide the "Reload" item, useful for read-only mode
      if item.identifier?.rawValue == "WKMenuItemIdentifierReload" {
        item.isHidden = true
      }

      return true
    }

    // Keep items minimal for ready-only mode
    if actionDelegate?.editorWebViewIsReadOnly(self) == true {
      return super.willOpenMenu(menu, with: event)
    }

    menu.addItem(.separator())
    menu.addItem(withTitle: Localized.Search.findSelection, action: #selector(findSelection(_:)))
    menu.addItem(withTitle: Localized.Search.selectAllOccurrences, action: #selector(selectAllOccurrences(_:)))

    menu.addItem({
      let item = NSMenuItem()
      item.title = Localized.Toolbar.textFormat
      item.submenu = NSApp.appDelegate?.textFormatMenu?.copiedMenu
      return item
    }())

    menu.addItem(.separator())
    super.willOpenMenu(menu, with: event)
  }
}

// MARK: - Private

private extension EditorWebView {
  @objc func findSelection(_ sender: NSMenuItem) {
    actionDelegate?.editorWebView(self, didSelect: .findSelection)
  }

  @objc func selectAllOccurrences(_ sender: NSMenuItem) {
    actionDelegate?.editorWebView(self, didSelect: .selectAllOccurrences)
  }
}
