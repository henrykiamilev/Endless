import Foundation
import SwiftUI
import Combine

/// Manages local storage of recorded golf session videos
class VideoStorageManager: ObservableObject {
    static let shared = VideoStorageManager()

    @Published private(set) var userVideos: [Video] = []

    /// The current user's ID - videos are stored per-user
    private var currentUserId: String?

    private let fileManager = FileManager.default
    private let baseVideosDirectoryName = "RecordedVideos"
    private let metadataFileName = "videos_metadata.json"

    /// Base directory for all video storage
    private var baseVideosDirectory: URL {
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsPath.appendingPathComponent(baseVideosDirectoryName)
    }

    /// User-specific videos directory
    private var videosDirectory: URL {
        if let userId = currentUserId {
            return baseVideosDirectory.appendingPathComponent(userId)
        }
        // Fallback for legacy/anonymous data
        return baseVideosDirectory.appendingPathComponent("anonymous")
    }

    private var metadataURL: URL {
        videosDirectory.appendingPathComponent(metadataFileName)
    }

    private init() {
        // Don't load videos on init - wait for user to be set
    }

    // MARK: - User Context Management

    /// Sets the current user and loads their videos
    /// Call this when a user signs in
    func setCurrentUser(userId: String) {
        // Don't reload if same user
        guard currentUserId != userId else { return }

        currentUserId = userId
        createVideosDirectoryIfNeeded()
        loadStoredVideos()

        // Migrate any legacy videos from old storage location to user's directory
        migrateLegacyVideosIfNeeded()
    }

    /// Clears the current user context without deleting data
    /// Call this when a user signs out
    func clearCurrentUser() {
        currentUserId = nil
        userVideos = []
    }

    /// Migrates videos from the old non-user-specific location
    private func migrateLegacyVideosIfNeeded() {
        guard let userId = currentUserId else { return }

        let legacyDirectory = baseVideosDirectory
        let legacyMetadataURL = legacyDirectory.appendingPathComponent(metadataFileName)

        // Check if legacy metadata exists at base level (not in a user folder)
        guard fileManager.fileExists(atPath: legacyMetadataURL.path) else { return }

        // Don't migrate if it's actually in a user subfolder
        let userDirectory = baseVideosDirectory.appendingPathComponent(userId)
        if legacyMetadataURL.path.contains(userDirectory.path) { return }

        do {
            let data = try Data(contentsOf: legacyMetadataURL)
            let decoder = JSONDecoder()
            let legacyMetadata = try decoder.decode([VideoMetadataLegacy].self, from: data)

            // Move each video file to user directory
            for meta in legacyMetadata {
                let legacyVideoPath = legacyDirectory.appendingPathComponent(meta.fileName)
                let newVideoPath = videosDirectory.appendingPathComponent(meta.fileName)

                if fileManager.fileExists(atPath: legacyVideoPath.path) {
                    try? fileManager.moveItem(at: legacyVideoPath, to: newVideoPath)
                }
            }

            // Move metadata file
            try? fileManager.moveItem(at: legacyMetadataURL, to: metadataURL)

            // Reload videos after migration
            loadStoredVideos()

            print("Migrated legacy videos to user directory: \(userId)")
        } catch {
            print("Failed to migrate legacy videos: \(error)")
        }
    }

    private func createVideosDirectoryIfNeeded() {
        if !fileManager.fileExists(atPath: videosDirectory.path) {
            try? fileManager.createDirectory(at: videosDirectory, withIntermediateDirectories: true)
        }
    }

    /// Saves an exported video to the local storage
    /// - Parameters:
    ///   - sourceURL: The temporary URL of the exported video
    ///   - title: The title for the video
    ///   - completion: Called with the saved Video object, or nil if saving failed
    func saveVideo(from sourceURL: URL, title: String? = nil, completion: @escaping (Video?) -> Void) {
        Task {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yy"
            let dateString = dateFormatter.string(from: Date())

            let videoId = UUID().uuidString
            let fileName = "session-\(videoId).mp4"
            let destinationURL = videosDirectory.appendingPathComponent(fileName)

            do {
                // Copy the video to local storage
                try fileManager.copyItem(at: sourceURL, to: destinationURL)

                // Get video duration asynchronously
                let duration = await getVideoDuration(url: destinationURL)

                // Create video metadata
                let video = Video(
                    id: videoId,
                    title: title ?? "Golf Session",
                    date: dateString,
                    duration: duration,
                    thumbnail: nil,
                    videoFileName: destinationURL.path  // Full local path
                )

                // Add to list and save metadata
                await MainActor.run {
                    self.userVideos.insert(video, at: 0)  // Add to beginning (most recent first)
                    self.saveMetadata()
                    completion(video)
                }

                // Clean up temp file
                try? fileManager.removeItem(at: sourceURL)

            } catch {
                print("Failed to save video: \(error)")
                await MainActor.run {
                    completion(nil)
                }
            }
        }
    }

