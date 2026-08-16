//
//  PawRefresh.swift
//  ROME
//
//  Pull to refresh: a paw reaches down, grips the top edge of the content and
//  holds it open while the work runs. When the work finishes the paw lets go,
//  and the content springs back on its own.
//
//  Why this is not `.refreshable`: the system control owns the snap-back and
//  releases the content on its own curve the moment the work completes, so
//  there is no held-open state for anything to be gripping. Here the revealed
//  strip is ordinary layout — a spacer whose height this view sets — which is
//  what makes "held down, then let go" expressible at all.
//

import SwiftUI
import UIKit

struct PawRefreshScrollView<Content: View>: View {

    let onRefresh: () async -> Void
    @ViewBuilder var content: Content

    /// How far the user has dragged past the top, live.
    @State private var pull: CGFloat = 0
    /// Height this view is holding open — i.e. how far down the paw is
    /// currently pinning the content. Zero unless refreshing or rebounding.
    @State private var heldHeight: CGFloat = 0
    @State private var stage: Stage = .idle

    /// Drives the paw's own release animation, independent of the content.
    @State private var pawOpening: CGFloat = 0
    @State private var pawLift: CGFloat = 0
    /// Where the paw was when it opened its toes. Held so that the content can
    /// spring away from underneath it — following `revealed` here would drag
    /// the paw home with the content, which is the opposite of letting go.
    @State private var releaseReach: CGFloat = 0

    private enum Stage: Equatable {
        case idle
        /// Reaching down, but the user has not pulled far enough to trigger.
        case reaching
        /// Clamped on — releasing the finger now will refresh.
        case gripping
        /// Holding the content open while the work runs.
        case holding
        /// Let go; the content is springing back.
        case releasing
    }

    /// Drag distance at which the paw takes hold.
    private let threshold: CGFloat = 80
    /// How far down the paw pins the content while the work runs.
    private let holdHeight: CGFloat = 76
    /// Cap on how far past the top the rebound is allowed to overshoot.
    private let maxOvershoot: CGFloat = 14

    /// The strip currently open above the content, whether that is the user's
    /// drag or the height the paw is pinning.
    private var revealed: CGFloat { max(pull, max(0, heldHeight)) }

    private var progress: CGFloat { min(1, revealed / threshold) }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Color.clear
                    .frame(height: max(0, heldHeight))
                content
            }
            // A spring that only drove the spacer's height would stop dead at
            // zero, because a frame cannot be negative — and the rebound is
            // the whole point of letting go. Negative values are carried as an
            // offset instead, so the overshoot is actually visible.
            .offset(y: min(0, max(-maxOvershoot, heldHeight)))
        }
        .onScrollGeometryChange(for: CGFloat.self) { geometry in
            geometry.contentOffset.y + geometry.contentInsets.top
        } action: { _, offset in
            handleOffsetChange(offset)
        }
        .onScrollPhaseChange { _, newPhase in
            // The lift is the trigger: the paw takes hold during the drag, but
            // the work should only start once the finger is off.
            guard newPhase == .decelerating || newPhase == .idle else { return }
            guard stage == .gripping else { return }
            startRefresh()
        }
        .overlay(alignment: .top) {
            GrippingPaw(
                progress: progress,
                isHolding: stage == .holding,
                opening: pawOpening
            )
            // Sits on the content's top edge and travels with it, so it reads
            // as holding that edge rather than floating in the gap above it.
            .offset(y: pawReach - 22)
            .opacity(revealed > 4 || stage == .releasing ? 1 : 0)
            .allowsHitTesting(false)
        }
    }

    /// How far down the paw currently sits. It tracks the surface while it has
    /// hold of it, then detaches at the moment of release and withdraws on its
    /// own timing.
    private var pawReach: CGFloat {
        stage == .releasing ? releaseReach + pawLift : revealed
    }

    // MARK: - Stage machine

    private func handleOffsetChange(_ offset: CGFloat) {
        pull = max(0, -offset)

        // Once the paw has hold, the drag no longer drives anything.
        guard stage == .idle || stage == .reaching || stage == .gripping else { return }

        let next: Stage = pull <= 0 ? .idle : (pull >= threshold ? .gripping : .reaching)
        guard next != stage else { return }

        if next == .gripping {
            Haptics.impact(.rigid)
        }
        stage = next
    }

    private func startRefresh() {
        stage = .holding
        withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
            heldHeight = holdHeight
        }

        Task {
            await onRefresh()
            await letGo()
        }
    }

    /// The paw opens first, then the content is free to go. The small gap
    /// between the two is what makes it read as a release rather than a shove:
    /// nothing moves until the grip is visibly gone.
    @MainActor
    private func letGo() async {
        releaseReach = revealed
        stage = .releasing
        Haptics.impact(.soft)

        // Splay open.
        withAnimation(.spring(response: 0.2, dampingFraction: 0.55)) {
            pawOpening = 1
        }
        try? await Task.sleep(for: .milliseconds(110))

        // Content is loose — low damping so it visibly overshoots and settles.
        withAnimation(.spring(response: 0.5, dampingFraction: 0.55)) {
            heldHeight = 0
        }
        // The paw hangs where it let go for a beat, then withdraws upward.
        withAnimation(.easeIn(duration: 0.34).delay(0.1)) {
            pawLift = -(releaseReach + 40)
        }

        try? await Task.sleep(for: .milliseconds(680))

        stage = .idle
        pawOpening = 0
        pawLift = 0
        releaseReach = 0
    }
}

