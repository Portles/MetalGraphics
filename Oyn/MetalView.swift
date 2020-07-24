//
//  MetalView.swift
//  Oyn
//
//  Created by Nizamet Özkan on 23.07.2020.
//  Copyright © 2020 NizoOrganizatsiyon. All rights reserved.
//

import MetalKit

class MetalView: MTKView {
    
    var renderer: Renderer!
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        
        self.device = MTLCreateSystemDefaultDevice()
        
        self.colorPixelFormat = .bgra8Unorm
        
        self.clearColor = MTLClearColor(red: 0.25, green: 0.57, blue: 0.39, alpha: 1.0)
        
        renderer = Renderer(device: device!)
        
        self.delegate = renderer
    }
    
}
