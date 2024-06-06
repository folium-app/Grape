//
//  GrapeObjC.mm
//
//
//  Created by Jarrod Norwell on 26/2/2024.
//

#import "GrapeObjC.h"
#import "GrapeDirectoryManager.h"

#include <hqx/hqx.h>
#include <xbrz/xbrz.h>

#include "core.h"
#include "settings.h"
#include "common/nds_icon.h"
#include "common/screen_layout.h"

std::unique_ptr<Core> grapeEmulator;
ScreenLayout screenLayout;

@implementation GrapeObjC
-(GrapeObjC *) init {
    if (self = [super init]) {
        hqxInit();
        
        NSURL *documentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
        NSURL *grapeDirectory = [documentsDirectory URLByAppendingPathComponent:@"Grape"];
        NSURL* sysdataURL = [grapeDirectory URLByAppendingPathComponent:@"sysdata"];
        
        if (!Settings::load([[[grapeDirectory URLByAppendingPathComponent:@"config"]
                              URLByAppendingPathComponent:@"config.ini"].path UTF8String])) {
            Settings::bios7Path = [[sysdataURL URLByAppendingPathComponent:@"bios7.bin"].path UTF8String];
            Settings::bios9Path = [[sysdataURL URLByAppendingPathComponent:@"bios9.bin"].path UTF8String];
            Settings::firmwarePath = [[sysdataURL URLByAppendingPathComponent:@"firmware.bin"].path UTF8String];
            if ([[NSFileManager defaultManager] fileExistsAtPath:[sysdataURL URLByAppendingPathComponent:@"gba_bios.bin"].path]) {
                Settings::gbaBiosPath = [[sysdataURL URLByAppendingPathComponent:@"gba_bios.bin"].path UTF8String];
            } else {
                Settings::gbaBiosPath = "";
            }
            Settings::sdImagePath = [[sysdataURL URLByAppendingPathComponent:@"sdcard.img"].path UTF8String];
            Settings::save();
        } else {
            Settings::bios7Path = [[sysdataURL URLByAppendingPathComponent:@"bios7.bin"].path UTF8String];
            Settings::bios9Path = [[sysdataURL URLByAppendingPathComponent:@"bios9.bin"].path UTF8String];
            Settings::firmwarePath = [[sysdataURL URLByAppendingPathComponent:@"firmware.bin"].path UTF8String];
            if ([[NSFileManager defaultManager] fileExistsAtPath:[sysdataURL URLByAppendingPathComponent:@"gba_bios.bin"].path]) {
                Settings::gbaBiosPath = [[sysdataURL URLByAppendingPathComponent:@"gba_bios.bin"].path UTF8String];
            } else {
                Settings::gbaBiosPath = "";
            }
            Settings::sdImagePath = [[sysdataURL URLByAppendingPathComponent:@"sdcard.img"].path UTF8String];
            Settings::save();
        }
    } return self;
}

