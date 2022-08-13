//
//  Filter.swift
//  Perfect Loop Maker
//
//  Created by Sviatoslav Belmeha on 09.07.2022.
//

import Foundation
import MetalPetal
import Vision
import VideoIO

class SmoothTransitionFilter: MTIFilter {
    var firstImage: MTIImage?
    var secondImage: MTIImage?
    
    var currentTime: Double = 0
    var startTime: Double = 0
    var endTime: Double = 0
    
    var quality: Int = 0
    var blurVal: Double = 0
    var scaleVal: Double = 0
    
    var outputPixelFormat: MTLPixelFormat = .rgba8Unorm
    
    var renderContext: MTIContext!
    
    static let shader = MTIRenderPipelineKernel(vertexFunctionDescriptor: .passthroughVertex, fragmentFunctionDescriptor: MTIFunctionDescriptor(name: "filter_fragment", in: .main))
    
    var outputImage: MTIImage? {
        var opticalFlowImage: MTIImage?
        if let firstImage = firstImage, let secondImage = secondImage {
            let size = CGSize(width: Int(firstImage.size.width/scaleVal), height: Int(firstImage.size.height/scaleVal))
            
            let firstFramePixelBuffer = createPixelBuffer(from: prepareImageForOpticalFlow(image: firstImage, size: size), size: size)
            let secondFramePixelBuffer = createPixelBuffer(from: prepareImageForOpticalFlow(image: secondImage, size: size), size: size)
            
            let opticalFlowPixelBuffer = createOpticalFlowPixelBuffer(
                firstPixelBuffer: firstFramePixelBuffer,
                secondPixelBuffer: secondFramePixelBuffer
            )
            
            opticalFlowImage = createImage(from: opticalFlowPixelBuffer, size: size)
        }
        
        let firstImage = firstImage ?? .black
        let secondImage = secondImage ?? .black
    
        return SmoothTransitionFilter.shader.apply(
            to: [firstImage, secondImage, opticalFlowImage ?? .black],
            parameters: ["time": currentTime, "startTime": startTime, "endTime": endTime],
            outputDimensions: firstImage.dimensions
        )
    }
    
    private func prepareImageForOpticalFlow(image: MTIImage, size: CGSize) -> MTIImage {
        let scaledImage = MTIUnaryImageRenderingFilter.image(
            byProcessingImage: image,
            orientation: .up,
            parameters: [:],
            outputPixelFormat: .unspecified,
            outputImageSize: size
        )
        
        let blur = MTIMPSGaussianBlurFilter()
        blur.radius = Float(blurVal)
        blur.inputImage = scaledImage
        let bluredImage = blur.outputImage!
        return bluredImage
    }
    
    private func createOpticalFlowPixelBuffer(firstPixelBuffer: CVPixelBuffer, secondPixelBuffer: CVPixelBuffer) -> CVPixelBuffer {
        var pixelBuffer: CVPixelBuffer!
        
        let request = VNGenerateOpticalFlowRequest(targetedCVPixelBuffer: secondPixelBuffer, orientation: .up)
        request.revision = VNGenerateOpticalFlowRequestRevision1
        request.computationAccuracy = VNGenerateOpticalFlowRequest.ComputationAccuracy(rawValue: UInt(quality))!
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: firstPixelBuffer, options: [:])
        try! requestHandler.perform([request])

        let observation = request.results!.first!
        pixelBuffer = observation.pixelBuffer
        
        return pixelBuffer
    }
    
    private func createImage(from pixelBuffer: CVPixelBuffer?, size: CGSize) -> MTIImage {
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .rg32Float,
            width: Int(size.width),
            height: Int(size.height),
            mipmapped: false
        )

        let image = pixelBuffer != nil ? MTIImage(cvPixelBuffer: pixelBuffer!, planeIndex: 0, textureDescriptor: textureDescriptor, alphaType: MTIAlphaType.alphaIsOne) : .black
        return image
    }
    
    private func createPixelBuffer(from image: MTIImage, size: CGSize) -> CVPixelBuffer {
        var pixelBuffer: CVPixelBuffer!
        CVPixelBufferCreate(kCFAllocatorDefault, Int(size.width), Int(size.height), kCVPixelFormatType_32BGRA, [kCVPixelBufferIOSurfacePropertiesKey as String: [:]] as CFDictionary, &pixelBuffer)

        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        defer {
            CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
        }
       
        try! self.renderContext.render(image, to: pixelBuffer)
        return pixelBuffer
    }
}
