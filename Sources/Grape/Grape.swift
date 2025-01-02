// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import GrapeObjC

public struct Grape : @unchecked Sendable {
    public static let shared = Grape()
    
    fileprivate let grapeObjC = GrapeObjC.shared()
    
    public func informationForGame(at url: URL) -> (icon: UnsafeMutablePointer<UInt32>, title: String) {
        (grapeObjC.iconForGame(at: url), grapeObjC.titleForGame(at: url))
    }
    
    public func insertCartridge(from url: URL) {
        grapeObjC.insert(game: url)
    }
    
    public func updateScreenLayout(with size: CGSize) {
        grapeObjC.updateScreenLayout(size)
    }
    
    public func togglePause() -> Bool {
        grapeObjC.togglePause()
    }
    
    public func stop() {
        grapeObjC.stop()
    }
    
    public func step() {
        grapeObjC.step()
    }
    
    public func audioBuffer() -> UnsafeMutablePointer<Int16> {
        grapeObjC.audioBuffer()
    }
    
    public func microphoneBuffer(with buffer: UnsafeMutablePointer<Int16>) {
        grapeObjC.microphoneBuffer(buffer)
    }
        
    public func videoBuffer() -> UnsafeMutablePointer<UInt32> {
        grapeObjC.videoBuffer()
    }
    
    public func videoBufferSize() -> CGSize {
        grapeObjC.videoBufferSize()
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
    
    public func input(_ button: Int32, _ pressed: Bool) {
        if pressed {
            grapeObjC.virtualControllerButtonDown(button)
        } else {
            grapeObjC.virtualControllerButtonUp(button)
        }
    }
    
    public func updateSettings() {
        grapeObjC.updateSettings()
    }
}
