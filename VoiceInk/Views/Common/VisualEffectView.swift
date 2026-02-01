//
//  VisualEffectView.swift
//  VoiceInk
//
//  NSVisualEffectView wrapper for macOS blur effects
//  Used for HUD windows and notification overlays
//

import SwiftUI
import AppKit

/// A SwiftUI wrapper for NSVisualEffectView to provide macOS native blur effects
/// Used for HUD windows and notification overlays where system blur is appropriate
struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
        visualEffectView.state = .active
        return visualEffectView
    }

    func updateNSView(_ visualEffectView: NSVisualEffectView, context: Context) {
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
    }
}
