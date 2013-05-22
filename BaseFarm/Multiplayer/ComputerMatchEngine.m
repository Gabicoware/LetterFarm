//
//  ComputerMatchEngine.m
//  LetterFarm
//
//  Created by Daniel Mueller on 7/23/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import "ComputerMatchEngine.h"
#import "MatchInfo.h"
#import "PuzzleGame.h"
#import "MatchInfo+Puzzle.h"


#define ComputerMatchDictionaryFileName @"computer_matches.0.lf" 

#define ComputerPlayerID @"computer_device"

#define ComputerSelfPlayerID @"local_player"

@implementation ComputerMatchEngine

@synthesize allMatches;

+(id)sharedComputerMatchEngine{
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
    
    return [documentsDirectory stringByAppendingPathComponent:ComputerMatchDictionaryFileName];
    
}

-(NSString*)playerID{
    return ComputerSelfPlayerID;
}

-(void)advanceMatch:(MatchInfo*)matchInfo{
    
    if ( matchInfo.status == MatchStatusTheirTurn  ){
        matchInfo.status = MatchStatusYourTurn;

        PuzzleGame* computerGame = nil;
        
        if (matchInfo.games.count%2 == 1) {
            //simulate an identical game
            PuzzleGame* yourGame = [matchInfo.games lastObject];
            
            computerGame = [yourGame copy];
            
            computerGame.guessedWords = yourGame.solutionWords;
            
            computerGame.creationDate = [NSDate date];
            computerGame.completionDate = [NSDate dateWithTimeIntervalSinceNow:10.0];
            computerGame.guessCount = computerGame.guessedWords.count + 1;
            computerGame.playerID = ComputerPlayerID;
            
            matchInfo.games = [matchInfo.games arrayByAddingObject:computerGame];
        }
        
        
        LocalSourceData* localSourceData = OBJECT_IF_OF_CLASS(matchInfo.sourceData, LocalSourceData);
        
        localSourceData.games = matchInfo.games;
        
        localSourceData.matchStatus = matchInfo.status;
        
        if( [matchInfo canFinishPuzzleMatch] ){
            [matchInfo finishPuzzleMatch];
            
            localSourceData.matchStatus = matchInfo.status;
            
            [self completeMatch:matchInfo];
        }
        
    }
    
}

-(BOOL)endTurnInMatch:(MatchInfo*)matchInfo{
    
    LocalSourceData* computerMatch = OBJECT_IF_OF_CLASS( matchInfo.sourceData, LocalSourceData);
    
    computerMatch.currentGame = nil;
    computerMatch.matchStatus = MatchStatusTheirTurn;
    computerMatch.games = matchInfo.games;
    matchInfo.status = MatchStatusTheirTurn;
    
    [self advanceMatch:matchInfo];
    
    if (![[self.allMatches allValues] containsObject:matchInfo]) {
        [[self allMatches] setObject:matchInfo forKey:computerMatch.matchID];
    }
    
    [self saveMatches];

    [[NSNotificationCenter defaultCenter] postNotificationName:MatchesDidLoadNotification object:self];
    
    return NO;
}

-(void)updateMatchInfo:(MatchInfo*)matchInfo withSourceData:(LocalSourceData *)localSourceData{
    
    [super updateMatchInfo:matchInfo withSourceData:localSourceData];
    
#ifndef DISABLE_LOCAL
    matchInfo.opponentType = OpponentTypeComputer;
#endif
    matchInfo.opponentID = ComputerPlayerID;
    matchInfo.opponentName = @"Computer";
}

@end
