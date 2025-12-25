import Foundation
import MapKit
import Combine

/// Represents a golf course search result
struct GolfCourseResult: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let address: String
    let coordinate: CLLocationCoordinate2D?

    /// Formatted display string combining name and address
    var displayName: String {
        if address.isEmpty {
            return name
        }
        return "\(address), \(name)"
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: GolfCourseResult, rhs: GolfCourseResult) -> Bool {
        lhs.id == rhs.id
    }
}

/// Service for searching golf courses using MapKit
@MainActor
class GolfCourseSearchService: ObservableObject {
    @Published var searchResults: [GolfCourseResult] = []
    @Published var isSearching = false
    @Published var searchError: String?

    private var searchTask: Task<Void, Never>?
    private var debounceTask: Task<Void, Never>?

    /// Search for golf courses matching the query
    /// - Parameters:
    ///   - query: The search query string
    ///   - debounceDelay: Delay in seconds before executing search (default 0.3s)
    func search(query: String, debounceDelay: Double = 0.3) {
        // Cancel any pending debounce
        debounceTask?.cancel()

        // Clear results if query is empty
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            searchResults = []
            isSearching = false
            searchError = nil
            return
        }

        // Debounce the search
        debounceTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(debounceDelay * 1_000_000_000))

            guard !Task.isCancelled else { return }

            await performSearch(query: query)
        }
    }

    /// Immediately perform a search without debouncing
    func searchImmediately(query: String) async {
        await performSearch(query: query)
    }

    private func performSearch(query: String) async {
        // Cancel any existing search
        searchTask?.cancel()

        isSearching = true
        searchError = nil

        searchTask = Task {
            do {
                let results = try await executeMapKitSearch(query: query)

                guard !Task.isCancelled else { return }

                self.searchResults = results
                self.isSearching = false
            } catch {
                guard !Task.isCancelled else { return }

                self.searchError = "Failed to search: \(error.localizedDescription)"
                self.isSearching = false
            }
        }

        await searchTask?.value
    }

    private func executeMapKitSearch(query: String) async throws -> [GolfCourseResult] {
        let request = MKLocalSearch.Request()
        // Append "golf course" to improve results
        request.naturalLanguageQuery = "\(query) golf course"
        request.resultTypes = .pointOfInterest

        let search = MKLocalSearch(request: request)
        let response = try await search.start()

        return response.mapItems.compactMap { item -> GolfCourseResult? in
            guard let name = item.name else { return nil }

            // Build address from placemark
            let placemark = item.placemark
            var addressComponents: [String] = []

            if let locality = placemark.locality {
                addressComponents.append(locality)
            }
            if let administrativeArea = placemark.administrativeArea {
                addressComponents.append(administrativeArea)
            }

            let address = addressComponents.joined(separator: ", ")

            return GolfCourseResult(
                name: name,
                address: address,
                coordinate: item.placemark.coordinate
            )
        }
    }

    /// Clear all search results
    func clearResults() {
        searchTask?.cancel()
        debounceTask?.cancel()
        searchResults = []
        isSearching = false
        searchError = nil
    }
}
