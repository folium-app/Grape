//
//  DirectoryManager.mm
//  Grape
//
//  Created by Jarrod Norwell on 21/3/2025.
//  Copyright © 2025 Jarrod Norwell. All rights reserved.
//

#import "DirectoryManager.h"

NSURL *savesDirectory(void) {
    return [[[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject] URLByAppendingPathComponent:@"Grape"] URLByAppendingPathComponent:@"saves"];
}

NSURL *sysdataDirectory(void) {
    return [[[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject] URLByAppendingPathComponent:@"Grape"] URLByAppendingPathComponent:@"sysdata"];
}
