

import Foundation

public struct Content {
    var title: String
    let url: String
    let thumbnail: String
    let totalTime: String
    
    public init(title:String, url: String, thumbnail: String , totalTime: String) {
        self.title = title
        self.url = url
        self.thumbnail = thumbnail
        self.totalTime = totalTime
    }
}
