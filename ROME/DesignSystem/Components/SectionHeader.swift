//
//  SectionHeader.swift
//  ROME
//
//  A large left-aligned title with an optional low-emphasis action on the
//  right — the pattern the reference design uses above every content block.
//

import SwiftUI

struct SectionHeader: View {

    let title: String
    var subtitle: String?
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppFont.display)
                    .foregroundStyle(AppColor.textPrimary)

                if let subtitle {
                    Text(subtitle)
                        .font(AppFont.footnote)
                        .foregroundStyle(AppColor.textSecondary)
                }
            }

            Spacer(minLength: AppSpacing.md)

            if let actionTitle, let action {
                TextButton(title: actionTitle, icon: "chevron.right", action: action)
            }
        }
    }
}

/// Smaller variant for blocks nested inside a screen that already has a title.
struct SubsectionHeader: View {

    let title: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(AppFont.sectionTitle)
                .foregroundStyle(AppColor.textPrimary)

            Spacer(minLength: AppSpacing.md)

            if let actionTitle, let action {
                TextButton(title: actionTitle, action: action)
            }
        }
    }
}

#Preview("Headers") {
    VStack(alignment: .leading, spacing: AppSpacing.xl) {
        SectionHeader(title: "Popular", actionTitle: "view all") {}
        SectionHeader(title: "My Pets", subtitle: "3 companions")
        SubsectionHeader(title: "Shop by Pet", actionTitle: "see all") {}
    }
    .padding(AppSpacing.screenGutter)
    .background(AppColor.background)
}
