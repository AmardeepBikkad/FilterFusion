//
//  ViewController+Model+Enum.swift
//  FilterFusion
//
//  Created by Amardeep Bikkad on 27/01/24.
//

import Foundation
import UIKit

enum Mode {
    case none
    case drawMode
    case textMode
}

struct EditPhotoModel {
    var isPhoto: Bool = true
    var image: UIImage?
    var textViews: [UITextView]?
    var doneImage: UIImage?
    
    init(isPhoto: Bool, image: UIImage? = nil, textViews: [UITextView]? = nil, doneImage: UIImage? = nil) {
        self.isPhoto = isPhoto
        self.image = image
        self.textViews = textViews
        self.doneImage = doneImage
    }
}

struct PointModel {
    var point: [CGPoint]?
    var color: [UIColor]?
}

enum FilterType: String {
    case Chrome = "CIPhotoEffectChrome"
    case Fade = "CIPhotoEffectFade"
    case Instant = "CIPhotoEffectInstant"
    case Mono = "CIPhotoEffectMono"
    case Noir = "CIPhotoEffectNoir"
    case Process = "CIPhotoEffectProcess"
    case Tonal = "CIPhotoEffectTonal"
    case Transfer = "CIPhotoEffectTransfer"
}
