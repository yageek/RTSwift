import Foundation;

struct URNResponse: Codable {
    let chapterUrn: String
    struct Episode: Codable {
        let id: String
        let title: String
        let lead: String?
        let publishedDate: String
        let imageUrl: URL
        let imageTitle: String?
    }
    let episode: Episode?
    struct Show: Codable {
        let id: String
        let vendor: String
        let transmission: String
        let urn: String
        let title: String
        let lead: String?
        let description: String?
        let imageUrl: URL
        let imageTitle: String?
        let bannerImageUrl: URL?
        let homepageUrl: URL?
        let podcastSubscriptionUrl: URL?
    }
    let show: Show
    struct ChapterList: Codable {
        let id: String
        let mediaType: String
        let vendor: String
        let urn: String
        let title: String
        let description: String?
        let imageUrl: URL
        let imageTitle: String?
        let imageCopyright: String?
        let type: String
        let date: String
        let duration: Int
        let validFrom: String
        let validTo: String?
        let playableAbroad: Bool
        let displayable: Bool
        let position: Int
        let noEmbed: Bool
        struct SubtitleList: Codable {
            let language: String
            let locale: String
            let url: URL
            let format: String
        }
        let subtitleList: [SubtitleList]?

        let eventData: String
        struct ResourceList: Codable {
            let url: URL
            let quality: String
            let `protocol`: String
            let encoding: String
            let mimeType: String
            let presentation: String
            let streaming: String
            let dvr: Bool
            let live: Bool
            let mediaContainer: String
            let audioCodec: String
            let videoCodec: String
        }
        let resourceList: [ResourceList]
    }
    let chapterList: [ChapterList]
    struct TopicList: Codable {
        let id: String
        let vendor: String
        let transmission: String
        let urn: String
        let title: String
    }
    let topicList: [TopicList]
}
