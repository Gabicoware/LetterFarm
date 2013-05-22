//
//  LengthGenerator.m
//  LetterFarm
//
//  Created by Daniel Mueller on 10/16/12.
//
//

#import "WordMovesGenerator.h"

@implementation WordMovesGenerator

@synthesize startWord=_startWord, maxMoves=_maxMoves;

-(id)generateResult{
    
    NSNumber* result = nil;
    
    if (self.startWord != nil) {
        
        //if we've been given a word, generate the puzzle whether it creates one or not
        int moves = 0;
        @autoreleasepool {
            moves = [self generateMaxMovesWithWord:self.startWord];
        }
        result = [NSNumber numberWithInt:moves];
        
    }
    
    return result;
}

-(int)generateMaxMovesWithWord:(NSString*)word{
    
    
    self.levelsDictionary = [NSMutableDictionary dictionary];
    self.sourcesDictionary = [NSMutableDictionary dictionary];
    
    NSMutableArray* levelWords = [NSMutableArray array];
    
    NSSet* currentLevelWords = [NSSet setWithObject:word];
    
    [levelWords addObject:currentLevelWords];
        
    for (int initialMove = 0; initialMove < self.maxMoves; initialMove++) {
        
        currentLevelWords = [self wordsForMove:initialMove currentWords:currentLevelWords];
        
        BOOL hasValidStepWord = NO;
        
        for (NSString* stepWord in currentLevelWords) {
            
            NSMutableSet* levels = [self.levelsDictionary objectForKey:stepWord];
            
            if ([levels count] == 1  && [self isWordValidSolution:stepWord start:word moves:(initialMove+1)]) {
                hasValidStepWord = YES;
                break;
            }
            
        }
        
        
        if (!hasValidStepWord) {
            break;
        }else{
            [levelWords addObject:currentLevelWords];
        }
        
    }
    
    for (int finalMove = (int)levelWords.count - 1; 0 < finalMove ; finalMove--) {
        
        currentLevelWords = [levelWords objectAtIndex:finalMove];
        
        BOOL hasValidFinalWord = NO;
        
        for (NSString* stepWord in currentLevelWords) {
            
            BOOL isLegal = [self isCandidateLegal:stepWord forWord:word inMoves:(int)(finalMove)];
            
            if (isLegal) {
                hasValidFinalWord = YES;
                break;
            }
            
        }
        
        if (hasValidFinalWord) {
            break;
        }else{
            [levelWords removeObjectAtIndex:finalMove];
        }
        
    }

    
    return (int)levelWords.count - 1;
    
}

-(BOOL)isWordValidSolution:(NSString*)solution start:(NSString*)start moves:(int)moves{
    NSMutableArray* resultArray = nil;
    
    if ( solution != nil ) {
        
        resultArray = [NSMutableArray array];
        
        [resultArray addObject:solution];
        
        NSString* backtraceWord = solution;
        
        for (int move = moves-1; 0 <= move; move--) {
            
            NSSet* sources = [self.sourcesDictionary objectForKey:backtraceWord];
            
            for (NSString* source in sources) {
                NSSet* sourceLevels = [self.levelsDictionary objectForKey:source];
                
                int lowestLevel = moves;
                
                for (NSNumber* level in sourceLevels) {
                    if ( [level intValue] < lowestLevel) {
                        lowestLevel = [level intValue];
                    }
                }
                
                if(lowestLevel == move){
                    backtraceWord = source;
                    [resultArray insertObject:backtraceWord atIndex:0];
                    break;
                }
                
            }
            
        }
        
        [resultArray insertObject:start atIndex:0];
        
    }
    
    return [resultArray count] == (moves + 1);
    
}


@end