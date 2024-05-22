//
//  GrapeSysDataDirectoryManager.mm
//
//
//  Created by Jarrod Norwell on 26/2/2024.
//

#import <Foundation/Foundation.h>

#import "GrapeDirectoryManager.h"

const char* GrapeDirectory() {
    return [[[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject]
             URLByAppendingPathComponent:@"Grape"].path UTF8String];
}
