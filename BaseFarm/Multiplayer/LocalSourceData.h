//
//  LocalSourceData.h
//  LetterFarm
//
//  Created by Daniel Mueller on 1/13/13.
//
//

#import <Foundation/Foundation.h>
#import "MatchInfo.h"

@interface LocalSourceData:NSObject<NSCoding>

@property (nonatomic) NSString* matchID;

@property (nonatomic) NSArray* games;

@property (nonatomic) id<MatchGame> currentGame;

@property (nonatomic) NSDate* creationDate;

@property (nonatomic) MatchStatus matchStatus;

@property (nonatomic) int startingDifficulty;

-(NSDate*)updatedDate;

@end

