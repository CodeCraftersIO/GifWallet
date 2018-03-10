//
//  Created by Pierluigi Cifani on 01/11/2018.
//  Copyright © 2018 Pierluigi Cifani. All rights reserved.
//

protocol ViewModelConfigurable {
    associatedtype VM
    func configureFor(vm: VM)
}
