//
//  monthConverter.swift
//  Beatrips-AdminPanel
//
//  Created by Burak Uzunboy on 6.08.2017.
//  Copyright © 2017 Burak Uzunboy. All rights reserved.
//

import Foundation

func convertMonth(month: String) -> String{
    
    switch month {
    case "01":
        return "January"
    case "02":
        return "February"
    case "03":
        return "March"
    case "04":
        return "April"
    case "05":
        return "May"
    case "06":
        return "June"
    case "07":
        return "July"
    case "08":
        return "August"
    case "09":
        return "September"
    case "10":
        return "October"
    case "11":
        return "November"
    case "12":
        return "December"
    default:
        return ""
    }
    
}
