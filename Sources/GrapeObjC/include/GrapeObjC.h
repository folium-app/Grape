//
//  GrapeObjC.h
//  Grape
//
//  Created by Jarrod Norwell on 8/8/2024.
//

#import <Foundation/Foundation.h>

#ifdef __cplusplus
#include <atomic>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface GrapeObjC : NSObject {
#ifdef __cplusplus
    std::atomic_bool stop_run;
    std::atomic_bool pause_emulation;
#endif
    BOOL isGBA;
}

+(GrapeObjC *) sharedInstance NS_SWIFT_NAME(shared());

-(uint32_t*) iconForGameAtURL:(NSURL *)url;
-(NSString *) titleForGameAtURL:(NSURL *)url;

-(void) insertGame:(NSURL *)url NS_SWIFT_NAME(insert(game:));
-(void) updateScreenLayout:(CGSize)size;

-(BOOL) togglePause;
-(void) stop;

-(void) step;
-(int16_t*) audioBuffer;
-(void) microphoneBuffer:(int16_t*)buffer;
-(uint32_t*) videoBuffer;
-(CGSize) videoBufferSize;

-(void) touchBeganAtPoint:(CGPoint)point;
-(void) touchEnded;
-(void) touchMovedAtPoint:(CGPoint)point;

-(void) virtualControllerButtonDown:(int)button;
-(void) virtualControllerButtonUp:(int)button;

-(void) updateSettings;
@end

NS_ASSUME_NONNULL_END
