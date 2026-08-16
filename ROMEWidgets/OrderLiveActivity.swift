//
//  OrderLiveActivity.swift
//  ROMEWidgets
//
//  The order's Live Activity: lock screen banner, and the three Dynamic Island
//  presentations.
//
//  The HIG treats the Island as a set of sizes with different jobs rather than
//  one view that shrinks. Compact leading and trailing are a handful of points
//  each and get one glyph and one very short string; minimal appears when a
//  second activity is running and has room for a single symbol only; expanded
//  is the only place a sentence belongs. Each is written for its own size here
//  rather than scaling one layout down.
//

import ActivityKit
import SwiftUI
import WidgetKit

struct OrderLiveActivity: Widget {

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: OrderActivityAttributes.self) { context in
            LockScreenView(context: context)
                // A tint here rather than a filled background: the lock screen
                // composites the activity over the wallpaper, and an opaque
                // fill fights whatever is behind it.
                .activityBackgroundTint(Color.black.opacity(0.55))
                .activitySystemActionForegroundColor(.white)

        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Label {
                        Text(context.state.stage.title)
                            .font(.caption)
                            .foregroundStyle(.white)
                    } icon: {
                        Image(systemName: context.state.stage.symbolName)
                            .foregroundStyle(Self.accent)
                    }
                }

                DynamicIslandExpandedRegion(.trailing) {
                    if context.state.stage == .delivered {
                        Text("Arrived")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        // Timer style so the countdown keeps ticking without
                        // the activity being updated — updates are budgeted,
                        // and a per-second push would exhaust that budget.
                        Text(timerInterval: Date.now...context.state.expectedAt, countsDown: true)
                            .font(.caption.monospacedDigit())
                            .multilineTextAlignment(.trailing)
                            .frame(maxWidth: 64)
                            .foregroundStyle(.white)
                    }
                }

                DynamicIslandExpandedRegion(.center) {
                    Text(context.attributes.headlineItem)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading, spacing: 6) {
                        ProgressView(value: context.state.stage.progress)
                            .tint(Self.accent)

                        HStack {
                            Text(summary(for: context))
                                .font(.caption2)
                                .foregroundStyle(.secondary)

                            Spacer()

                            Text(context.attributes.total)
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(.white)
                        }
                    }
                }

            } compactLeading: {
                Image(systemName: context.state.stage.symbolName)
                    .foregroundStyle(Self.accent)

            } compactTrailing: {
                if context.state.stage == .delivered {
                    Image(systemName: "checkmark")
                        .foregroundStyle(Self.accent)
                } else {
                    Text(timerInterval: Date.now...context.state.expectedAt, countsDown: true)
                        .font(.caption2.monospacedDigit())
                        // Without a width the timer's widest frame pushes the
                        // island wider mid-countdown and it visibly jitters.
                        .frame(maxWidth: 44)
                        .foregroundStyle(Self.accent)
                }

            } minimal: {
                Image(systemName: context.state.stage.symbolName)
                    .foregroundStyle(Self.accent)
            }
            .widgetURL(URL(string: "rome://order/\(context.attributes.orderNumber)"))
            .keylineTint(Self.accent)
        }
    }

    /// The app's accent, restated here because the extension is a separate
    /// target and does not see the app's design tokens.
    private static let accent = Color(red: 1.0, green: 0.42, blue: 0.21)

    private func summary(for context: ActivityViewContext<OrderActivityAttributes>) -> String {
        let count = context.attributes.itemCount
        let items = count == 1 ? "1 item" : "\(count) items"
        return "\(items) · \(context.attributes.orderNumber)"
    }
}

// MARK: - Lock screen

private struct LockScreenView: View {

    let context: ActivityViewContext<OrderActivityAttributes>

    private static let accent = Color(red: 1.0, green: 0.42, blue: 0.21)

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: context.state.stage.symbolName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Self.accent)
                    .frame(width: 32, height: 32)
                    .background(Circle().fill(Self.accent.opacity(0.18)))

                VStack(alignment: .leading, spacing: 1) {
                    Text(context.state.stage.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)

                    Text(context.attributes.headlineItem)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                        .lineLimit(1)
                }

                Spacer(minLength: 8)

                if context.state.stage != .delivered {
                    VStack(alignment: .trailing, spacing: 1) {
                        Text(timerInterval: Date.now...context.state.expectedAt, countsDown: true)
                            .font(.callout.monospacedDigit().weight(.semibold))
                            .multilineTextAlignment(.trailing)
                            .frame(maxWidth: 74)
                            .foregroundStyle(.white)

                        Text("remaining")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.55))
                    }
                }
            }

            ProgressView(value: context.state.stage.progress)
                .tint(Self.accent)

            HStack {
                Text(context.attributes.orderNumber)
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.55))

                Spacer()

                Text(context.attributes.total)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
        .padding(14)
    }
}
