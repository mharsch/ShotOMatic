//
//  ShotRecord.h
//  ShotProto
//
//  Created by Michael Harsch on 2/1/11.
//  Copyright 2011 Harsch Systems Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShotRecord : NSObject
{
	NSString *name;
	NSString *description;
	NSString *category;
    BOOL favorite;
}
@property (retain) NSString *name;
@property (retain) NSString *description;
@property (retain) NSString *category;
@property BOOL favorite;

@end
