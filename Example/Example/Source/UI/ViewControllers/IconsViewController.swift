//
//  IconsViewController.swift
//  Example
//
//  Created by Daniil Subbotin on 12.09.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import UIKit
import UIComponents

final class IconsViewController: UIViewController {
    @IBOutlet private var stackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        [
            UIImage.ic16Notification,
            UIImage.ic16KeyEmergency,
            UIImage.ic16KeySandglass,
            UIImage.ic24ShareIos,
            UIImage.ic24Close,
            UIImage.ic24ArrowRight,
            UIImage.ic24DropdownDown,
            UIImage.ic24Dots,
            UIImage.ic24FullscreenEnable,
            UIImage.ic24FullscreenDisable
        ].forEach {
            let imageView = UIImageView(image: $0)
            stackView.addArrangedSubview(imageView)
        }
    }
}
