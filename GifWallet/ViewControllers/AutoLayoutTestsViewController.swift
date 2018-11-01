//
//  Created by Pierluigi Cifani on 10/03/2018.
//  Copyright © 2018 Code Crafters. All rights reserved.
//

import UIKit

class AutoLayoutTestsViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let gradientView = GradientView.sampleGradient()
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(gradientView)
        
        let redView = RedView(frame: .zero)
        view.addSubview(redView)

        NSLayoutConstraint.activate([
            redView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            redView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            gradientView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            gradientView.topAnchor.constraint(equalTo: self.view.topAnchor),
            gradientView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            ])
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        print("Horiziontal: \(self.traitCollection.horizontalSizeClass)")
        print("Vertical: \(self.traitCollection.verticalSizeClass)")
    }
}

extension UIUserInterfaceSizeClass: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .compact:
            return "compact"
        case .regular:
            return "regular"
        case .unspecified:
            return "unspecified"
        }
    }
}

class RedView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .red

        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Code Crafters"
        self.addSubview(label)

        self.layoutMargins = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor),
            label.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor),
            label.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor)
            ])
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

import UIKit

class GradientView: UIView {
    
    class func sampleGradient() -> GradientView {
        let gradientView = GradientView(frame: .zero)
        gradientView.startPoint = 0.5
        gradientView.topColor = UIColor(rgb: 0xEF4DB6)
        gradientView.bottomColor = UIColor(rgb: 0xC643FC)
        return gradientView
    }
    
    public var startPoint: Float = 0 {
        didSet {
            updateGradientColors()
        }
    }
    
    public var topColor: UIColor = .white {
        didSet {
            updateGradientColors()
        }
    }
    
    public var bottomColor: UIColor = .black {
        didSet {
            updateGradientColors()
        }
    }
    
    private let gradientLayer = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    private func sharedInit() {
        layer.addSublayer(gradientLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        updateGradientColors()
    }
    
    private func updateGradientColors() {
        gradientLayer.colors = [topColor.cgColor,  bottomColor.cgColor]
        gradientLayer.locations = [0, NSNumber(value: startPoint)]
    }
    
}
