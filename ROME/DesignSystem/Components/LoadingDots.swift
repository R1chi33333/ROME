//
//  LoadingDots.swift
//  ROME
//
//  Three dots rising and falling in sequence. Used inside buttons where a
//  system spinner would look out of place against the app's own type.
//

import SwiftUI

struct LoadingDots: View {

    var color: Color = .white
    var dotSize: CGFloat = 7

    @State private var isAnimating = false

    var body: some View {
        HStack(spacing: dotSize * 0.6) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(color)
                    .frame(width: dotSize, height: dotSize)
                    .offset(y: isAnimating ? -dotSize * 0.55 : dotSize * 0.55)
                    .animation(
                        .easeInOut(duration: 0.42)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.14),
                        value: isAnimating
                    )
            }
        }
        .onAppear { isAnimating = true }
    }
}

// MARK: - Checkmark

/// A checkmark that draws itself in, for confirming a completed action.
struct AnimatedCheckmark: View {

    var color: Color = .white
    var lineWidth: CGFloat = 2.5

    @State private var progress: CGFloat = 0

    var body: some View {
        CheckmarkShape()
            .trim(from: 0, to: progress)
            .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
            .frame(width: 20, height: 20)
            .onAppear {
                withAnimation(.easeOut(duration: 0.32)) { progress = 1 }
            }
    }
}

private struct CheckmarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + rect.width * 0.14, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.40, y: rect.maxY - rect.height * 0.22))
        path.addLine(to: CGPoint(x: rect.maxX - rect.width * 0.12, y: rect.minY + rect.height * 0.24))
        return path
    }
}

// MARK: - Skeleton shimmer

/// Placeholder block shown while a `DataStore` call is in flight.
struct SkeletonBlock: View {

    var height: CGFloat
    var radius: CGFloat = AppRadius.base

    @State private var phase: CGFloat = -1

    var body: some View {
        RoundedRectangle(cornerRadius: radius, style: .continuous)
            .fill(AppColor.surfaceSunken)
            .frame(height: height)
            .overlay {
                GeometryReader { geometry in
                    LinearGradient(
                        colors: [.clear, AppColor.surface.opacity(0.7), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * 0.6)
                    .offset(x: phase * geometry.size.width * 1.6)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .onAppear {
                withAnimation(.linear(duration: 1.3).repeatForever(autoreverses: false)) {
                    phase = 1.2
                }
            }
    }
}

#Preview("Loading states") {
    VStack(spacing: AppSpacing.xl) {
        LoadingDots(color: AppColor.ink)
        AnimatedCheckmark(color: AppColor.ink)
        SkeletonBlock(height: 120)
        SkeletonBlock(height: 16)
    }
    .padding(AppSpacing.xxl)
    .background(AppColor.background)
}
