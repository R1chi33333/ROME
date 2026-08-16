//
//  FlyToCart.swift
//  ROME
//
//  Adding to cart sends a copy of the product arcing into the cart tab.
//
//  The point is causal: without it, tapping "Add to Cart" changes a number in
//  a bar at the bottom of the screen and nothing connects the two. The flight
//  is the connection — it says *this* went *there*.
//
//  Both endpoints are measured rather than assumed. The start comes from the
//  hero's real frame on whatever screen triggered it, the end from the cart
//  tab's real frame, both in global coordinates. Hardcoding either breaks the
//  moment a layout changes or a different device size is used.
//

import SwiftUI

// MARK: - Flight state

/// One in-flight parcel. Held by `RootTabView`, which owns the overlay.
struct CartFlight: Equatable, Identifiable {
    let id = UUID()
    let label: String
    let tint: Color
    let start: CGRect
}

@MainActor
@Observable
final class FlightCoordinator {

    private(set) var flight: CartFlight?
    /// Where the cart tab sits, reported by the tab bar as it lays out.
    var destination: CGRect = .zero

    func send(label: String, tint: Color, from start: CGRect) {
        guard start != .zero, destination != .zero else { return }
        flight = CartFlight(label: label, tint: tint, start: start)
    }

    func complete() {
        flight = nil
    }
}

// MARK: - Reporting frames

private struct GlobalFrameKey: PreferenceKey {
    static let defaultValue: [String: CGRect] = [:]
    static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
        value.merge(nextValue()) { _, new in new }
    }
}

extension View {
    /// Publishes this view's frame in global coordinates under `key`.
    func reportsGlobalFrame(_ key: String) -> some View {
        background {
            GeometryReader { geometry in
                Color.clear.preference(
                    key: GlobalFrameKey.self,
                    value: [key: geometry.frame(in: .global)]
                )
            }
        }
    }

    /// Collects frames published by descendants.
    func onGlobalFrames(_ action: @escaping ([String: CGRect]) -> Void) -> some View {
        onPreferenceChange(GlobalFrameKey.self) { action($0) }
    }
}

// MARK: - The parcel

/// The thing that flies. A small copy of the product's thumbnail, following a
/// curve rather than a straight line — a straight line reads as a slide, an
/// arc reads as something being thrown.
struct FlyingParcel: View {

    let flight: CartFlight
    let destination: CGRect
    let onFinish: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var progress: CGFloat = 0

    private var start: CGPoint {
        CGPoint(x: flight.start.midX, y: flight.start.midY)
    }

    private var end: CGPoint {
        CGPoint(x: destination.midX, y: destination.midY)
    }

    /// Lifts the midpoint above the straight line so the parcel arcs.
    private var control: CGPoint {
        CGPoint(
            x: (start.x + end.x) / 2,
            y: min(start.y, end.y) - 120
        )
    }

    private var position: CGPoint {
        let t = progress
        let inverse = 1 - t
        return CGPoint(
            x: inverse * inverse * start.x + 2 * inverse * t * control.x + t * t * end.x,
            y: inverse * inverse * start.y + 2 * inverse * t * control.y + t * t * end.y
        )
    }

    var body: some View {
        RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
            .fill(AppColor.surface)
            .overlay {
                RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                    .fill(flight.tint.opacity(0.18))
            }
            .overlay {
                Text(flight.label)
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.textSecondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.6)
                    .padding(4)
            }
            .appShadow(.card)
            // Shrinks as it travels, so it reads as moving away from the
            // viewer and into the bar rather than sliding across it.
            .frame(
                width: flight.start.width * (1 - 0.72 * progress),
                height: flight.start.height * (1 - 0.72 * progress)
            )
            .position(position)
            .opacity(progress > 0.92 ? 0 : 1)
            .onAppear(perform: run)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }

    private func run() {
        guard !reduceMotion else {
            // No flight under Reduce Motion; the badge still increments, which
            // is the information the animation was carrying.
            onFinish()
            return
        }
        withAnimation(.timingCurve(0.32, 0.9, 0.35, 1, duration: 0.62)) {
            progress = 1
        } completion: {
            onFinish()
        }
    }
}
