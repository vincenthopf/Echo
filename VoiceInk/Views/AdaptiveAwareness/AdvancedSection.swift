import SwiftUI

/// Advanced section for additional settings
struct AdvancedSection: View {
    @Binding var config: PowerModeConfig
    let onSave: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Advanced")
                .font(.headline)
                .foregroundColor(.secondary)

            HStack(spacing: 8) {
                Toggle("Auto-send after transcription", isOn: Binding(
                    get: { config.isAutoSendEnabled },
                    set: { newValue in
                        config.isAutoSendEnabled = newValue
                        onSave()
                    }
                ))
                .toggleStyle(.switch)

                InfoTip(
                    title: "Auto-Send",
                    message: "Automatically paste the transcription to the active text field after transcription completes, without requiring manual confirmation."
                )
            }
        }
    }
}
