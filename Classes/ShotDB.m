//
//  ShotDB.m
//  ShotProto
//
//  Created by Michael Harsch on 2/1/11.
//  Copyright 2011 Harsch Systems Inc. All rights reserved.
//

#import "ShotDB.h"
#import "ShotRecord.h"

@interface ShotDB()
@property (readonly) NSDictionary *shotPropertyList;
@end

@implementation ShotDB 

@synthesize favoriteSet;
@synthesize favoritesUpdated;

+ (ShotDB *)instance
{
    static ShotDB *instance;
    @synchronized(self) {
        if (!instance) {
            instance = [[ShotDB alloc] init];
        }
    }
    return instance;
}

/* Lazily instantiate the setPropertyList instance variable by overriding the getter */
- (NSDictionary *)shotPropertyList
{
	if (!shotPropertyList) {

		NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
		NSString *filePath = [bundlePath stringByAppendingPathComponent:@"ShotDB.plist"];
		shotPropertyList = [[NSDictionary alloc] initWithContentsOfFile:filePath];
	}
	
	return shotPropertyList;
}

- (NSArray *)shotRecordList
{
    if (favoritesUpdated) {
        shotRecordList = nil;
        favoritesUpdated = NO;
    }
    
    if (!shotRecordList) {
        
        ShotRecord *tmpRecord = nil;
        NSMutableArray *tmpArray = nil;
        NSUInteger listSize = 0;

        for (NSString *tmpKey in self.shotPropertyList) {
            listSize += [[self.shotPropertyList objectForKey:tmpKey] count];
        }
        tmpArray = [[NSMutableArray alloc] initWithCapacity:listSize];
        
        for (NSString *tmpCategory in self.shotPropertyList) {
            for (NSString *tmpKey in [[self.shotPropertyList objectForKey:tmpCategory] allKeys]) {
                tmpRecord = [[ShotRecord alloc] init];
                tmpRecord.name = tmpKey;
                tmpRecord.description = [[self.shotPropertyList objectForKey:tmpCategory] objectForKey:tmpKey];
                tmpRecord.category = tmpCategory;
                if ([[ShotDB instance].favoriteSet containsObject:tmpKey])
                    tmpRecord.favorite = YES;
                [tmpArray addObject:tmpRecord];
                [tmpRecord release];
            }
        }
        
        [tmpArray sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
        shotRecordList = [[NSArray arrayWithArray:tmpArray] retain];
        [tmpArray release];
    }
    
    return shotRecordList;
}

- (NSMutableSet *)favoriteSet
{
    if (!favoriteSet) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults objectForKey:@"favorites"]) {
            favoriteSet = [[NSMutableSet alloc] initWithSet:[NSSet setWithArray:[defaults arrayForKey:@"favorites"]]];
        } else {
            favoriteSet = [[NSMutableSet alloc] initWithObjects: @"Warm Blanket", @"Panty Burner", @"El Diablo", @"Kamikaze", @"Lemon Drop", nil];
        }
    }
    return favoriteSet;
}

- (ShotRecord *)pickAShot
{	
	/* Pick a random category and then call pickAShot:withCategory: */
	NSArray *tmpArray = [self.shotPropertyList allKeys];
	int tmpIndex = arc4random() % tmpArray.count;
	NSString *tmpString = [tmpArray objectAtIndex:tmpIndex];
	
	return [self pickAShotWithCategory:tmpString];
	
}

- (ShotRecord *)pickAShotWithCategory:(NSString *)category
{
	ShotRecord *tmpShot = [[ShotRecord alloc] init];
	
	NSDictionary *tmpDictionary = [self.shotPropertyList objectForKey:category];
	
	if (tmpDictionary) {
		NSArray *tmpArray = [tmpDictionary allKeys];
		
		int tmpIndex = arc4random() % tmpArray.count;
		
		NSString *tmpString = [tmpArray objectAtIndex:tmpIndex];
		tmpShot.name = tmpString;
		tmpShot.description = [tmpDictionary objectForKey:tmpString];
		tmpShot.category = category;
		
	} else {
		//NSLog(@"Failed to retrieve Dictionary for category\n");
	}
    
	return [tmpShot autorelease];
}

- (NSSet *)pickShotGroup:(int)groupSize withCategory:(NSString *)category
{
	ShotRecord *tmpRecord = [self pickAShotWithCategory:category];
	
	if (!tmpRecord) {
		//NSLog(@"problem getting first record\n");
	}
	
	NSMutableSet *tmpSet = [[NSMutableSet alloc] initWithCapacity:groupSize];
	[tmpSet addObject:tmpRecord];
	
    NSMutableArray *tmpArray = [NSMutableArray arrayWithCapacity:groupSize];
    [tmpArray addObject:tmpRecord.name];
    
	while ([tmpSet count] < groupSize) {
		
		tmpRecord = nil;
		tmpRecord = [self pickAShotWithCategory:category];
		if (!tmpRecord) {
			//NSLog(@"problem getting subsequent record\n");
		}
		
        if ([tmpArray containsObject:tmpRecord.name]) {
            continue;
        }
        [tmpArray addObject:tmpRecord.name];
        
		[tmpSet addObject:tmpRecord];
	}
	
	NSSet *returnSet = [NSSet setWithSet:tmpSet];
	[tmpSet release];
	
	return returnSet;
	
}

- (NSSet *)pickShotGroup:(int)groupSize
{
	NSArray *tmpArray = [self.shotPropertyList allKeys];
	int tmpIndex = arc4random() % tmpArray.count;
	NSString *tmpString = [tmpArray objectAtIndex:tmpIndex];
	
	ShotRecord *tmpRecord = [self pickAShotWithCategory:tmpString];
	
	NSMutableSet *tmpSet = [[NSMutableSet alloc] initWithCapacity:groupSize];
	[tmpSet addObject:tmpRecord];
	
	while ([tmpSet count] < groupSize) {
		tmpIndex = arc4random() % tmpArray.count;
		tmpString = [tmpArray objectAtIndex:tmpIndex];
		
		tmpRecord = nil;
		tmpRecord = [self pickAShotWithCategory:tmpString];

		[tmpSet addObject:tmpRecord];
	}
	
	NSSet *returnSet = [NSSet setWithSet:tmpSet];
	[tmpSet release];
	
	return returnSet;

}

- (void)dealloc
{
	[shotPropertyList release];
    [shotRecordList release];
    [favoriteSet release];
	[super dealloc];
}
@end
