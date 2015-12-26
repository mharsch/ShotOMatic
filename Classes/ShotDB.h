//
//  ShotDB.h
//  ShotProto
//
//  Created by Michael Harsch on 2/1/11.
//  Copyright 2011 Harsch Systems Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShotRecord.h"

@interface ShotDB : NSObject
{
	NSDictionary *shotPropertyList;
    NSMutableSet *favoriteSet;
    NSArray *shotRecordList;
    BOOL favoritesUpdated;
}

@property (nonatomic,retain) NSMutableSet *favoriteSet;
@property (readonly) NSArray *shotRecordList;
@property (nonatomic) BOOL favoritesUpdated;

/* ShotDB is designed as a singleton resource */

+ (ShotDB *)instance;

- (ShotRecord *)pickAShot;
- (ShotRecord *)pickAShotWithCategory:(NSString *)category;
- (NSSet *)pickShotGroup:(int)groupSize;
- (NSSet *)pickShotGroup:(int)groupSize withCategory:(NSString *)category;


@end
