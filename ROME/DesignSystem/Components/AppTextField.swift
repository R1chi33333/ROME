//
//  AppTextField.swift
//  ROME
//
//  Text input with a floating label and an animated focus ring.
//

import SwiftUI

struct AppTextField: View {

    let title: String
    @Binding var text: String
    var icon: String?
    var isSecure: Bool = false
    var keyboard: UIKeyboardType = .default
    var contentType: UITextContentType?
    var submitLabel: SubmitLabel = .next
    var onSubmit: (() -> Void)?

    @FocusState private var isFocused: Bool
    @State private var isRevealed = false

    private var hasContent: Bool { !text.isEmpty }
    private var labelIsFloating: Bool { isFocused || hasContent }

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(isFocused ? AppColor.accent : AppColor.textTertiary)
                    .frame(width: 20)
                    .animation(.smooth(duration: 0.2), value: isFocused)
            }

            ZStack(alignment: .leading) {
                Text(title)
                    .font(labelIsFloating ? AppFont.caption : AppFont.body)
                    .foregroundStyle(isFocused ? AppColor.accentText : AppColor.textTertiary)
                    .offset(y: labelIsFloating ? -13 : 0)

                // Always present and always visible. Hiding it until focus
                // (with `opacity`) would take it out of the accessibility
                // tree, leaving VoiceOver and UI tests with nothing to target.
                // It can stay visible safely: when the label is not floating,
                // the field is by definition empty, so the two never overlap.
                field
                    .font(AppFont.body)
                    .foregroundStyle(AppColor.textPrimary)
                    .keyboardType(keyboard)
                    .textContentType(contentType)
                    .textInputAutocapitalization(keyboard == .emailAddress ? .never : .sentences)
                    .autocorrectionDisabled(keyboard == .emailAddress)
                    .submitLabel(submitLabel)
                    .focused($isFocused)
                    .onSubmit { onSubmit?() }
                    .offset(y: labelIsFloating ? 8 : 0)
                    .accessibilityLabel(title)
            }
            .animation(.spring(response: 0.32, dampingFraction: 0.8), value: labelIsFloating)

            if isSecure {
                Button {
                    isRevealed.toggle()
                } label: {
                    Image(systemName: isRevealed ? "eye.slash" : "eye")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(AppColor.textTertiary)
                }
                .buttonStyle(.pressable)
            }
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.vertical, AppSpacing.md)
        .frame(minHeight: 62)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.base, style: .continuous)
                .fill(AppColor.surfaceSunken)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.base, style: .continuous)
                .strokeBorder(
                    isFocused ? AppColor.accent : Color.clear,
                    lineWidth: 1.5
                )
        )
        .animation(.smooth(duration: 0.22), value: isFocused)
        .contentShape(Rectangle())
        .onTapGesture { isFocused = true }
    }

    @ViewBuilder
    private var field: some View {
        if isSecure && !isRevealed {
            SecureField("", text: $text)
        } else {
            TextField("", text: $text)
        }
    }
}

#Preview("Fields") {
    @Previewable @State var email = ""
    @Previewable @State var password = "hunter2"

    return VStack(spacing: AppSpacing.lg) {
        AppTextField(
            title: "Email",
            text: $email,
            icon: "envelope",
            keyboard: .emailAddress,
            contentType: .emailAddress
        )
        AppTextField(
            title: "Password",
            text: $password,
            icon: "lock",
            isSecure: true,
            contentType: .password
        )
    }
    .padding(AppSpacing.screenGutter)
    .background(AppColor.background)
}
