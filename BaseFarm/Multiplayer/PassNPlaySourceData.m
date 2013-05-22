//
//  PassNPlayMatch.m
//  LetterFarm
//
//  Created by Daniel Mueller on 1/15/13.
//
//

#import "PassNPlaySourceData.h"

#define playerOneIDKey @"playerOneID"
#define playerTwoIDKey @"playerTwoID"

@implementation PassNPlaySourceData

-(id)initWithCoder:(NSCoder *)aDecoder{
    if((self = [super initWithCoder:aDecoder])){
        self.playerOneID = [aDecoder decodeObjectForKey:playerOneIDKey];
        self.playerTwoID = [aDecoder decodeObjectForKey:playerTwoIDKey];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.playerOneID forKey:playerOneIDKey];
    [aCoder encodeObject:self.playerTwoID forKey:playerTwoIDKey];
}

-(NSString*)description{
    return [NSString stringWithFormat:@"<%@: %@ vs %@; %p status = %d ; games = %@>", NSStringFromClass([self class]), self, self.playerTwoID, self.playerTwoID, self.matchStatus, self.games];
}


@end
