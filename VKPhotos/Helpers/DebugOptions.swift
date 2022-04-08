//
//  DebugOptions.swift
//  VKPhotos
//
//  Created by Юрий Андрианов on 08.04.2022.
//

import Foundation

// Disable print for release scheme
func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
#if DEBUG
    items.forEach {
        Swift.print($0, separator: separator, terminator: terminator)
    }
#endif
}
