import SwiftUI

struct DictionarySettingsView: View {
    @State private var selectedSection: DictionarySection = .replacements
    let whisperPrompt: WhisperPrompt
    
    enum DictionarySection: String, CaseIterable {
        case replacements = "Smart Corrections"
        case spellings = "Personal Vocabulary"
        
        var description: String {
            switch self {
            case .spellings:
                return "Add words to help Echo recognize them properly"
            case .replacements:
                return "Automatically replace specific words/phrases with custom formatted text "
            }
        }
        
        var icon: String {
            switch self {
            case .spellings:
                return "character.book.closed.fill"
            case .replacements:
                return "arrow.2.squarepath"
            }
        }
    }
    
    var body: some View {
        ScrollView {
            mainContent
        }
        .frame(minWidth: 600, minHeight: 500)
        .background(Color(NSColor.controlBackgroundColor))
    }

    private var mainContent: some View {
        VStack(spacing: 40) {
            sectionSelector

            selectedSectionContent
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 20)
    }
    
    private var sectionSelector: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Select Section")
                .font(.title2)
                .fontWeight(.semibold)
            
            HStack(spacing: 20) {
                ForEach(DictionarySection.allCases, id: \.self) { section in
                    SectionCard(
                        section: section,
                        isSelected: selectedSection == section,
                        action: { selectedSection = section }
                    )
                }
            }
        }
    }
    
    private var selectedSectionContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            switch selectedSection {
            case .spellings:
                DictionaryView(whisperPrompt: whisperPrompt)
                    .background(CardBackground(isSelected: false))
            case .replacements:
                WordReplacementView()
                    .background(CardBackground(isSelected: false))
            }
        }
    }
}

struct SectionCard: View {
    let section: DictionarySettingsView.DictionarySection
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: section.icon)
                    .font(.system(size: 28))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(isSelected ? Color.accentColor : .secondary)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(section.rawValue)
                        .font(.headline)
                    
                    Text(section.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(CardBackground(isSelected: isSelected))
        }
        .buttonStyle(.plain)
    }
} 
