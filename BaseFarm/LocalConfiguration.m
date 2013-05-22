//
//  LocalConfiguration.m
//  LetterFarm
//
//  Created by Daniel Mueller on 7/26/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import "LocalConfiguration.h"
#import "InAppPurchases.h"
#import "RemoteLoader.h"
#import "NSString+LF.h"

#ifdef DEBUG

#define REMOTE_CONFIGURATION_URL @"http://127.0.0.1/~saltymule/default_config_1.plist"

#else

#define REMOTE_CONFIGURATION_URL @"http://lf.gabicoware.com.s3-website-us-east-1.amazonaws.com/default_config_1.plist"

#endif

#ifdef DEBUG
#define TestGameArgument @"TEST_GAME"
#define TestUrlArgument @"TEST_URL"
#define TestCompleteViewArgument @"TEST_COMPLETE_VIEW"

#endif

@interface NSData (IsPlist)
//an expensive test but it should be run rarely
- (BOOL)isPlist;
@end


@interface LocalConfiguration ()

@property (nonatomic, retain) NSDictionary* configurationDictionary;

@property (nonatomic, retain) RemoteLoader* configLoader;

@property (nonatomic, retain) NSMutableDictionary* loaderDictionary;

@end


@implementation LocalConfiguration

@synthesize configurationDictionary=_configurationDictionary;

+ (id)sharedLocalConfiguration
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
    });
    return _sharedObject;
}

-(id)init{
    if((self = [super init])){
        
        self.loaderDictionary = [NSMutableDictionary dictionary];
        
        NSError* error = nil;
        
        [[NSFileManager defaultManager] createDirectoryAtURL:[self promptImgDirURL]
                                 withIntermediateDirectories:YES
                                                  attributes:nil
                                                       error:&error];
        
        NSString* bundledConfigPath = [[NSBundle bundleForClass:[self class]]
                                       pathForResource:@"default_config" ofType:@"plist"];
        
        //only do this if the file does not exist, we want to maintain the existing version if at all possible
        if(![[NSFileManager defaultManager] fileExistsAtPath:[[self configURL] relativePath]]){
            
            [[NSFileManager defaultManager] moveItemAtPath:bundledConfigPath
                                                    toPath:[[self configURL] relativePath]
                                                    error:&error];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error == nil) {
                [self updateConfiguration];
            }else{
                self.configurationDictionary = [NSDictionary dictionaryWithContentsOfFile:bundledConfigPath];
            }
            [self loadRemoteConfiguration];
        });
        
        
    
        
    }
    return self;
}

#define APP_UUID_KEY @"appUUIDKey"

-(NSString*)appUUID{
    NSString *uuid = [[NSUserDefaults standardUserDefaults] objectForKey:APP_UUID_KEY];
    
    if(uuid == nil){
        CFUUIDRef theUUID = CFUUIDCreate(kCFAllocatorDefault);
        if (theUUID) {
            uuid = CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, theUUID));
            CFRelease(theUUID);
        }
        [[NSUserDefaults standardUserDefaults] setObject:uuid forKey:APP_UUID_KEY];
    }
    
    return uuid;
    
}


-(NSURL*)localImageURLWithString:(NSString*)string{
    
    NSURL* URL = [NSURL URLWithString:string];
    
    NSString* md5 = [string md5HexDigest];
    
    NSString* fileName = [NSString stringWithFormat:@"%@.%@",md5,[URL pathExtension]];
    
    return [[self promptImgDirURL] URLByAppendingPathComponent:fileName];
    
}

-(void)updateConfiguration{
    self.configurationDictionary = [NSDictionary dictionaryWithContentsOfURL:[self configURL]];
    
}

-(void)loadRemoteConfiguration{
    
    self.configLoader = [[RemoteLoader alloc] init];
    
    NSURL* configURL = [self configURL];
    
    void (^completionHandler)(BOOL finished) =^(BOOL finished) {
        if (finished && [_configLoader.receivedData isPlist]) {
            
            NSError* error = nil;
            [[NSFileManager defaultManager] removeItemAtPath:[configURL relativePath] error:&error];
#ifdef DEBUG
            if (error != nil) {NSLog(@"%@", error);}
#endif
            
            [_configLoader.receivedData writeToURL:configURL options:0 error:&error];
            
#ifdef DEBUG
            if (error != nil) {NSLog(@"%@", error);}
#endif
        }
        [[LocalConfiguration sharedLocalConfiguration] updateConfiguration];
        //reload after 1 day
        [[LocalConfiguration sharedLocalConfiguration] performSelector:@selector(loadRemoteConfiguration)
                                                            withObject:nil
                                                            afterDelay:(24.0*60.0*60.0)];
    };
    
    [self.configLoader downloadFileAtURL:[NSURL URLWithString:REMOTE_CONFIGURATION_URL]
                       completionHandler:completionHandler];
    
    
}

-(NSURL*)configURL{
    
    NSArray* URLs = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    
    NSURL* documentsURL = [URLs lastObject];
    
    return [documentsURL URLByAppendingPathComponent:@"config.plist"];
    
}

