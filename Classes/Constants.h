//
//  Constants.h
//  ShotOMatic
//
//  Created by Michael Harsch on 2/11/11.
//  Copyright 2011 Harsch Systems Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


extern int const numPages;
extern bool const analyticsEnabled;
extern NSString * const kDaredevilImagePath;
extern NSString * const kProImagePath;
extern NSString * const kRookieImagePath;
extern NSString * const kFBAppId;
extern NSString * const kFlurryId;

//RGB color macro (used for setting shot name text in ShotPickViewController)
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

//Used to check iOS version
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)