//
//  ContentsMaker.swift
//  SummerPlayerViewDemo
//
//  Created by derrick on 2020/09/29.
//  Copyright © 2020 Derrick. All rights reserved.
//

//import SummerPlayerView
import Foundation

struct ContentsMaker {
    public static func getContents() -> [Content] {
        
        let contents = [
            Content(title: "Newyork", url: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4", thumbnail: "newyork",totalTime: "4:32"),
            Content(title: "Paris", url: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4", thumbnail: "paris" , totalTime: "11:32"),
            Content(title: "Busan", url: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4", thumbnail: "busan",totalTime: "4:32"),
            Content(title: "Copenhagen", url: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4", thumbnail: "cofenhagen",totalTime: "5:40"),
            Content(title: "SF", url: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4", thumbnail: "sf",totalTime: "3:32")
        ]
        
        return contents
    }
}