-(NSURL*)promptImgDirURL{
    
    NSArray* URLs = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    
    NSURL* documentsURL = [URLs lastObject];
    
    return [documentsURL URLByAppendingPathComponent:@"prompt_img"];
    
}


#ifdef DEBUG

-(BOOL)hasTestGame{
    return [self hasTestArgumentWithName:TestGameArgument];
}

-(NSString*)testGameID{
    return [self testArgumentValueWithName:TestGameArgument];
}

-(BOOL)hasTestURL{
    return [self hasTestArgumentWithName:TestUrlArgument];
}

-(NSString*)testURL{
    return [self testArgumentValueWithName:TestUrlArgument];
}

-(BOOL)hasTestCompleteView{
    return [self hasTestArgumentWithName:TestCompleteViewArgument];
}

-(BOOL)hasTestArgumentWithName:(NSString*)argumentName{
    BOOL result = NO;
    
    for (NSString* argument in [[NSProcessInfo processInfo] arguments]) {
        if ([argument rangeOfString:argumentName].location == 0) {
            result = YES;
        }
    }
    
    return result;
}

-(NSString*)testArgumentValueWithName:(NSString*)argumentName{
    
    NSString* result = nil;
    
    for (NSString* argument in [[NSProcessInfo processInfo] arguments]) {
        if ([argument rangeOfString:argumentName].location == 0) {
            
            NSRange equalRange = [argument rangeOfString:@"="];
            
            if (equalRange.location != NSNotFound) {
                result = [argument substringFromIndex:(equalRange.location + equalRange.length)];
            }
        }
    }
    
    return result;
    
}
#endif

-(NSString*)buildVersionString{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

-(int)buildVersion{
    NSString* versionString = [self buildVersionString];
    return [versionString integerValue];
}

-(int)compareToBuildVersion:(NSString*)version{
    int result = 0;
    [[NSScanner scannerWithString:version] scanInt:&result];
    if(result > [self buildVersion]){
        return 1;
    }else if (result < [self buildVersion]){
        return -1;
    }else{
        return 0;
    }
}

@end

@implementation LocalConfiguration (Games)

-(NSUInteger)gameCount{
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"Local_Configuration_Game_Count"];
}

-(void)incrementGameCount{
    NSInteger count = [self gameCount];
    count++;
    [[NSUserDefaults standardUserDefaults] setInteger:count forKey:@"Local_Configuration_Game_Count"];
}

@end

@implementation LocalConfiguration (CustomerSupport)

-(BOOL)hasViewedChanges{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"Local_Configuration_Has_Viewed_Changes"];
}

-(void)setHasViewedChanges:(BOOL)hasViewedChanges{
    [[NSUserDefaults standardUserDefaults] setBool:hasViewedChanges forKey:@"Local_Configuration_Has_Viewed_Changes"];
}

@end

NSString* TileImageNameDidChange = @"TileImageNameDidChange";

@implementation LocalConfiguration (Personalization)

-(BOOL)isUsageTrackingDisabled{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"Local_Configuration_Is_Usage_Tracking_Disabled"];
}

-(void)setIsUsageTrackingDisabled:(BOOL)isUsageTrackingDisabled{
    [[NSUserDefaults standardUserDefaults] setBool:isUsageTrackingDisabled forKey:@"Local_Configuration_Is_Usage_Tracking_Disabled"];
}

-(NSString*)playerName{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"player_name"];
}

-(void)setPlayerName:(NSString *)playerName{
    [[NSUserDefaults standardUserDefaults] setObject:playerName forKey:@"player_name"];
}

-(NSString*)playerEmail{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"player_email"];
}

-(void)setPlayerEmail:(NSString *)playerEmail{
    [[NSUserDefaults standardUserDefaults] setObject:playerEmail forKey:@"player_email"];
}

-(NSString*)tileImageName{
    NSString* result = [[NSUserDefaults standardUserDefaults] stringForKey:@"tile_image_name"];
    
    return result == nil ? DefaultTextureName : result;
}

-(void)setTileImageName:(NSString *)tileImageName{
    if (![tileImageName isEqualToString:[self tileImageName]]) {
        [[NSUserDefaults standardUserDefaults] setObject:tileImageName forKey:@"tile_image_name"];
        [[NSNotificationCenter defaultCenter] postNotificationName:TileImageNameDidChange object:nil];
    }
}

@end


@implementation NSData (IsPlist)

- (BOOL)isPlist
{
	// uses toll-free bridging for data into CFDataRef and CFPropertyList into NSDictionary
	CFPropertyListRef plist =  CFPropertyListCreateFromXMLData(kCFAllocatorDefault, (__bridge CFDataRef)self,
															   kCFPropertyListImmutable,
															   NULL);
    BOOL result = plist != nil;
    if (result) {
		CFRelease(plist);
    }
    
    return result;
}

@end

@implementation NSString (IsURL)

- (BOOL)isURL {
    return [self hasPrefix:@"http://"] || [self hasPrefix:@"https://"];
}

@end

@implementation ImageProviderManager (Default)

-(id)newImageProvider{
    return [self newImageProviderWithName:[[LocalConfiguration sharedLocalConfiguration] tileImageName]];
}

@end


