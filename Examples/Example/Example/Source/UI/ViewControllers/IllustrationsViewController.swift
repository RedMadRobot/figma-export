//
//  IllustrationsViewController.swift
//  Example
//
//  Created by Daniil Subbotin on 12.09.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import UIKit
import UIComponents

final class IllustrationsViewController: UIViewController {
    
    @IBOutlet private var stackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        [
            UIImage.imgZeroEmpty,
            UIImage.imgZeroError,
            UIImage.imgZeroInternet
        ].forEach {
            let imageView = UIImageView(image: $0)
            stackView.addArrangedSubview(imageView)
        }
    }
}
