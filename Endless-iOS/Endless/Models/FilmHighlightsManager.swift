import Foundation
import Photos
import UIKit
import AVFoundation

/// Manages film highlights for the recruit profile
class FilmHighlightsManager: ObservableObject {
    static let shared = FilmHighlightsManager()

    @Published private(set) var highlights: [FilmHighlight] = []
    @Published var isSaving = false

    private var currentUserId: String?
    private let fileManager = FileManager.default

    private let baseDirectoryName = "FilmHighlights"
    private let metadataFileName = "film_highlights_metadata.json"

    private var baseDirectory: URL {
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsPath.appendingPathComponent(baseDirectoryName)
    }

    private var userDirectory: URL {
        if let userId = currentUserId {
            return baseDirectory.appendingPathComponent(userId)
        }
        return baseDirectory.appendingPathComponent("anonymous")
    }

    private var metadataURL: URL {
        userDirectory.appendingPathComponent(metadataFileName)
    }

    private init() {}

    // MARK: - User Context

    func setCurrentUser(userId: String) {
        guard currentUserId != userId else { return }
        currentUserId = userId
        createDirectoryIfNeeded()
        loadHighlights()
    }

    func clearCurrentUser() {
        currentUserId = nil
        highlights = []
    }

    private func createDirectoryIfNeeded() {
        if !fileManager.fileExists(atPath: userDirectory.path) {
            try? fileManager.createDirectory(at: userDirectory, withIntermediateDirectories: true)
        }
    }

    // MARK: - Save Highlight

    /// Saves a highlight video to the recruit profile
    func saveHighlight(from sourceURL: URL, title: String, completion: @escaping (Bool) -> Void) {
        isSaving = true

        let highlightId = UUID().uuidString
        let fileName = "highlight-\(highlightId).mp4"
        let destinationURL = userDirectory.appendingPathComponent(fileName)
        let thumbnailFileName = "thumbnail-\(highlightId).jpg"
        let thumbnailURL = userDirectory.appendingPathComponent(thumbnailFileName)

        do {
            // Copy the video file
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }
            try fileManager.copyItem(at: sourceURL, to: destinationURL)

            // Generate thumbnail from video
            generateThumbnail(from: destinationURL, to: thumbnailURL)

            // Create highlight metadata
            let highlight = FilmHighlight(
                id: highlightId,
                title: title,
                videoPath: destinationURL.path,
                thumbnailPath: thumbnailURL.path,
                createdAt: Date(),
                isAIGenerated: true
            )

            highlights.insert(highlight, at: 0)
            saveMetadata()

            isSaving = false
            completion(true)
        } catch {
            print("Failed to save highlight: \(error)")
            isSaving = false
            completion(false)
        }
    }

    /// Generates a thumbnail from a video file
    private func generateThumbnail(from videoURL: URL, to thumbnailURL: URL) {
        let asset = AVURLAsset(url: videoURL)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.maximumSize = CGSize(width: 400, height: 400)

        // Get frame at 1 second or middle of video
        let time = CMTime(seconds: 1.0, preferredTimescale: 600)

        do {
            let cgImage = try generator.copyCGImage(at: time, actualTime: nil)
            let uiImage = UIImage(cgImage: cgImage)

            if let jpegData = uiImage.jpegData(compressionQuality: 0.8) {
                try jpegData.write(to: thumbnailURL)
            }
        } catch {
            print("Failed to generate thumbnail: \(error)")
        }
    }

    /// Saves a video to the camera roll
    func saveToCameraRoll(from videoURL: URL, completion: @escaping (Bool, Error?) -> Void) {
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            guard status == .authorized || status == .limited else {
                DispatchQueue.main.async {
                    completion(false, FilmHighlightsError.photoLibraryAccessDenied)
                }
                return
            }

            PHPhotoLibrary.shared().performChanges {
                PHAssetCreationRequest.forAsset().addResource(with: .video, fileURL: videoURL, options: nil)
            } completionHandler: { success, error in
                DispatchQueue.main.async {
                    completion(success, error)
                }
            }
        }
    }

    // MARK: - Delete Highlight

    func deleteHighlight(_ highlight: FilmHighlight) {
        guard let index = highlights.firstIndex(where: { $0.id == highlight.id }) else { return }

        // Delete the video file
        try? fileManager.removeItem(atPath: highlight.videoPath)

        // Delete the thumbnail file
        if let thumbnailPath = highlight.thumbnailPath {
            try? fileManager.removeItem(atPath: thumbnailPath)
        }

        // Remove from array
        highlights.remove(at: index)
        saveMetadata()
    }

    // MARK: - Persistence

    private func loadHighlights() {
        guard fileManager.fileExists(atPath: metadataURL.path),
              let data = try? Data(contentsOf: metadataURL) else {
            highlights = []
            return
        }

        do {
            let decoder = JSONDecoder()
            let loadedHighlights = try decoder.decode([FilmHighlight].self, from: data)

            // Filter out highlights whose files no longer exist
            highlights = loadedHighlights.filter { highlight in
                fileManager.fileExists(atPath: highlight.videoPath)
            }

            // Save if we filtered any out
            if highlights.count != loadedHighlights.count {
                saveMetadata()
            }
        } catch {
            print("Failed to load highlights: \(error)")
            highlights = []
        }
    }

    private func saveMetadata() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(highlights)
            try data.write(to: metadataURL)
        } catch {
            print("Failed to save highlight metadata: \(error)")
        }
    }

    /// Clears all highlights (for account deletion)
    func clearAllHighlights() {
        for highlight in highlights {
            try? fileManager.removeItem(atPath: highlight.videoPath)
            if let thumbnailPath = highlight.thumbnailPath {
                try? fileManager.removeItem(atPath: thumbnailPath)
            }
        }
        highlights = []
        try? fileManager.removeItem(at: metadataURL)
    }
}

// MARK: - Film Highlight Model

struct FilmHighlight: Identifiable, Codable {
    let id: String
    let title: String
    let videoPath: String
    let thumbnailPath: String?
    let createdAt: Date
    let isAIGenerated: Bool

    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        return formatter.string(from: createdAt)
    }

    /// Returns a UIImage for the thumbnail if available
    var thumbnailImage: UIImage? {
        guard let path = thumbnailPath,
              FileManager.default.fileExists(atPath: path),
              let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
            return nil
        }
        return UIImage(data: data)
    }
}

// MARK: - Errors

enum FilmHighlightsError: Error, LocalizedError {
    case photoLibraryAccessDenied
    case saveFailed

    var errorDescription: String? {
        switch self {
        case .photoLibraryAccessDenied:
            return "Please allow access to Photos in Settings to save videos"
        case .saveFailed:
            return "Failed to save the video"
        }
    }
}
