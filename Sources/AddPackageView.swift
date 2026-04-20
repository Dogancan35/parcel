import SwiftUI
import SwiftData

struct AddPackageView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var title = ""
    @State private var trackingNumber = ""
    @State private var carrier = "USPS"
    @State private var arrivalDate = Date()
    @State private var useCamera = false
    @State private var capturedImage: UIImage?

    private let carriers = ["USPS", "UPS", "FedEx", "DHL", "Amazon", "Other"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Package Info") {
                    TextField("Nickname (e.g. New Sneakers)", text: $title)

                    Picker("Carrier", selection: $carrier) {
                        ForEach(carriers, id: \.self) { c in
                            Text(c).tag(c)
                        }
                    }

                    TextField("Tracking Number", text: $trackingNumber)
                        .textInputAutocapitalization(.characters)
                }

                Section("Expected Delivery") {
                    DatePicker("Arrival Date", selection: $arrivalDate, displayedComponents: .date)
                }

                Section("Photo (optional)") {
                    if let img = capturedImage {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(Button {
                                capturedImage = nil
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.white, .black.opacity(0.6))
                                    .font(.title2)
                            }
                            .offset(x: 60, y: -60))
                    }

                    Button {
                        useCamera = true
                    } label: {
                        Label(capturedImage == nil ? "Take Photo" : "Retake Photo", systemImage: "camera")
                    }
                }
            }
            .navigationTitle("Add Package")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(title.isEmpty || trackingNumber.isEmpty)
                }
            }
            .sheet(isPresented: $useCamera) {
                CameraView(image: $capturedImage)
            }
        }
    }

    private func save() {
        let pkg = Package(
            title: title,
            trackingNumber: trackingNumber,
            carrier: carrier,
            arrivalDate: arrivalDate,
            status: .ordered,
            photoData: capturedImage?.jpegData(compressionQuality: 0.8)
        )
        modelContext.insert(pkg)
        dismiss()
    }
}

struct CameraView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        init(_ parent: CameraView) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let img = info[.originalImage] as? UIImage {
                parent.image = img
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    AddPackageView()
        .modelContainer(for: Package.self, inMemory: true)
}
