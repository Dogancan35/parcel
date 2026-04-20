import Foundation
import SwiftData

@Model
final class Package {
    var id: UUID
    var title: String
    var trackingNumber: String
    var carrier: String
    var arrivalDate: Date
    var statusRaw: String
    var lastChecked: Date
    var events: [TrackingEvent]
    var photoData: Data?

    var status: PackageStatus {
        get { PackageStatus(rawValue: statusRaw) ?? .unknown }
        set { statusRaw = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        title: String,
        trackingNumber: String,
        carrier: String,
        arrivalDate: Date,
        status: PackageStatus = .unknown,
        lastChecked: Date = Date(),
        events: [TrackingEvent] = [],
        photoData: Data? = nil
    ) {
        self.id = id
        self.title = title
        self.trackingNumber = trackingNumber
        self.carrier = carrier
        self.arrivalDate = arrivalDate
        self.statusRaw = status.rawValue
        self.lastChecked = lastChecked
        self.events = events
        self.photoData = photoData
    }
}

enum PackageStatus: String, Codable {
    case unknown = "unknown"
    case ordered = "ordered"
    case shipped = "shipped"
    case inTransit = "in_transit"
    case outForDelivery = "out_for_delivery"
    case delivered = "delivered"
    case delayed = "delayed"
    case failed = "failed"

    var icon: String {
        switch self {
        case .unknown: return "questionmark.circle"
        case .ordered: return "bag"
        case .shipped: return "shippingbox"
        case .inTransit: return "truck.box"
        case .outForDelivery: return "bicycle"
        case .delivered: return "checkmark.circle.fill"
        case .delayed: return "exclamationmark.triangle"
        case .failed: return "xmark.circle"
        }
    }

    var label: String {
        switch self {
        case .unknown: return "Unknown"
        case .ordered: return "Ordered"
        case .shipped: return "Shipped"
        case .inTransit: return "In Transit"
        case .outForDelivery: return "Out for Delivery"
        case .delivered: return "Delivered"
        case .delayed: return "Delayed"
        case .failed: return "Delivery Failed"
        }
    }
}

struct TrackingEvent: Codable, Identifiable {
    var id: UUID = UUID()
    var timestamp: Date
    var location: String
    var description: String
}
