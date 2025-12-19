import Foundation
import SwiftUI
import Combine

/// Manages local storage of recorded golf session videos
class VideoStorageManager: ObservableObject {
    static let shared = VideoStorageManager()

    @Published private(set) var userVideos: [Video] = []

    private let fileManager = FileManager.default
    private let videosDirectoryName = "RecordedVideos"
    private let metadataFileName = "videos_metadata.json"

    private var videosDirectory: URL {
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsPath.appendingPathComponent(videosDirectoryName)
    }

    private var metadataURL: URL {
        videosDirectory.appendingPathComponent(metadataFileName)
    }

    private init() {
        createVideosDirectoryIfNeeded()
        loadStoredVideos()
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
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"
        let dateString = dateFormatter.string(from: Date())

        let videoId = UUID().uuidString
        let fileName = "session-\(videoId).mp4"
        let destinationURL = videosDirectory.appendingPathComponent(fileName)

        do {
            // Copy the video to local storage
            try fileManager.copyItem(at: sourceURL, to: destinationURL)

            // Create video metadata
            let video = Video(
                id: videoId,
                title: title ?? "Golf Session",
                date: dateString,
                duration: getVideoDuration(url: destinationURL),
                thumbnail: nil,
                videoFileName: destinationURL.path  // Full local path
            )

            // Add to list and save metadata
            DispatchQueue.main.async {
                self.userVideos.insert(video, at: 0)  // Add to beginning (most recent first)
                self.saveMetadata()
                completion(video)
            }

            // Clean up temp file
            try? fileManager.removeItem(at: sourceURL)

        } catch {
            print("Failed to save video: \(error)")
            completion(nil)
        }
    }

    /// Gets the duration of a video file
    private func getVideoDuration(url: URL) -> String {
        let asset = AVURLAsset(url: url)
        let duration = asset.duration
        let seconds = Int(CMTimeGetSeconds(duration))
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
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

// We need to import AVFoundation for CMTimeGetSeconds
import AVFoundation
