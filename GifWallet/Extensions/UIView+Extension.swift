//
//  Created by Pierluigi Cifani on 01/11/2018.
//  Copyright © 2018 Pierluigi Cifani. All rights reserved.
//

import UIKit

extension UIView {
    
    public func addAutolayoutView(_ subview: UIView) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(subview)
    }

}
