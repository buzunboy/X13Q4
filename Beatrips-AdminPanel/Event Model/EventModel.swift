//
//  EventModel.swift
//  Beatrips-AdminPanel
//
//  Created by Burak Uzunboy on 13.08.2017.
//  Copyright © 2017 Burak Uzunboy. All rights reserved.
//

import UIKit

class EventModel: NSObject {
    
    var name: String = ""
    var ID: String = ""
    var venue: String = ""
    var venueID: String = ""
    var image: String = ""
    var ticket: String = ""
    var descriptionText: String = ""
    var day: String = ""
    var month: String = ""
    var year: String = ""
    var hour: String = ""
    var minute: String = ""
    var isApproved: String = ""
    var likeCount: String = ""
    var seenCount: String = ""
    var commentCount: String = ""
    var latitude: Double = 0
    var longitude: Double = 0
    var isEditorChoice: String = ""
    var isPromoted: String = ""
    var genres: [String] = []
    var eventDate: String = ""
    
    init(name: String, ID: String, venue: String, venueID: String, image: String, ticket: String, descriptionText: String, day: String, month: String, year: String, hour: String, minute: String, isApproved: String, likeCount: String, seenCount: String, commentCount: String, latitude: Double, longitude: Double, isEditorChoice: String, isPromoted: String, genres: [String]) {
        self.name = name
        self.ID = ID
        self.venue = venue
        self.venueID = venueID
        self.image = image
        self.ticket = ticket
        self.descriptionText = descriptionText
        self.day = day
        self.month = month
        self.year = year
        self.hour = hour
        self.minute = minute
        self.isApproved = isApproved
        self.likeCount = likeCount
        self.seenCount = seenCount
        self.commentCount = commentCount
        self.latitude = latitude
        self.longitude = longitude
        self.isEditorChoice = isEditorChoice
        self.isPromoted = isPromoted
        self.genres = genres
        self.eventDate = day + " " + convertMonth(month: month) + "" + year + hour + ":" + minute
    }
    
   

}
