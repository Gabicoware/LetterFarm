//
//  GKSourceDataTests.m
//  LetterFarm
//
//  Created by Daniel Mueller on 3/20/13.
//
//

#import "GKSourceDataTests.h"
#import "GKSourceData.h"
#import "PuzzleGame.h"

@implementation GKSourceDataTests

-(void)testSourceData{
    GKSourceData* initialSourceData = [[GKSourceData alloc] init];
    
    PuzzleGame* puzzleGame = [[PuzzleGame alloc] init];
    
    puzzleGame.startWord = @"mine";
    puzzleGame.endWord = @"pile";
    puzzleGame.solutionWords = @[@"mine", @"mile", @"pile"];
    puzzleGame.guessedWords = @[@"mine"];
    
    initialSourceData.currentGame = puzzleGame;
    
    initialSourceData.games = @[];
    
    initialSourceData.startingDifficulty = 4;
    
    NSData* data = [initialSourceData archiveData];
    
    GKSourceData* decrytedSourceData = [GKSourceData sourceDataWithArchiveData:data];
    
    STAssertNotNil(decrytedSourceData, @"The decrypted object must exist");
    
    PuzzleGame* currentGame = OBJECT_IF_OF_CLASS(decrytedSourceData.currentGame, PuzzleGame);
    
    STAssertNotNil(currentGame, @"The currentGame must exist");
    STAssertEquals(decrytedSourceData.startingDifficulty, 4, @"the decrypted object should have the correct difficulty");
    STAssertEquals(decrytedSourceData.games, initialSourceData.games, @"the sourceData should have equal game counts");
}

@end
