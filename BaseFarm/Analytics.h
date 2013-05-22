//
//  Analytics.h
//  LetterFarm
//
//  Created by Daniel Mueller on 8/12/12.
//
//

#import <Foundation/Foundation.h>

@interface Analytics : NSObject

+(id)sharedAnalytics;

-(void)startup;

-(void)trackCategory:(NSString*)category action:(NSString*)action label:(NSString*)label value:(int)value;

@end

@interface NSObject(Tracking)

-(NSString*)categoryName;
-(void)trackScreen:(NSString*)name;
-(void)trackEvent:(NSString*)name;

@end
