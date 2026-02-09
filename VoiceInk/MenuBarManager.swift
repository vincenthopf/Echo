import SwiftUI
import LaunchAtLogin
import SwiftData
import AppKit

class MenuBarManager: ObservableObject {
    @Published var isMenuBarOnly: Bool {
        didSet {
            UserDefaults.standard.set(isMenuBarOnly, forKey: "IsMenuBarOnly")
            updateAppActivationPolicy()
        }
    }
    
    private var updaterViewModel: UpdaterViewModel
    private var whisperState: WhisperState
    private var container: ModelContainer
    private var enhancementService: AIEnhancementService
    private var aiService: AIService
    private var hotkeyManager: HotkeyManager
    private var mainWindow: NSWindow?  // Store window reference
    private var windowDelegate: WindowDelegate?  // Store delegate to prevent deallocation
    
    init(updaterViewModel: UpdaterViewModel, 
         whisperState: WhisperState, 
         container: ModelContainer,
         enhancementService: AIEnhancementService,
         aiService: AIService,
         hotkeyManager: HotkeyManager) {
        self.isMenuBarOnly = UserDefaults.standard.bool(forKey: "IsMenuBarOnly")
        self.updaterViewModel = updaterViewModel
        self.whisperState = whisperState
        self.container = container
        self.enhancementService = enhancementService
        self.aiService = aiService
        self.hotkeyManager = hotkeyManager
        updateAppActivationPolicy()
    }
    
    func toggleMenuBarOnly() {
        isMenuBarOnly.toggle()
    }

    /// Navigate to a destination in the existing window without creating a new one
    func navigateTo(_ destination: AppDestination) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: .navigateToDestination,
                object: nil,
                userInfo: Notification.destinationUserInfo(destination)
            )
        }
    }
    
    private func updateAppActivationPolicy() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Clean up existing window if switching to menu bar mode
            if self.isMenuBarOnly && self.mainWindow != nil {
                self.mainWindow?.close()
                self.mainWindow = nil
                self.windowDelegate = nil
            }
            
            // Update activation policy
            if self.isMenuBarOnly {
                NSApp.setActivationPolicy(.accessory)
            } else {
                NSApp.setActivationPolicy(.regular)
            }
        }
    }
    
    func openMainWindowAndNavigate(to destination: AppDestination) {
        print("MenuBarManager: Navigating to \(destination)")

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            // Always use .regular policy when opening window
            NSApp.setActivationPolicy(.regular)

            // Activate the app
            NSApp.activate(ignoringOtherApps: true)

            // Find the main content window (exclude menu bar extras, panels, etc.)
            // Look for a regular window that has contentView and is sizable
            let mainWindow = NSApp.windows.first { window in
                window.contentView != nil &&
                window.styleMask.contains(.titled) &&
                window.styleMask.contains(.resizable) &&
                !window.styleMask.contains(.utilityWindow) &&
                window.className != "NSStatusBarWindow" &&
                window.level == .normal
            }

            if let window = mainWindow {
                // Window exists (from WindowGroup) - just bring it to front
                window.makeKeyAndOrderFront(nil)
                window.orderFrontRegardless()
            } else if self.isMenuBarOnly {
                // Only create window in menu-bar-only mode when no window exists
                if self.mainWindow == nil || self.mainWindow?.isVisible == false {
                    self.mainWindow = self.createMainWindow()
                }

                if let window = self.mainWindow {
                    window.makeKeyAndOrderFront(nil)
                    window.orderFrontRegardless()
                    window.center()
                }
            }

            // Post a notification to navigate to the desired destination
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                NotificationCenter.default.post(
                    name: .navigateToDestination,
                    object: nil,
                    userInfo: Notification.destinationUserInfo(destination)
                )
                print("MenuBarManager: Posted navigation notification for \(destination)")
            }
        }
    }
    
    private func createMainWindow() -> NSWindow {
        print("MenuBarManager: Creating new main window")
        
        // Create the content view with all required environment objects
        let contentView = ContentView()
            .environmentObject(whisperState)
            .environmentObject(hotkeyManager)
            .environmentObject(self)
            .environmentObject(updaterViewModel)
            .environmentObject(enhancementService)
            .environmentObject(aiService)
            .environment(\.modelContext, ModelContext(container))
        
        // Create window using WindowManager
        let hostingView = NSHostingView(rootView: contentView)
        let window = WindowManager.shared.createMainWindow(contentView: hostingView)

        // Set window delegate to handle window closing
        let delegate = WindowDelegate { [weak self] in
            self?.mainWindow = nil
            self?.windowDelegate = nil

            // Restore accessory policy when window closes if in menu bar mode
            if self?.isMenuBarOnly == true {
                DispatchQueue.main.async {
                    NSApp.setActivationPolicy(.accessory)
                }
            }
        }
        window.delegate = delegate
        self.windowDelegate = delegate  // Store strong reference to prevent deallocation

        print("MenuBarManager: Window setup complete")

        return window
    }
}

// Window delegate to handle window closing
class WindowDelegate: NSObject, NSWindowDelegate {
    let onClose: () -> Void
    
    init(onClose: @escaping () -> Void) {
        self.onClose = onClose
        super.init()
    }
    
    func windowWillClose(_ notification: Notification) {
        onClose()
    }
}
