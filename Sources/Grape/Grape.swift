//
//  Grape.swift
//
//
//  Created by Jarrod Norwell on 26/2/2024.
//

import GrapeObjC
import Foundation

public struct Grape {
    public static let shared = Grape()
    
    fileprivate let grapeObjC = GrapeObjC.shared()
    
    public func insert(game url: URL) {
        grapeObjC.insert(game: url)
    }
    
    public func step() {
        grapeObjC.step()
    }
    
    public func setPaused(_ isPaused: Bool) {
        grapeObjC.setPaused(isPaused)
    }
    
    public func isPaused() -> Bool {
        grapeObjC.isPaused()
    }
    
    public func icon(_ url: URL) -> UnsafeMutablePointer<UInt32> {
        grapeObjC.icon(from: url)
    }
    
    public func audioBuffer() -> UnsafeMutablePointer<Int16> {
        grapeObjC.audioBuffer()
    }
    
    public func videoBuffer(isGBA: Bool) -> UnsafeMutablePointer<UInt32> {
        grapeObjC.videoBuffer(isGBA)
    }
    
    public func updateScreenLayout(with size: CGSize) {
        grapeObjC.updateScreenLayout(size)
    }
    
    public func touchBegan(at point: CGPoint) {
        grapeObjC.touchBegan(at: point)
    }
    
    public func touchEnded() {
        grapeObjC.touchEnded()
    }
    
    public func touchMoved(at point: CGPoint) {
        grapeObjC.touchMoved(at: point)
    }
    
    public func virtualControllerButtonDown(_ button: Int32) {
        grapeObjC.virtualControllerButtonDown(button)
    }
    
    public func virtualControllerButtonUp(_ button: Int32) {
        grapeObjC.virtualControllerButtonUp(button)
    }
    
    public func useHighRes3D() -> Int32 {
        grapeObjC.useHighRes3D()
    }
    
    public func setHighRes3D(_ highRes3D: Int32) {
        grapeObjC.setHighRes3D(highRes3D)
    }
    
    public func useUpscalingFilter() -> Int32 {
        grapeObjC.useUpscalingFilter()
    }
    
    public func setUpscalingFilter(_ upscalingFilter: Int32) {
        grapeObjC.setUpscalingFilter(upscalingFilter)
    }
    
    public func useUpscalingFactor() -> Int32 {
        grapeObjC.useUpscalingFactor()
    }
    
    public func setUpscalingFactor(_ upscalingFactor: Int32) {
        grapeObjC.setUpscalingFactor(upscalingFactor)
    }
    
    public func useDirectBoot() -> Int32 {
        grapeObjC.useDirectBoot()
    }
    
    public func setDirectBoot(_ directBoot: Int32) {
        grapeObjC.setDirectBoot(directBoot)
    }
}
