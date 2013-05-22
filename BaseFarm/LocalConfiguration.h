//
//  LocalConfiguration.h
//  LetterFarm
//
//  Created by Daniel Mueller on 7/26/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageProviderManager.h"

@interface LocalConfiguration : NSObject

+ (id)sharedLocalConfiguration;

#ifdef DEBUG

@property (nonatomic, readonly) BOOL hasTestGame;
@property (nonatomic, readonly) NSString* testGameID;

@property (nonatomic, readonly) BOOL hasTestURL;
@property (nonatomic, readonly) NSString* testURL;

@property (nonatomic, readonly) BOOL hasTestCompleteView;

#endif

@property (nonatomic, readonly) int buildVersion;

//! 1 if the provided version is greater, -1 if the provided version is lesser, 0 if the versions are equal
-(int)compareToBuildVersion:(NSString*)version;

-(NSString*)buildVersionString;

-(NSURL*)localImageURLWithString:(NSString*)string;

//!A unique id identifying an installation of the app
@property (nonatomic, readonly) NSString* appUUID;

@end

@interface LocalConfiguration (Games)

@property (nonatomic, readonly) NSUInteger gameCount;

-(void)incrementGameCount;

@end

@interface LocalConfiguration (CustomerSupport)

@property (nonatomic) BOOL hasViewedChanges;

@end

@interface NSString (IsURL)

-(BOOL)isURL;

@end

extern NSString* TileImageNameDidChange;

@interface LocalConfiguration (Personalization)

@property (nonatomic) BOOL isUsageTrackingDisabled;

@property (nonatomic) NSString* playerName;

@property (nonatomic) NSString* playerEmail;

@property (nonatomic) NSString* tileImageName;

@end

@interface ImageProviderManager (Default)

-(id)newImageProvider;

@end
