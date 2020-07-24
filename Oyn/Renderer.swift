//
//  Renderer.swift
//  Oyn
//
//  Created by Nizamet Özkan on 23.07.2020.
//  Copyright © 2020 NizoOrganizatsiyon. All rights reserved.
//

import MetalKit

class Renderer: NSObject {
    
    var commandQueue: MTLCommandQueue!
    var renderPipelineState: MTLRenderPipelineState!
    
    var indexBuffer: MTLBuffer!
    var vertexBuffer: MTLBuffer!
    var indices: [uint16]!
    
    var vertices: [Vertex]!
    
    var constants = Constants()
    
    init(device: MTLDevice) {
        super.init()
        
        buildCommandQueue(device: device)
        buildPipelineState(device: device)
        buildVertices()
        buildBuffers(device: device)
    }
    
    func buildCommandQueue(device: MTLDevice){
        commandQueue = device.makeCommandQueue()
    }
    
    func buildPipelineState(device: MTLDevice) {
        let library = device.makeDefaultLibrary()
        let vertexFunction = library?.makeFunction(name: "basic_vertex_function")
        let fragmentFunction = library?.makeFunction(name: "basic_fragment_function")
        
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        renderPipelineDescriptor.vertexFunction = vertexFunction
        renderPipelineDescriptor.fragmentFunction = fragmentFunction
        
        let vertexDesriptor = MTLVertexDescriptor()
        vertexDesriptor.attributes[0].bufferIndex = 0
        vertexDesriptor.attributes[0].format = .float3
        vertexDesriptor.attributes[0].offset = 0
        
        vertexDesriptor.attributes[1].bufferIndex = 0
        vertexDesriptor.attributes[1].format = .float4
        vertexDesriptor.attributes[1].offset = MemoryLayout<float3>.size
        
        vertexDesriptor.layouts[0].stride = MemoryLayout<Vertex>.stride
        
        renderPipelineDescriptor.vertexDescriptor = vertexDesriptor
        
        do{
            renderPipelineState = try device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
        }catch let error as NSError{
            Swift.print("\(error)")
        }
    }
    func buildVertices(){
        
        let size: Float = 0.5
        
        vertices = [
            Vertex(position: float3( size, size, 0), color: float4( 1, 0, 0, 1)),
            Vertex(position: float3( -size, size, 0), color: float4( 1, 1, 0, 1)),
            Vertex(position: float3( -size, -size, 0), color: float4( 0, 0, 1, 1)),
            Vertex(position: float3( size, -size, 0), color: float4( 1, 0, 1, 1))
        ]
        
        indices = [
            0, 1, 2,
            0, 2, 3
        ]
    }
    func buildBuffers(device: MTLDevice) {
        vertexBuffer = device.makeBuffer(bytes: vertices, length: MemoryLayout<Vertex>.stride * vertices.count, options: [])
        indexBuffer = device.makeBuffer(bytes: indices, length: MemoryLayout<uint16>.size * indices.count, options: [])
    }
}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {    }
    
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable, let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
        
        let commandBuffer = commandQueue.makeCommandBuffer()
        let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        commandEncoder?.setRenderPipelineState(renderPipelineState)
        
        let deltaTime = 1 / Float(view.preferredFramesPerSecond)
        constants.animatedBy += deltaTime
        
        commandEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        commandEncoder?.setVertexBytes(&constants, length: MemoryLayout<Constants>.stride, index: 1)
        
        commandEncoder?.drawIndexedPrimitives(type: .triangle, indexCount: indices.count, indexType: .uint16, indexBuffer: indexBuffer, indexBufferOffset: 0)
        commandEncoder?.endEncoding()
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}
