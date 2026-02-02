import Foundation
import AppKit
import Vision
import os
import ScreenCaptureKit

/// Result of a screen capture containing both OCR text and optional base64-encoded image
struct ScreenCaptureResult {
    let windowTitle: String
    let appName: String
    let ocrText: String?
    let imageBase64: String?

    /// Returns the formatted OCR context text for non-vision models
    var formattedOCRContext: String {
        var text = """
        Active Window: \(windowTitle)
        Application: \(appName)

        """
        if let ocrText = ocrText, !ocrText.isEmpty {
            text += "Window Content:\n\(ocrText)"
        } else {
            text += "Window Content:\nNo text detected via OCR"
        }
        return text
    }
}

@MainActor
class ScreenCaptureService: ObservableObject {
    @Published var isCapturing = false
    @Published var lastCapturedText: String?
    @Published var lastCapturedResult: ScreenCaptureResult?
    
    private let logger = Logger(
        subsystem: "com.VincentHopf.embrvoice",
        category: "aienhancement"
    )
    
    private func getActiveWindowInfo() -> (title: String, ownerName: String, windowID: CGWindowID)? {
        let windowListInfo = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID) as? [[String: Any]] ?? []

        if let frontWindow = windowListInfo.first(where: { info in
            let layer = info[kCGWindowLayer as String] as? Int32 ?? 0
            return layer == 0
        }) {
            guard let windowID = frontWindow[kCGWindowNumber as String] as? CGWindowID,
                  let ownerName = frontWindow[kCGWindowOwnerName as String] as? String,
                  let title = frontWindow[kCGWindowName as String] as? String else {
                return nil
            }

            return (title: title, ownerName: ownerName, windowID: windowID)
        }

        return nil
    }
    
    func captureActiveWindow() async -> NSImage? {
        guard let windowInfo = getActiveWindowInfo() else {
            return nil
        }
        
        do {
            let content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
            
            guard let targetWindow = content.windows.first(where: { $0.windowID == windowInfo.windowID }) else {
                return nil
            }
            
            let filter = SCContentFilter(desktopIndependentWindow: targetWindow)
            
            let configuration = SCStreamConfiguration()
            configuration.width = Int(targetWindow.frame.width) * 2
            configuration.height = Int(targetWindow.frame.height) * 2
            
            let cgImage = try await SCScreenshotManager.captureImage(contentFilter: filter, configuration: configuration)
            
            return NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
            
        } catch {
            logger.notice("📸 Screen capture failed: \(error.localizedDescription, privacy: .public)")
            return nil
        }
    }
    
    private func extractText(from image: NSImage) async -> String? {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return nil
        }
        
        let result: Result<String?, Error> = await Task.detached(priority: .userInitiated) {
            let request = VNRecognizeTextRequest()
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            request.automaticallyDetectsLanguage = true
            
            let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            do {
                try requestHandler.perform([request])
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    return .success(nil)
                }
                
                let text = observations
                    .compactMap { $0.topCandidates(1).first?.string }
                    .joined(separator: "\n")
                
                return .success(text.isEmpty ? nil : text)
            } catch {
                return .failure(error)
            }
        }.value
        
        switch result {
        case .success(let text):
            return text
        case .failure(let error):
            logger.notice("📸 Text recognition failed: \(error.localizedDescription, privacy: .public)")
            return nil
        }
    }

    /// Encode an NSImage to base64 PNG string, optionally resizing if larger than maxWidth
    private func encodeImageToBase64(_ image: NSImage, maxWidth: Int = 1536) -> String? {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return nil
        }

        // Check if resizing is needed
        let originalWidth = cgImage.width
        let originalHeight = cgImage.height

        var finalCGImage = cgImage
        if originalWidth > maxWidth {
            let scale = CGFloat(maxWidth) / CGFloat(originalWidth)
            let newWidth = Int(CGFloat(originalWidth) * scale)
            let newHeight = Int(CGFloat(originalHeight) * scale)

            // Create resized image
            if let colorSpace = cgImage.colorSpace,
               let context = CGContext(
                   data: nil,
                   width: newWidth,
                   height: newHeight,
                   bitsPerComponent: cgImage.bitsPerComponent,
                   bytesPerRow: 0,
                   space: colorSpace,
                   bitmapInfo: cgImage.bitmapInfo.rawValue
               ) {
                context.interpolationQuality = .high
                context.draw(cgImage, in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
                if let resizedCGImage = context.makeImage() {
                    finalCGImage = resizedCGImage
                    logger.notice("📸 Resized image from \(originalWidth)x\(originalHeight) to \(newWidth)x\(newHeight)")
                }
            }
        }

        // Convert to PNG data
        let bitmapRep = NSBitmapImageRep(cgImage: finalCGImage)
        guard let pngData = bitmapRep.representation(using: .png, properties: [:]) else {
            logger.notice("📸 Failed to convert image to PNG")
            return nil
        }

        let base64String = pngData.base64EncodedString()
        logger.notice("📸 Encoded image to base64 (\(base64String.count) characters)")
        return base64String
    }

    func captureAndExtractText() async -> String? {
        guard !isCapturing else {
            return nil
        }

        isCapturing = true
        defer {
            DispatchQueue.main.async {
                self.isCapturing = false
            }
        }

        guard let windowInfo = getActiveWindowInfo() else {
            logger.notice("📸 No active window found")
            return nil
        }

        logger.notice("📸 Capturing: \(windowInfo.title, privacy: .public) (\(windowInfo.ownerName, privacy: .public))")

        if let capturedImage = await captureActiveWindow() {
            // Run OCR and base64 encoding in parallel
            async let extractedTextTask = extractText(from: capturedImage)
            let imageBase64 = encodeImageToBase64(capturedImage)
            let extractedText = await extractedTextTask

            if let extractedText = extractedText, !extractedText.isEmpty {
                let preview = String(extractedText.prefix(100))
                logger.notice("📸 Text extracted: \(preview, privacy: .public)\(extractedText.count > 100 ? "..." : "")")
            } else {
                logger.notice("📸 No text extracted from window")
            }

            // Create and store the full result
            let result = ScreenCaptureResult(
                windowTitle: windowInfo.title,
                appName: windowInfo.ownerName,
                ocrText: extractedText,
                imageBase64: imageBase64
            )

            await MainActor.run {
                self.lastCapturedResult = result
                self.lastCapturedText = result.formattedOCRContext
            }

            return result.formattedOCRContext
        }

        logger.notice("📸 Window capture failed")
        return nil
    }

    /// Clear the captured context data
    func clearCapturedResult() {
        lastCapturedResult = nil
        lastCapturedText = nil
    }
} 
