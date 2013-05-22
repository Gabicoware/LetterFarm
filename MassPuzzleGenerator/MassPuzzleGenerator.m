//
//  MassPuzzleGenerator.m
//  LetterFarm
//
//  Created by Daniel Mueller on 1/31/13.
//
//

#import "MassPuzzleGenerator.h"
#import "PuzzleGenerator.h"
#import "PuzzleGeneratorFactory.h"
#import "WordProvider.h"

@implementation MassPuzzleGenerator

-(NSArray*)arrayFromFilePath:(NSString*)filePath{
    
    NSError* error = nil;
    
    NSString* contentString = [NSString stringWithContentsOfFile:filePath
                                                        encoding:NSASCIIStringEncoding
                                                           error:&error];
    
    NSString* formattedContentString = [[contentString lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return [formattedContentString componentsSeparatedByString:@"\n"];
    
}

-(void)writeArray:(NSArray*)array toFilePath:(NSString*)filePath{
    
    NSString* contentString = [array componentsJoinedByString:@"\n"];
    
    NSError* error = nil;
    
    [contentString writeToFile:filePath atomically:NO encoding:NSASCIIStringEncoding error:&error];
    
    if (error != nil) {
        NSLog(@"%@", error);
    }
}

-(void)generatePuzzlesFromDirectory:(NSString*)inputDir toFile:(NSString*)output{
    
    NSMutableArray* allGames = [NSMutableArray array];
    
    [[WordProvider currentWordProvider] setAlternativeBasePath:inputDir];
    
    int difficulties[] = {DifficultyEasy, DifficultyMedium, DifficultyHard, DifficultyVeryHard, DifficultyBrutal};
    int counts[] = {0,3,4,3,0};
    int total = 5;
    
    for (int index = 0; index < total; index++) {
        
        int difficulty = difficulties[index];
        int count = counts[index];
        
        for (int type = 5; type > 2; type--)
        {
            PuzzleGenerator* generator = [PuzzleGeneratorFactory newGameGeneratorForType:type withDifficulty:difficulty];
            NSArray* games = [self gamesWithGenerator:generator count:count];
            [allGames addObjectsFromArray:games];
        }
    }
    
    [self writeArray:allGames toFilePath:output];

}

-(NSArray*)gamesWithGenerator:(PuzzleGenerator*)generator count:(int)count{
    NSMutableArray* games = [NSMutableArray array];
    for (int index = 0; index < count; index++) {
        
        static int totalCount = 0;
        
        [generator setResult:nil];
        [generator setStartWord:nil];
        
        [generator generate];
        
        PuzzleGame* game = OBJECT_IF_OF_CLASS([generator result], PuzzleGame);
        
        NSString* gameString = [game.solutionWords componentsJoinedByString:@","];
        
        [games addObject:gameString];
        
        
        totalCount++;
        
        if (totalCount%5 == 0) {
            NSLog(@"Generated %d", totalCount);
        }

    }
    return [NSArray arrayWithArray:games];
}

@end
