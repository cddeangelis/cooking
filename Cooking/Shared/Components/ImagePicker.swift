import SwiftUI
import PhotosUI

struct ImagePicker: View {
    @Binding var imageData: Data?
    @State private var selectedItem: PhotosPickerItem?

    var body: some View {
        PhotosPicker(selection: $selectedItem, matching: .images) {
            if let imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                ContentUnavailableView {
                    Label("Add Photo", systemImage: "photo.badge.plus")
                } description: {
                    Text("Tap to select an image")
                }
            }
        }
        .onChange(of: selectedItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    await MainActor.run {
                        imageData = data
                    }
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var imageData: Data? = nil
    ImagePicker(imageData: $imageData)
}
