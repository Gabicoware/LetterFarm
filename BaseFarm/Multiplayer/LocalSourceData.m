//
//  LocalSourceData.m
//  LetterFarm
//
//  Created by Daniel Mueller on 1/13/13.
//
//

#import "LocalSourceData.h"

#define matchIDKEY @"matchID"
#define gamesKEY @"games"
#define creationDateKEY @"creationDate"
#define matchStatusKEY @"matchStatus"
#define startingDifficultyKEY @"startingDifficulty"
#define currentGameKEY @"currentGame"

@implementation LocalSourceData

@synthesize matchID=_matchID;
@synthesize games=_games;
@synthesize creationDate=_creationDate;
@synthesize matchStatus=_matchStatus;
@synthesize startingDifficulty=_startingDifficulty;
@synthesize currentGame=_currentGame;

-(id)init{
    if((self = [super init])){
        self.matchID = [NSString stringWithFormat:@"%@-%@", [[NSDate date] description], NSStringFromClass([self class])];
        self.creationDate = [NSDate date];
        self.matchStatus = MatchStatusYourTurn;
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    if((self = [super init])){
        self.matchID = [aDecoder decodeObjectForKey:matchIDKEY];
        self.games = [aDecoder decodeObjectForKey:gamesKEY];
        self.creationDate = [aDecoder decodeObjectForKey:creationDateKEY];
        self.currentGame = [aDecoder decodeObjectForKey:currentGameKEY];
        self.matchStatus = [aDecoder decodeIntForKey:matchStatusKEY];
        self.startingDifficulty = [aDecoder decodeIntForKey:startingDifficultyKEY];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.matchID forKey:matchIDKEY];
    [aCoder encodeObject:self.games forKey:gamesKEY];
    [aCoder encodeObject:self.creationDate forKey:creationDateKEY];
    [aCoder encodeObject:self.currentGame forKey:currentGameKEY];
    [aCoder encodeInt:self.matchStatus forKey:matchStatusKEY];
    [aCoder encodeInt:self.startingDifficulty forKey:startingDifficultyKEY];
}

-(NSString*)description{
    return [NSString stringWithFormat:@"<%@: %p status = %d ; games = %@>", NSStringFromClass([self class]), self, self.matchStatus, self.games];
}

-(NSDate*)updatedDate{
    NSDate* updatedDate = self.creationDate;
    
    for (id<MatchGame> game in self.games) {
        if ( 0 < [game.completionDate timeIntervalSinceDate:updatedDate]) {
            updatedDate = game.completionDate;
        }
    }
    
    return  updatedDate;

}

@end