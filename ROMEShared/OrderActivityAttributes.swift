//
//  OrderActivityAttributes.swift
//  ROME
//
//  The contract between the app and its Live Activity.
//
//  This file is compiled into both targets — the app starts and updates the
//  activity, the widget extension renders it — so it must stay free of
//  anything either side cannot import.
//

import ActivityKit
import Foundation

struct OrderActivityAttributes: ActivityAttributes {

    /// Values that change while the order is in flight. Keep this small:
    /// the system budgets how often an activity may be updated, and every
    /// field here is pushed on each update.
    struct ContentState: Codable, Hashable {
        var stage: Stage
        /// When the order is expected to arrive. Rendered with a timer style
        /// so the countdown ticks without the app being awake to update it.
        var expectedAt: Date
        var itemsRemaining: Int
    }

    // Fixed for the life of the activity.
    let orderNumber: String
    let itemCount: Int
    let headlineItem: String
    let total: String

    enum Stage: String, Codable, Hashable, CaseIterable {
        case preparing
        case packed
        case onTheWay
        case delivered

        var title: String {
            switch self {
            case .preparing: return "Preparing"
            case .packed: return "Packed"
            case .onTheWay: return "On the way"
            case .delivered: return "Delivered"
            }
        }

        /// Short enough for the compact Dynamic Island, which gives roughly a
        /// dozen points of width before the system truncates.
        var shortTitle: String {
            switch self {
            case .preparing: return "Packing"
            case .packed: return "Packed"
            case .onTheWay: return "Out"
            case .delivered: return "Done"
            }
        }

        var symbolName: String {
            switch self {
            case .preparing: return "shippingbox.fill"
            case .packed: return "checkmark.seal.fill"
            case .onTheWay: return "bicycle"
            case .delivered: return "house.fill"
            }
        }

        /// 0 through 1, for the progress track.
        var progress: Double {
            guard let index = Stage.allCases.firstIndex(of: self) else { return 0 }
            return Double(index) / Double(Stage.allCases.count - 1)
        }

        var next: Stage? {
            guard
                let index = Stage.allCases.firstIndex(of: self),
                index + 1 < Stage.allCases.count
            else { return nil }
            return Stage.allCases[index + 1]
        }
    }
}
