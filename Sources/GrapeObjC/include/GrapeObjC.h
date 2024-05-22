//
//  GrapeObjC.h
//  
//
//  Created by Jarrod Norwell on 26/2/2024.
//

#import <Foundation/Foundation.h>

#ifdef __cplusplus
#include <algorithm>
#include <cstdint>
#include <vector>
#endif

NS_ASSUME_NONNULL_BEGIN

@protocol GrapeMicProtocol <NSObject>
-(void) send:(const int16_t*)microphoneData sampleRate:(size_t)sampleRate NS_SWIFT_NAME(send(microphoneData:sampleRate:));
@end

@interface GrapeObjC : NSObject
@property (nonatomic, strong) id<GrapeMicProtocol> microphoneDelegate;

+(GrapeObjC *) sharedInstance NS_SWIFT_NAME(shared());
-(void) insertGame:(NSURL * _Nullable)url directBoot:(BOOL)directBoot NS_SWIFT_NAME(insert(game:directBoot:));
-(void) step;

-(uint32_t*) icon:(NSURL *)url NS_SWIFT_NAME(icon(from:));

-(int16_t*) audioBuffer;
-(uint32_t*) videoBuffer:(BOOL)isGBA;
-(void) updateScreenLayout:(CGSize)size;

-(void) touchBeganAtPoint:(CGPoint)point;
-(void) touchEnded;
-(void) touchMovedAtPoint:(CGPoint)point;

-(void) virtualControllerButtonDown:(int)button;
-(void) virtualControllerButtonUp:(int)button;

-(int) useHighRes3D;
-(void) setHighRes3D:(int)highRes3D;

-(int) useUpscalingFilter;
-(void) setUpscalingFilter:(int)upscalingFilter;

-(int) useUpscalingFactor;
-(void) setUpscalingFactor:(int)upscalingFactor;
@end

NS_ASSUME_NONNULL_END
