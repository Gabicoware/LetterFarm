//
//  EmailMatchEngine.h
//  LetterFarm
//
//  Created by Daniel Mueller on 12/23/12.
//
//

#import <Foundation/Foundation.h>
#import "MatchInfo.h"
#import "MatchEngine.h"

@interface EmailMatchEngine : NSObject<MatchEngine>

+(id)sharedEmailMatchEngine;

-(void)setPlayerID:(NSString*)playerID;

-(BOOL)handleOpenURL:(NSURL*)url;

-(void)sendEmailForMatch:(MatchInfo*)matchInfo;
@end
