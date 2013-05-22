//
//  EmailMatch.h
//  LetterFarm
//
//  Created by Daniel Mueller on 12/28/12.
//
//

#import <Foundation/Foundation.h>
#import "MatchInfo.h"

@interface EmailMatch : NSObject<NSCoding>

@property (nonatomic) NSString* matchID;

@property (nonatomic) NSArray* games;

@property (nonatomic) NSDate* creationDate;

@property (nonatomic) int timeSinceEpoch;

@property (nonatomic) MatchStatus matchStatus;

@property (nonatomic) BOOL isSource;

//the player that initiated the match
//stays constant for both players
@property (nonatomic) NSString* sourceEmail;

//the player that the match was sent to
//stays constant for both players
@property (nonatomic) NSString* targetEmail;

@end

