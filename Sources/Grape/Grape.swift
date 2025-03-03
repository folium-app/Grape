// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import GrapeObjC

public struct Grape : @unchecked Sendable {
    public static let shared = Grape()
    
    fileprivate let grapeObjC = GrapeObjC.shared()
    
    public func information(for cartridge: URL) -> (icon: UnsafeMutablePointer<UInt32>, title: String) {
        (grapeObjC.iconForCartridge(at: cartridge), grapeObjC.titleForCartridge(at: cartridge))
    }
    
    public func insertCartridge(from url: URL) -> CartridgeType {
        grapeObjC.insertCartridge(at: url)
    }
    
    public func updateScreenLayout(with size: CGSize) {
        grapeObjC.updateScreenLayout(size)
    }
    
    public func pause() {
        grapeObjC.pause()
    }
    
    public func stop() {
        grapeObjC.stop()
    }
    
    public func start() { grapeObjC.start() }
    
    public func running() -> Bool { grapeObjC.running() }
    
    public func audioBuffer() -> UnsafeMutablePointer<Int16> {
        grapeObjC.audioBuffer()
    }
    
    public func microphoneBuffer(with buffer: UnsafeMutablePointer<Int16>) {
        grapeObjC.microphoneBuffer(buffer)
    }
        
    public func framebuffer(_ framebuffer: @escaping (UnsafeMutablePointer<UInt32>) -> Void) { grapeObjC.buffer = framebuffer }
    
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
    
    public func loadState() { grapeObjC.loadState() }
    public func saveState() { grapeObjC.saveState() }
}
