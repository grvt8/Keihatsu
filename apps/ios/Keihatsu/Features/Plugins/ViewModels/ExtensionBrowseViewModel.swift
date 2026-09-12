import Combine
import Foundation

@MainActor
final class ExtensionBrowseViewModel: ObservableObject {
    @Published private(set) var mangas: [Manga] = []
    @Published private(set) var isLoading = false
    @Published private(set) var hasNextPage = true
    @Published private(set) var error: String?

    private let source: Source
    private let repository: any CatalogueRepository
    private var page = 0
    private var query = ""
    private var generation = UUID()

    init(source: Source, repository: any CatalogueRepository) {
        self.source = source
        self.repository = repository
    }

    func reload(query rawQuery: String) async {
        let normalized = rawQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        let request = UUID()
        generation = request
        query = normalized
        page = 0
        hasNextPage = true
        error = nil
        mangas = []
        isLoading = false
        await loadNextPage(generation: request)
    }

    func loadNextPage() async {
        await loadNextPage(generation: generation)
    }

    private func loadNextPage(generation request: UUID) async {
        guard request == generation, !isLoading, hasNextPage else { return }
        let nextPage = page + 1
        let currentQuery = query
        let listing: CatalogueListing = currentQuery.isEmpty ? .popular : .search
        isLoading = true
        error = nil

        if nextPage == 1,
           let cached = await repository.cachedMangas(
                sourceID: source.id,
                listing: listing,
                page: nextPage,
                query: currentQuery.isEmpty ? nil : currentQuery
           ), request == generation {
            mangas = cached.mangas
            hasNextPage = cached.hasNextPage
        }

        do {
            let result = try await repository.mangas(
                sourceID: source.id,
                listing: listing,
                page: nextPage,
                query: currentQuery.isEmpty ? nil : currentQuery
            )
            try Task.checkCancellation()
            guard request == generation else { return }
            var known = Set(mangas.map(\.id))
            mangas.append(contentsOf: result.mangas.filter { known.insert($0.id).inserted })
            page = nextPage
            hasNextPage = result.hasNextPage
            isLoading = false
        } catch is CancellationError {
            if request == generation { isLoading = false }
        } catch {
            guard request == generation else { return }
            self.error = error.localizedDescription
            isLoading = false
        }
    }
}
