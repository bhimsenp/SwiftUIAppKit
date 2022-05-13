import SwiftUI
import Combine

public struct URLImage: View {
    private let url: String?
    private let cacheMins: Int?
    private let placeholder: AnyView
    public init(url: String?, placeholder: AnyView? = nil, cacheMins: Int? = nil) {
        self.url = url
        self.cacheMins = cacheMins
        self.placeholder = placeholder ?? AnyView(Color.gray)
    }
    public var body: some View {
        ImageFetcherView(url: url, cacheMins: cacheMins) { image in
            content(image: image)
        }
    }

    @ViewBuilder private func content(image: UIImage?) -> some View {
        if let image = image {
            Image(uiImage: image)
                .resizable().aspectRatio(contentMode: .fill)
        } else {
            placeholder
        }
    }
}

public struct ImageFetcherView<Content: View>: View {
    @State private var imageLoader: ImageLoader
    @State var image: UIImage?
    private let url: String?
    private let content: (UIImage?) -> Content
    public init(url: String?, cacheMins: Int? = nil, content: @escaping (UIImage?) -> Content) {
        self.url = url
        self.content = content
        self.imageLoader = ImageLoader(urlString: url, cacheMins: cacheMins)
    }
    public var body: some View {
        ZStack {
            content(image)
        }
        .onReceive(imageLoader.didChange) { newImage in
            if newImage.0 == url {
                self.image = newImage.1
            }
        }
        .onReceive(imageLoader.didStartFetching) {
            self.image = nil
        }
        .onReceive(imageLoader.didFail) {
            self.image = nil
        }
        .onAppear {
            imageLoader.showImage(url: url)
        }
    }
}

public class ImageLoader {
    let cacheMins: Int?
    public var didChange = PassthroughSubject<(String, UIImage?), Never>()
    public var didStartFetching = PassthroughSubject<Void, Never>()
    public var didFail = PassthroughSubject<Void, Never>()
    private var requestInProgress = false

    public init(urlString: String?, cacheMins: Int?) {
        self.cacheMins = cacheMins
//        showImage(url: urlString)
    }

    public func showImage(url: String?) {
        if let url = url {
            Task {
                if let cached = await CacheService.shared.getCached(forKey: url) {
                    DispatchQueue.main.async {
                        self.didChange.send((url, UIImage(data: cached)))
                    }
                } else {
                    await self.fetchImage(url: url)
                }
            }
        } else {
            DispatchQueue.main.async {
                self.didFail.send()
            }
        }
    }

    private func fetchImage(url: String) async {
        if requestInProgress { return }
        requestInProgress = true
        DispatchQueue.main.sync {
            self.didStartFetching.send()
        }
        do {
            requestInProgress = false
            let data = try await APIClient.shared.fetchImage(url: url)
            if let cacheMins = self.cacheMins {
                await CacheService.shared.setCache(withKey: url, data: data, expiryInMinutes: cacheMins)
            }
            DispatchQueue.main.async {
                self.didChange.send((url, UIImage(data: data)))
            }
        } catch {
            requestInProgress = false
            DispatchQueue.main.async {
                self.didFail.send()
            }
        }
    }
}
