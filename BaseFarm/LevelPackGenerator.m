//
//  LevelPackGenerator.m
//  LetterFarm
//
//  Created by Daniel Mueller on 2/10/13.
//
//

#import "LevelPackGenerator.h"
#import "PuzzleGenerator.h"
#import "PuzzleGeneratorFactory.h"

@implementation LevelPackGenerator

@synthesize generatedCount=_generatedCount;

-(void)generateInBackground{
    
    [self performSelectorInBackground:@selector(generate) withObject:nil];
    
}

-(void)generate{
    
    self.result = [self generateResult];
    
    [self.target performSelectorOnMainThread:self.action withObject:self.result waitUntilDone:YES];
    
}

-(id)generateResult{
    
    NSMutableArray* allGames = [NSMutableArray array];
    
    int total = 5;
    int difficulties[] = {DifficultyEasy,DifficultyMedium,DifficultyHard,DifficultyVeryHard,DifficultyBrutal};
    int counts[] = {0,0,0,0,0};
    
    
    switch (self.difficulty) {
        case DifficultyEasy:
            counts[0] = 6;
            counts[1] = 3;
            counts[2] = 1;
            break;
        case DifficultyMedium:
            counts[1] = 6;
            counts[2] = 3;
            counts[3] = 1;
            break;
        case DifficultyHard:
            counts[2] = 6;
            counts[3] = 3;
            counts[4] = 1;
            break;
        case DifficultyVeryHard:
            counts[3] = 7;
            counts[4] = 3;
            break;
        case DifficultyBrutal:
            counts[4] = 10;
            break;
        case DifficultyNone:
            counts[0] = 6;
            counts[1] = 3;
            counts[2] = 1;
            break;
    }
    
    self.generatedCount = 0;
    
    
    for (int index = 0; index < total; index++) {
        
        Difficulty difficulty = difficulties[index];
        int count = counts[index];
        
        for (int type = 5; type > 2; type--)
        {
            PuzzleGenerator* generator = [PuzzleGeneratorFactory newGameGeneratorForType:type withDifficulty:difficulty];
            NSArray* games = [self gamesWithGenerator:generator count:count];
            [allGames addObjectsFromArray:games];
        }
        
    }
    
    NSAssert([allGames count] == 30, @"Must have created 30 games");
    return allGames;
    
}



-(NSArray*)gamesWithGenerator:(PuzzleGenerator*)generator count:(int)count{
    NSMutableArray* games = [NSMutableArray array];
    for (int index = 0; index < count; index++) {
        
        [generator setResult:nil];
        [generator setStartWord:nil];
        
        @autoreleasepool {
            
            [generator generate];
        }
        
        PuzzleGame* game = OBJECT_IF_OF_CLASS([generator result], PuzzleGame);
        
        NSString* gameString = [game.solutionWords componentsJoinedByString:@","];
        
        [games addObject:gameString];
        
        self.generatedCount = self.generatedCount + 1;
        
    }
    return [NSArray arrayWithArray:games];
}


@end
