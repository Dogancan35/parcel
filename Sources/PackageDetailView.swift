import SwiftUI
import SwiftData

struct PackageDetailView: View {
    let package: Package
    @Environment(\.modelContext) private var modelContext
    @State private var isRefreshing = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Hero card
                VStack(spacing: 12) {
                    Image(systemName: package.status.icon)
                        .font(.system(size: 48))
                        .foregroundStyle(statusColor)

                    Text(package.status.label)
                        .font(.title2.bold())

                    if let img = package.photoData, let uiImage = UIImage(data: img) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 160)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                }

                // Info cards
                VStack(spacing: 12) {
                    InfoRow(icon: "shippingbox", label: "Carrier", value: package.carrier)
                    InfoRow(icon: "number", label: "Tracking #", value: package.trackingNumber)
                    InfoRow(icon: "calendar", label: "Expected", value: package.arrivalDate.formatted(date: .long, time: .omitted))
                    InfoRow(icon: "clock", label: "Last Checked", value: package.lastChecked.formatted(date: .abbreviated, time: .shortened))
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.secondarySystemGroupedBackground))
                }

                // Timeline
                if !package.events.isEmpty {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Tracking History")
                            .font(.headline)
                            .padding(.horizontal)
                            .padding(.bottom, 8)

                        ForEach(Array(package.events.enumerated()), id: \.element.id) { idx, event in
                            TimelineRow(event: event, isLast: idx == package.events.count - 1)
                        }
                    }
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.secondarySystemGroupedBackground))
                    }
                }

                // Refresh button
                Button {
                    refresh()
                } label: {
                    HStack {
                        if isRefreshing {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "arrow.triangle.2.circlepath")
                        }
                        Text(isRefreshing ? "Checking..." : "Refresh Status")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(isRefreshing)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(package.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var statusColor: Color {
        switch package.status {
        case .delivered: return .green
        case .delayed, .failed: return .red
        case .outForDelivery: return .orange
        default: return .accentColor
        }
    }

    private func refresh() {
        isRefreshing = true
        // Simulate API check — in production: call carrier API
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            package.lastChecked = Date()
            isRefreshing = false
        }
    }
}

struct InfoRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 24)
                .foregroundStyle(.secondary)

            Text(label)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .fontWeight(.medium)
        }
        .font(.subheadline)
    }
}

struct TimelineRow: View {
    let event: TrackingEvent
    let isLast: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(spacing: 0) {
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 10, height: 10)

                if !isLast {
                    Rectangle()
                        .fill(Color.accentColor.opacity(0.3))
                        .frame(width: 2, height: 40)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(event.description)
                    .font(.subheadline)

                Text(event.location)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(event.timestamp.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .padding(.bottom, isLast ? 0 : 12)

            Spacer()
        }
    }
}

#Preview {
    let pkg = Package(
        title: "New Sneakers",
        trackingNumber: "1Z999AA10123456784",
        carrier: "UPS",
        arrivalDate: Date().addingTimeInterval(86400 * 2),
        status: .outForDelivery,
        events: [
            TrackingEvent(timestamp: Date().addingTimeInterval(-3600), location: "Local Hub", description: "Out for delivery"),
            TrackingEvent(timestamp: Date().addingTimeInterval(-86400), location: "Memphis, TN", description: "In transit"),
            TrackingEvent(timestamp: Date().addingTimeInterval(-172800), location: "Origin", description: "Package picked up"),
        ]
    )
    return NavigationStack {
        PackageDetailView(package: pkg)
    }
    .modelContainer(for: Package.self, inMemory: true)
}
