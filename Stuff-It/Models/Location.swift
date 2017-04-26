//
//  Location.swift
//  Inventory17
//
//  Created by Michael King on 2/13/17.
//  Copyright © 2017 Microideas. All rights reserved.
//

import UIKit

struct Location {
    var locationKey: String!
    var _locationName: String!
    var _locationDetail: String?
    var _locationArea: String?
    
    var locationName: String! {
        get {
            return _locationName
        }
        set{
            _locationName = newValue
        }
    }
    
    var locationArea: String? {
        get {
            return _locationArea
        }
        set{
            _locationArea = newValue
        }
    }
    
    var locationDetail: String? {
        get {
            return _locationDetail
        }
        set{
            _locationDetail = newValue
        }
    }
    
    
    init(name: String!, detail: String?, area: String?) {
        self._locationName = name
        self._locationDetail = detail
        self._locationArea = area
    }
    
    
    init (locationKey: String, dictionary: Dictionary <String, AnyObject> ) {
        self.locationKey = locationKey
        
        if let locationName = dictionary["name"] as? String {
            self._locationName = locationName
        }
        
        if let locationDetail = dictionary["detail"] as? String {
            self._locationDetail = locationDetail
        }
        
        if let locationArea = dictionary["area"] as? String {
            self._locationArea = locationArea
        }
        
    }
  
}
 
