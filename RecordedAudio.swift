//
//  RecordedAudio.swift
//  Pitch Perfect
//
//  Created by Antonio Maradiaga on 15/02/2015.
//  Copyright (c) 2015 Antonio Maradiaga. All rights reserved.
//

import Foundation

class RecordedAudio: NSObject{
    var filePathUrl: NSURL!
    var title: String!
    
    override init() {
        filePathUrl = NSURL()
        title = ""
    }
    
    init(_filePathURL: NSURL, _title: String){
        filePathUrl = _filePathURL
        title = _title
    }
}
