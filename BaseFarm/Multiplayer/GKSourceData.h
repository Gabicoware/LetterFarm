//
//  GKSourceData.h
//  LetterFarm
//
//  Created by Daniel Mueller on 3/15/13.
//
//

#import <Foundation/Foundation.h>
#import "MatchInfo.h"

@class GKTurnBasedMatch;

@interface GKSourceData : NSObject

//this is not included in the encoding
@property (nonatomic) GKTurnBasedMatch* match;

@property (nonatomic) int startingDifficulty;
@property (nonatomic) NSArray* games;

@property (nonatomic) id<MatchGame> currentGame;

-(NSData*)archiveData;

-(void)updateWithArchiveData:(NSData*)data;

+(id)sourceDataWithArchiveData:(NSData*)data;

@end
