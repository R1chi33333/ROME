//
//  OrderActivityController.swift
//  ROME
//
//  Starts and advances the order's Live Activity.
//
//  The stage progression here is simulated on a timer, standing in for the
//  push updates a real backend would send. That is the only part that is fake:
//  the activity itself is a real `ActivityKit` activity, so it behaves exactly
//  as it would in production — same budgets, same lifecycle, same Island.
//

import ActivityKit
import Observation
import SwiftUI

@MainActor
@Observable
final class OrderActivityController {

    private(set) var isRunning = false

    private var activity: Activity<OrderActivityAttributes>?
    private var advanceTask: Task<Void, Never>?

    /// How long the demo spends in each stage. A real order would sit in
    /// "preparing" for far longer; this is paced so the Island can actually be
    /// watched changing.
    private let stageDuration: Duration = .seconds(12)

    var areActivitiesAvailable: Bool {
        ActivityAuthorizationInfo().areActivitiesEnabled
    }

    func start(orderNumber: String, items: [CartItem], total: String) {
        guard areActivitiesAvailable, activity == nil else { return }

        let itemCount = items.reduce(0) { $0 + $1.quantity }
        let headline = items.first?.product.name ?? "Your order"

        let attributes = OrderActivityAttributes(
            orderNumber: orderNumber,
            itemCount: itemCount,
            headlineItem: headline,
            total: total
        )

        let state = OrderActivityAttributes.ContentState(
            stage: .preparing,
            expectedAt: .now.addingTimeInterval(
                Double(OrderActivityAttributes.Stage.allCases.count - 1) * 12
            ),
            itemsRemaining: itemCount
        )

        do {
            activity = try Activity.request(
                attributes: attributes,
                // `staleDate` tells the system when this content stops being
                // trustworthy, so a stalled activity dims instead of showing a
                // countdown that quietly went wrong.
                content: ActivityContent(state: state, staleDate: .now.addingTimeInterval(600)),
                pushType: nil
            )
            isRunning = true
            scheduleAdvance()
        } catch {
            // Starting can legitimately fail — the user may have disabled
            // activities, or too many are already running. Nothing in the
            // order flow depends on this, so it stays silent.
            activity = nil
        }
    }

    /// Walks the order through the remaining stages, then ends the activity.
    private func scheduleAdvance() {
        advanceTask?.cancel()
        advanceTask = Task { [weak self] in
            guard let self else { return }

            var stage = OrderActivityAttributes.Stage.preparing
            while let next = stage.next {
                try? await Task.sleep(for: stageDuration)
                if Task.isCancelled { return }
                stage = next
                await update(to: stage)
            }

            // Leave the delivered state up briefly so it is not missed, then
            // dismiss. Without an explicit end the activity lingers for hours.
            try? await Task.sleep(for: .seconds(6))
            await finish()
        }
    }

    private func update(to stage: OrderActivityAttributes.Stage) async {
        guard let activity else { return }

        let remainingStages = OrderActivityAttributes.Stage.allCases.count
            - (OrderActivityAttributes.Stage.allCases.firstIndex(of: stage) ?? 0) - 1

        let state = OrderActivityAttributes.ContentState(
            stage: stage,
            expectedAt: .now.addingTimeInterval(Double(remainingStages) * 12),
            itemsRemaining: activity.attributes.itemCount
        )

        await activity.update(
            ActivityContent(state: state, staleDate: .now.addingTimeInterval(600)),
            alertConfiguration: stage == .onTheWay
                ? AlertConfiguration(
                    title: "On the way",
                    body: "\(activity.attributes.headlineItem) has left the store.",
                    sound: .default
                )
                : nil
        )
    }

    private func finish() async {
        await activity?.end(nil, dismissalPolicy: .immediate)
        activity = nil
        isRunning = false
    }

    /// Ends the activity early — used when the user signs out, since the
    /// order belongs to the account they just left.
    func cancel() {
        advanceTask?.cancel()
        Task { await finish() }
    }
}
