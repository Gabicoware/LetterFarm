//
//  EmailMatch.m
//  LetterFarm
//
//  Created by Daniel Mueller on 12/28/12.
//
//

#import "EmailMatch.h"

#define matchIDKEY @"matchID"
#define gamesKEY @"games"
#define matchStatusKEY @"matchStatus"
#define sourceEmailKEY @"sourceEmail"
#define targetEmailKEY @"targetEmail"
#define timeSinceEpochKEY @"timeSinceEpoch"
#define isSourceKEY @"isSource"

@implementation EmailMatch

@synthesize creationDate=_creationDate;

@synthesize matchID=_matchID;
@synthesize games=_games;
@synthesize matchStatus=_matchStatus;
@synthesize sourceEmail=_sourceEmail;
@synthesize targetEmail=_targetEmail;
@synthesize timeSinceEpoch=_timeSinceEpoch;
@synthesize isSource=_isSource;

-(id)init{
    if((self = [super init])){
        self.creationDate = [NSDate date];
        self.matchStatus = MatchStatusYourTurn;
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    if((self = [super init])){
        self.matchID = [aDecoder decodeObjectForKey:matchIDKEY];
        self.games = [aDecoder decodeObjectForKey:gamesKEY];
        self.matchStatus = [aDecoder decodeIntForKey:matchStatusKEY];
        self.targetEmail = [aDecoder decodeObjectForKey:targetEmailKEY];
        self.sourceEmail = [aDecoder decodeObjectForKey:sourceEmailKEY];
        self.isSource = [aDecoder decodeBoolForKey:isSourceKEY];
        self.timeSinceEpoch = [aDecoder decodeIntForKey:timeSinceEpochKEY];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.matchID forKey:matchIDKEY];
    [aCoder encodeObject:self.games forKey:gamesKEY];
    [aCoder encodeInt:self.matchStatus forKey:matchStatusKEY];
    [aCoder encodeObject:self.targetEmail forKey:targetEmailKEY];
    [aCoder encodeObject:self.sourceEmail forKey:sourceEmailKEY];
    [aCoder encodeBool:self.isSource forKey:isSourceKEY];
    [aCoder encodeInt:self.timeSinceEpoch forKey:timeSinceEpochKEY];
}

-(NSString*)description{
    return [NSString stringWithFormat:@"<%@: %p status = %d ; games = %@>", NSStringFromClass([self class]), self, self.matchStatus, self.games];
}

@end