    /// Gets the duration of a video file
    private func getVideoDuration(url: URL) async -> String {
        let asset = AVURLAsset(url: url)
        
        do {
            if #available(iOS 16.0, *) {
                let duration = try await asset.load(.duration)
                let seconds = Int(CMTimeGetSeconds(duration))
                let minutes = seconds / 60
                let remainingSeconds = seconds % 60
                return String(format: "%d:%02d", minutes, remainingSeconds)
            } else {
                let duration = asset.duration
                let seconds = Int(CMTimeGetSeconds(duration))
                let minutes = seconds / 60
                let remainingSeconds = seconds % 60
                return String(format: "%d:%02d", minutes, remainingSeconds)
            }
        } catch {
            print("Failed to load video duration: \(error)")
            return "0:00"
        }
    }

    /// Loads stored videos from metadata file
    private func loadStoredVideos() {
        guard fileManager.fileExists(atPath: metadataURL.path),
              let data = try? Data(contentsOf: metadataURL) else {
            return
        }

        do {
            let decoder = JSONDecoder()
            let metadata = try decoder.decode([VideoMetadata].self, from: data)

            // Convert metadata to Video objects, filtering out videos that no longer exist
            userVideos = metadata.compactMap { meta -> Video? in
                let videoPath = videosDirectory.appendingPathComponent(meta.fileName).path
                guard fileManager.fileExists(atPath: videoPath) else { return nil }

                return Video(
                    id: meta.id,
                    title: meta.title,
                    date: meta.date,
                    duration: meta.duration,
                    thumbnail: nil,
                    videoFileName: videoPath
                )
            }
        } catch {
            print("Failed to load video metadata: \(error)")
        }
    }

    /// Saves video metadata to disk
    private func saveMetadata() {
        let metadata = userVideos.map { video -> VideoMetadata in
            let fileName = URL(fileURLWithPath: video.videoFileName ?? "").lastPathComponent
            return VideoMetadata(
                id: video.id,
                title: video.title,
                date: video.date,
                duration: video.duration,
                fileName: fileName
            )
        }

        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(metadata)
            try data.write(to: metadataURL)
        } catch {
            print("Failed to save video metadata: \(error)")
        }
    }

    /// Deletes a video from storage
    func deleteVideo(_ video: Video) {
        guard let index = userVideos.firstIndex(where: { $0.id == video.id }) else { return }

        if let path = video.videoFileName {
            try? fileManager.removeItem(atPath: path)
        }

        userVideos.remove(at: index)
        saveMetadata()
    }

    /// Permanently deletes all stored videos and metadata for the current user
    /// WARNING: This permanently deletes data. Use clearCurrentUser() for sign-out instead.
    /// Only use this when the user explicitly requests to delete their data (e.g., account deletion)
    func clearAllVideos() {
        // Delete all video files
        for video in userVideos {
            if let path = video.videoFileName {
                try? fileManager.removeItem(atPath: path)
            }
        }

        // Clear the list
        userVideos = []

        // Delete metadata file
        try? fileManager.removeItem(at: metadataURL)
    }

    /// Gets all videos (user recorded + mock data)
    var allVideos: [Video] {
        userVideos + MockData.videos
    }
}

// MARK: - Video Metadata for persistence
private struct VideoMetadata: Codable {
    let id: String
    let title: String
    let date: String
    let duration: String
    let fileName: String
}

/// Legacy metadata struct for migration from old storage format
private struct VideoMetadataLegacy: Codable {
    let id: String
    let title: String
    let date: String
    let duration: String
    let fileName: String
}

// We need to import AVFoundation for CMTimeGetSeconds
import AVFoundation