// MARK: - Paw

private struct GrippingPaw: View {

    /// 0 while reaching, 1 once the pull is deep enough to grip.
    let progress: CGFloat
    let isHolding: Bool
    /// 0 gripped, 1 fully splayed open on release.
    let opening: CGFloat

    /// Slow tremble while the paw is taking the weight of the held content.
    @State private var strain = false

    private var isGripped: Bool { progress >= 1 }

    var body: some View {
        ZStack {
            Circle()
                .fill(AppColor.surface)
                .appShadow(isGripped ? .card : .sm)

            Image(systemName: isGripped && opening == 0 ? "pawprint.fill" : "pawprint")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(isGripped ? AppColor.accent : AppColor.accent.opacity(0.55))
                // Straightens up as the pull approaches the threshold, then
                // twists slightly as it lets go.
                .rotationEffect(.degrees(reachAngle))
                // Splays outward at the moment of release.
                .scaleEffect(1 + 0.34 * opening)
        }
        .frame(width: 44, height: 44)
        .scaleEffect(gripScale)
        .opacity(1 - 0.75 * Double(opening))
        .onChange(of: isHolding) { _, holding in
            if holding {
                withAnimation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true)) {
                    strain = true
                }
            } else {
                strain = false
            }
        }
    }

    private var reachAngle: Double {
        if opening > 0 { return 18 }
        if isHolding { return strain ? 4 : -4 }
        return -32 * (1 - Double(progress))
    }

    /// Squashes very slightly once loaded — the visual cue that it is bearing
    /// the weight of the content it is holding down.
    private var gripScale: CGFloat {
        if opening > 0 { return 1 + 0.12 * opening }
        if isHolding { return 0.96 }
        return 0.72 + 0.28 * progress
    }
}

// MARK: - Haptics

enum Haptics {
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
}

#Preview("Paw refresh") {
    PawRefreshScrollView {
        try? await Task.sleep(for: .seconds(2))
    } content: {
        VStack(spacing: AppSpacing.md) {
            ForEach(0..<12, id: \.self) { index in
                HStack {
                    Text("Row \(index + 1)")
                        .font(AppFont.cardTitle)
                        .foregroundStyle(AppColor.textPrimary)
                    Spacer()
                }
                .cardStyle()
            }
        }
        .padding(AppSpacing.screenGutter)
    }
    .background(AppColor.background)
}
