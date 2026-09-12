import SwiftUI

struct ExtensionDetailsSheet: View {
    let source: Source
    let isEnabled: Bool
    let onDisable: () -> Void
    let onBrowse: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 12) {
                ExtensionImageView(sourceID: source.id, url: source.iconURL, size: 88, cornerRadius: 22)

                Text(source.name)
                    .font(.title2.weight(.bold))
                    .multilineTextAlignment(.center)

                if let website = source.baseURL {
                    Link(destination: website) {
                        HStack(spacing: 6) {
                            Text(website.absoluteString)
                                .lineLimit(1)
                            Image(systemName: "arrow.up.right")
                                .font(.caption.weight(.semibold))
                        }
                        .font(.subheadline)
                    }
                    .padding(.horizontal, 24)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 30)

            Spacer(minLength: 20)

            HStack(spacing: 12) {
                Button(role: .cancel) {
                    onDisable()
                    dismiss()
                } label: {
                    Label("Disable", systemImage: "puzzlepiece.extension.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.capsule)
                .controlSize(.large)
                .tint(.primary)
                .disabled(!isEnabled)

                Button {
                    onBrowse()
                    dismiss()
                } label: {
                    Label("Browse", systemImage: "safari")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .controlSize(.large)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .presentationDetents([.height(330), .medium])
        .presentationDragIndicator(.visible)
        .presentationBackground(.regularMaterial)
    }
}
