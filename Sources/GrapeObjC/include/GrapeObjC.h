//
//  GrapeObjC.h
//  Grape
//
//  Created by Jarrod Norwell on 8/8/2024.
//

#import <Foundation/Foundation.h>

#ifdef __cplusplus
#include <atomic>
#include <condition_variable>
#include <mutex>
#include <thread>
#endif

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, CartridgeType) {
    GBA,
    NDS
};

@interface GrapeObjC : NSObject {
#ifdef __cplusplus
    BOOL isRunning;
    std::thread *coreThread, *saveThread;
#endif
    BOOL isGBA;
    NSURL *url;
}

@property (nonatomic, strong) void (^buffer) (uint32_t*);

+(GrapeObjC *) sharedInstance NS_SWIFT_NAME(shared());

-(uint32_t*) iconForCartridge:(NSURL *)url NS_SWIFT_NAME(iconForCartridge(at:));
-(NSString *) titleForCartridge:(NSURL *)url NS_SWIFT_NAME(titleForCartridge(at:));

-(CartridgeType) insertCartridge:(NSURL *)url NS_SWIFT_NAME(insertCartridge(at:));
-(void) updateScreenLayout:(CGSize)size;

-(void) stopCore:(BOOL)full;
-(void) startCore:(BOOL)full;

-(BOOL) running;

-(void) pause;
-(void) stop;
-(void) start;

-(int16_t*) audioBuffer;
-(void) microphoneBuffer:(int16_t*)buffer;
-(uint32_t*) videoBuffer;
-(CGSize) videoBufferSize;

-(BOOL) loadState;
-(BOOL) saveState;

-(void) touchBeganAtPoint:(CGPoint)point;
-(void) touchEnded;
-(void) touchMovedAtPoint:(CGPoint)point;

-(void) virtualControllerButtonDown:(int)button;
-(void) virtualControllerButtonUp:(int)button;

-(void) updateSettings;
@end

NS_ASSUME_NONNULL_END
