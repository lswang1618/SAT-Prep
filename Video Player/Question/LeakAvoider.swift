//
//  LeakAvoider.swift
//  Video Player
//
//  Created by Lisa Wang on 7/6/19.
//  Copyright © 2019 Lisa Wang. All rights reserved.
//

class LeakAvoider : NSObject, WKScriptMessageHandler {
    weak var delegate : WKScriptMessageHandler?
    init(delegate:WKScriptMessageHandler) {
        self.delegate = delegate
        super.init()
    }
    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        self.delegate?.userContentController(
            userContentController, didReceive: message)
    }
}
