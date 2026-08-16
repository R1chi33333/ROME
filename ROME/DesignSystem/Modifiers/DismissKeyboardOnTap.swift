//
//  DismissKeyboardOnTap.swift
//  ROME
//
//  Tapping empty space in a form puts the keyboard away.
//
//  `scrollDismissesKeyboard(.interactively)` only responds to a drag, so
//  without this a tap on the background leaves the keyboard up — and on a long
//  form it can be covering the very field the user is reaching for.
//

import SwiftUI

extension View {
    func dismissKeyboardOnTap() -> some View {
        onTapGesture {
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil,
                from: nil,
                for: nil
            )
        }
    }
}