+(GrapeObjC *) sharedInstance {
    static dispatch_once_t onceToken;
    static GrapeObjC *sharedInstance = NULL;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(void) insertGame:(NSURL * _Nullable)url {
    NSURL *savesDirectory = [[[url URLByDeletingLastPathComponent] URLByDeletingLastPathComponent] URLByAppendingPathComponent:@"saves"];
    NSString *gameName = [url.lastPathComponent stringByReplacingOccurrencesOfString:url.pathExtension withString:@"sav"];
    const char* saveName = [[savesDirectory URLByAppendingPathComponent:gameName].path UTF8String];
    
    if (url && [url.pathExtension.lowercaseString isEqualToString:@"nds"]) {
        grapeEmulator = std::make_unique<Core>([url.path UTF8String], "", saveName, "");
    } else if (url && [url.pathExtension.lowercaseString isEqualToString:@"gba"]) {
        grapeEmulator = std::make_unique<Core>("", [url.path UTF8String], "", saveName);
    } else {
        grapeEmulator = std::make_unique<Core>("", "");
    }
}

-(void) step {
    stop_run = false;
    pause_emulation = false;
    
    while (!stop_run) {
        if (!pause_emulation) {
            grapeEmulator->runFrame();
            if (grapeEmulator->gbaMode)
                grapeEmulator->cartridgeGba.writeSave();
            else
                grapeEmulator->cartridgeNds.writeSave();
        }
    }
}

-(void) setPaused:(BOOL)isPaused {
    pause_emulation = isPaused;
}

-(BOOL) isPaused {
    return pause_emulation;
}

-(uint32_t *) icon:(NSURL *)url {
    NdsIcon cartridge([url.path UTF8String]);
    static std::vector<uint32_t> buffer(32 * 32);
    memcpy(buffer.data(), cartridge.getIcon(), 32 * 32 * sizeof(uint32_t));
    return buffer.data();
}

-(int16_t *) audioBuffer {
    static std::vector<int16_t> buffer(1024 * 2);
    const auto original = grapeEmulator->spu.getSamples(699);
    for (int i = 0; i < 1024; i++) {
        uint32_t sample = original[i * 699 / 1024];
        buffer[i * 2 + 0] = sample >>  0;
        buffer[i * 2 + 1] = sample >> 16;
    }
    delete[] original;
    return buffer.data();
}

-(uint32_t*) videoBuffer:(BOOL)isGBA {
    static std::vector<uint32_t> framebuffer;
    if (isGBA)
        framebuffer.resize(240 * 160);
    else
        framebuffer.resize(256 * 192 * 2);
    grapeEmulator->gpu.getFrame(framebuffer.data(), isGBA);
    
    switch ([self useUpscalingFilter]) {
        case 0: {
            const auto upscalingFactor = [self useUpscalingFactor];
            static std::vector<uint32_t> upscaled(((isGBA ? 240 : 256) * upscalingFactor) * ((isGBA ? 160 : (192 * 2)) * upscalingFactor));
            switch (upscalingFactor) {
                case 2:
                default:
                    hq2x_32(framebuffer.data(), upscaled.data(), isGBA ? 240 : 256, isGBA ? 160 : (192 * 2));
                    break;
                case 3:
                    hq3x_32(framebuffer.data(), upscaled.data(), isGBA ? 240 : 256, isGBA ? 160 : (192 * 2));
                    break;
                case 4:
                    hq4x_32(framebuffer.data(), upscaled.data(), isGBA ? 240 : 256, isGBA ? 160 : (192 * 2));
                    break;
            }
            return upscaled.data();
        }
        case 1: {
            const auto upscalingFactor = [self useUpscalingFactor];
            static std::vector<uint32_t> upscaled(((isGBA ? 240 : 256) * upscalingFactor) * ((isGBA ? 160 : (192 * 2)) * upscalingFactor));
            xbrz::scale(upscalingFactor, framebuffer.data(), upscaled.data(), isGBA ? 240 : 256, isGBA ? 160 : (192 * 2), xbrz::ColorFormat::ARGB);
            return upscaled.data();
        }
        case 2: {
            const auto upscalingFactor = [self useUpscalingFactor];
            static std::vector<uint32_t> upscaled(((isGBA ? 240 : 256) * upscalingFactor) * ((isGBA ? 160 : (192 * 2)) * upscalingFactor));
            xbrz::nearestNeighborScale(framebuffer.data(), isGBA ? 240 : 256, isGBA ? 160 : (192 * 2), upscaled.data(),
                                       ((isGBA ? 240 : 256) * upscalingFactor), ((isGBA ? 160 : (192 * 2)) * upscalingFactor));
            return upscaled.data();
        }
        case -1:
        default:
            return framebuffer.data();
    }
}

-(void) updateScreenLayout:(CGSize)size {
    screenLayout.update(size.width, size.height, false);
}

-(void) touchBeganAtPoint:(CGPoint)point {
    grapeEmulator->input.pressScreen();
    
    auto x = screenLayout.getTouchX(point.x, point.y);
    auto y = screenLayout.getTouchY(point.x, point.y);
    
    grapeEmulator->spi.setTouch(x, y);
}

-(void) touchEnded {
    grapeEmulator->input.releaseScreen();
    grapeEmulator->spi.clearTouch();
}

-(void) touchMovedAtPoint:(CGPoint)point {
    auto x = screenLayout.getTouchX(point.x, point.y);
    auto y = screenLayout.getTouchY(point.x, point.y);
    
    grapeEmulator->spi.setTouch(x, y);
}

-(void) virtualControllerButtonDown:(int)button {
    grapeEmulator->input.pressKey(button);
}

-(void) virtualControllerButtonUp:(int)button {
    grapeEmulator->input.releaseKey(button);
}

-(int) useHighRes3D {
    return Settings::highRes3D;
}

-(void) setHighRes3D:(int)highRes3D {
    Settings::highRes3D = highRes3D;
    Settings::save();
}

-(int) useUpscalingFilter {
    return Settings::upscalingFilter;
}

-(void) setUpscalingFilter:(int)upscalingFilter {
    Settings::upscalingFilter = upscalingFilter;
    Settings::save();
}

-(int) useUpscalingFactor {
    return Settings::upscalingFactor;
}

-(void) setUpscalingFactor:(int)upscalingFactor {
    Settings::upscalingFactor = upscalingFactor;
    Settings::save();
}

-(int) useDirectBoot {
    return Settings::directBoot;
}

-(void) setDirectBoot:(int)directBoot {
    Settings::directBoot = directBoot;
    Settings::save();
}
@end
