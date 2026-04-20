import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var showAddPackage = false
    @Query(sort: \Package.arrivalDate) private var packages: [Package]

    var body: some View {
        NavigationStack {
            Group {
                if packages.isEmpty {
                    EmptyStateView()
                } else {
                    PackageListView(packages: packages)
                }
            }
            .navigationTitle("📦 Parcel")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddPackage = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showAddPackage) {
                AddPackageView()
            }
        }
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "shippingbox")
                .font(.system(size: 72))
                .foregroundStyle(.secondary)

            Text("No packages yet")
                .font(.title2.bold())

            Text("Tap + to add a tracking number\nor scan a barcode")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

struct PackageListView: View {
    let packages: [Package]

    var body: some View {
        List {
            ForEach(packages) { pkg in
                NavigationLink {
                    PackageDetailView(package: pkg)
                } label: {
                    PackageRow(package: pkg)
                }
            }
            .onDelete(perform: delete)
        }
        .listStyle(.insetGrouped)
    }

    private func delete(at offsets: IndexSet) {
        // handled via modelContext in the view
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Package.self, inMemory: true)
}
