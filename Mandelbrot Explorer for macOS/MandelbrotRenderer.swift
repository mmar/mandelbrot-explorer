//
//  MandelbrotRenderer.swift
//  Mandelbrot Explorer
//
//  Created by Matusalem Marques on 10/06/2019.
//  Copyright © 2019 Matusalem Marques. All rights reserved.
//

import MetalKit
import simd

class MandelbrotRenderer: NSObject, MTKViewDelegate {
    let limits = CGRect(x: -0.2, y: 0.0, width: 3.5, height: 4.5)
    struct Uniforms {
        var visibleRect: vector_float4
        var maxIterations: UInt32
        var escapeValue: Float
    }

    var origin: CGPoint {
        get {
            return CGPoint(x: CGFloat(uniforms.visibleRect.x), y: CGFloat(uniforms.visibleRect.y))
        }
        set {
            uniforms.visibleRect.x = Float(newValue.x)
            uniforms.visibleRect.y = Float(newValue.y)
        }
    }

    var size: CGSize {
        get {
            return CGSize(width: CGFloat(uniforms.visibleRect.z), height: CGFloat(uniforms.visibleRect.w))
        }
        set {
            uniforms.visibleRect.z = Float(newValue.width)
            uniforms.visibleRect.w = Float(newValue.height)
        }
    }

    var uniforms = Uniforms(visibleRect: vector_float4(-2.5, -1.25, 3.5, 2.5), maxIterations: 100, escapeValue: 16.0)

    @IBOutlet var metalView: MTKView! {
        didSet {
            metalView.device = MTLCreateSystemDefaultDevice()
            metalView.delegate = self
            metalView.isPaused = false
            metalView.framebufferOnly = false

            if let function = metalView.device?.makeDefaultLibrary()?.makeFunction(name: "mandelbrot") {
                computePipelineState = try? metalView.device?.makeComputePipelineState(function: function)
            }

            commandQueue = metalView.device?.makeCommandQueue()

            guard let pipelineState = computePipelineState else { return }

            let threadWidth = pipelineState.threadExecutionWidth
            let threadHeight = pipelineState.maxTotalThreadsPerThreadgroup / threadWidth

            threadsPerThreadgroup = MTLSizeMake(threadWidth, threadHeight, 1)

            threadGroupsPerGrid = MTLSize(width: (Int(metalView.drawableSize.width) + threadWidth - 1) / threadWidth,
                                          height: (Int(metalView.drawableSize.height) + threadHeight - 1) / threadHeight,
                                          depth: 1)
        }
    }

    var computePipelineState: MTLComputePipelineState?
    var commandQueue: MTLCommandQueue?
    var threadsPerThreadgroup: MTLSize!
    var threadsPerGrid: MTLSize!
    var threadGroupsPerGrid: MTLSize!

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        guard let pipelineState = computePipelineState else { return }

        let threadWidth = pipelineState.threadExecutionWidth
        let threadHeight = pipelineState.maxTotalThreadsPerThreadgroup / threadWidth
        threadGroupsPerGrid = MTLSize(width: (Int(size.width) + threadWidth - 1) / threadWidth,
                                      height: (Int(size.height) + threadHeight - 1) / threadHeight,
                                      depth: 1)
    }

    func draw(in view: MTKView) {
        guard let commandBuffer = self.commandQueue?.makeCommandBuffer() else { return }
        guard let encoder = commandBuffer.makeComputeCommandEncoder() else { return }
        guard let pipelineState = computePipelineState else { return }
        guard let drawable = view.currentDrawable else { return }

        encoder.setComputePipelineState(pipelineState)
        encoder.setBytes(&self.uniforms, length: MemoryLayout.size(ofValue: self.uniforms), index: 0)
        encoder.setTexture(drawable.texture, index: 0)
        encoder.dispatchThreadgroups(threadGroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
        encoder.endEncoding()

        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
