//
//  PassNPlayMatchEngine.m
//  LetterFarm
//
//  Created by Daniel Mueller on 1/13/13.
//
//

#import "PassNPlayMatchEngine.h"
#import "PuzzleGame.h"
#import "MatchInfo+Puzzle.h"

#define PassNPlayMatchDictionaryFileName @"passnplay_matches.0.lf"
#define PassNPlayMatchPlayerID @"passnplay_player"

@implementation PassNPlayMatchEngine

+(id)sharedPassNPlayMatchEngine{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
    });
    return _sharedObject;
}

-(NSString*)localMatchFilePath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    return [documentsDirectory stringByAppendingPathComponent:PassNPlayMatchDictionaryFileName];
}

-(NSString*)playerID{
    return PassNPlayMatchPlayerID;
}

-(BOOL)endTurnInMatch:(MatchInfo*)matchInfo{
    
    PassNPlaySourceData* passNPlayMatch = OBJECT_IF_OF_CLASS( matchInfo.sourceData, PassNPlaySourceData);
    
    passNPlayMatch.currentGame = nil;
    
    if (passNPlayMatch.matchStatus == MatchStatusTheirTurn) {
        passNPlayMatch.matchStatus = MatchStatusYourTurn;
    }else if (passNPlayMatch.matchStatus == MatchStatusYourTurn) {
        passNPlayMatch.matchStatus = MatchStatusTheirTurn;
    }
    passNPlayMatch.games = matchInfo.games;
    matchInfo.status = passNPlayMatch.matchStatus;
    
    if (![[self.allMatches allValues] containsObject:matchInfo]) {
        [[self allMatches] setObject:matchInfo forKey:passNPlayMatch.matchID];
    }
    
    [self saveMatches];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MatchesDidLoadNotification object:self];
    
    return NO;
}

-(void)quitMatch:(MatchInfo*)matchInfo{
    
    PassNPlaySourceData* passNPLayMatch = OBJECT_IF_OF_CLASS(matchInfo.sourceData, PassNPlaySourceData);
    matchInfo.status = MatchStatusYouQuit;
    passNPLayMatch.matchStatus = MatchStatusYouQuit;
    [[self allMatches] setObject:matchInfo forKey:passNPLayMatch.matchID];
    [self saveMatches];
    [[NSNotificationCenter defaultCenter] postNotificationName:MatchesDidLoadNotification object:self];
}

-(BOOL)canPlayWithMatchInfo:(MatchInfo*)matchInfo{
    return [matchInfo.sourceData isKindOfClass:[PassNPlaySourceData class]] && (matchInfo.status == MatchStatusYourTurn || matchInfo.status == MatchStatusTheirTurn);
}

-(void)updateMatchInfo:(MatchInfo*)matchInfo withSourceData:(LocalSourceData *)localSourceData{
    
    [super updateMatchInfo:matchInfo withSourceData:localSourceData];
    
#ifndef DISABLE_LOCAL
    matchInfo.opponentType = OpponentTypePassNPlay;
    
    PassNPlaySourceData* passNPlayMatch = OBJECT_IF_OF_CLASS(localSourceData, PassNPlaySourceData);
    
    //current status
    matchInfo.opponentID = passNPlayMatch.playerTwoID;
    matchInfo.opponentName = passNPlayMatch.playerTwoID;
    
#endif
}

-(void)updateGame:(id)game forMatch:(MatchInfo*)matchInfo{
    PassNPlaySourceData* passNPlayMatch = OBJECT_IF_OF_CLASS(matchInfo.sourceData, PassNPlaySourceData);

    PuzzleGame* puzzleGame = OBJECT_IF_OF_CLASS(game, PuzzleGame);
    if (matchInfo.status == MatchStatusYourTurn) {
        puzzleGame.playerID =passNPlayMatch.playerOneID;
    }else if (matchInfo.status == MatchStatusTheirTurn) {
        puzzleGame.playerID =passNPlayMatch.playerTwoID;
    }
}


@end