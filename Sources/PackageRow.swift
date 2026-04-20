import SwiftUI

struct PackageRow: View {
    let `package`: Package

    private var carrierColor: Color {
        switch package.carrier {
        case "USPS": return .blue
        case "UPS": return .brown
        case "FedEx": return .purple
        case "DHL": return .yellow
        case "Amazon": return .orange
        default: return .gray
        }
    }

    private var carrierIcon: String {
        switch package.carrier {
        case "USPS": return "envelope.fill"
        case "UPS": return "box.truck.fill"
        case "FedEx": return "airplane"
        case "DHL": return "globe"
        case "Amazon": return "cart.fill"
        default: return "shippingbox.fill"
        }
    }

    private var daysUntil: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: package.arrivalDate).day ?? 0
    }

    var body: some View {
        HStack(spacing: 14) {
            // Carrier icon badge
            ZStack {
                Circle()
                    .fill(carrierColor.gradient)
                    .frame(width: 44, height: 44)

                Image(systemName: carrierIcon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(package.title)
                    .font(.headline)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    Text(package.carrier)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("•")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(package.trackingNumber)
                        .font(.caption.monospaced())
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                // Arrival countdown
                if package.status != .delivered {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption2)

                        if daysUntil == 0 {
                            Text("Arriving today!")
                                .font(.caption.bold())
                                .foregroundStyle(.green)
                        } else if daysUntil == 1 {
                            Text("Tomorrow")
                                .font(.caption.bold())
                                .foregroundStyle(.orange)
                        } else if daysUntil > 1 {
                            Text("in \(daysUntil) days")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } else {
                            Text("Overdue")
                                .font(.caption.bold())
                                .foregroundStyle(.red)
                        }
                    }
                }
            }

            Spacer()

            Image(systemName: package.status.icon)
                .font(.title2)
                .foregroundStyle(statusColor)
        }
        .padding(.vertical, 4)
    }

    private var statusColor: Color {
        switch package.status {
        case .delivered: return .green
        case .delayed, .failed: return .red
        case .outForDelivery: return .orange
        case .shipped, .inTransit: return .blue
        default: return .secondary
        }
    }
}

#Preview {
    let pkg = Package(
        title: "Nike Air Max",
        trackingNumber: "1Z999AA10123456784",
        carrier: "UPS",
        arrivalDate: Date().addingTimeInterval(86400 * 2),
        status: .inTransit
    )
    return List { PackageRow(package: pkg) }
        .listStyle(.insetGrouped)
}
