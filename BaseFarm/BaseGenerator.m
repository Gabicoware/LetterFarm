//
//  BaseGenerator.m
//  LetterFarm
//
//  Created by Daniel Mueller on 9/20/12.
//
//

#import "BaseGenerator.h"
#import "WordProvider.h"

@implementation BaseGenerator

@synthesize words=_words, levelsDictionary=_levelsDictionary, sourcesDictionary=_sourcesDictionary, target=_target, action=_action;

-(id)initWithWords:(NSSet *)words{
    if((self = [self init])){
        self.words = words;
    }
    return self;
}

-(void)generateInBackground{
    
    [self performSelectorInBackground:@selector(generate) withObject:nil];
    
}

-(void)generate{
    
    self.result = [self generateResult];
    
    [self.target performSelectorOnMainThread:self.action withObject:self.result waitUntilDone:YES];
    
}

-(id)generateResult{
    [NSException raise:@"Unimplemented Exception" format:@"generateResult is unimplemented"];
    return nil;
}


-(NSMutableArray*)resultWordsWithStart:(NSString*)start finish:(NSString*)finish moves:(int)moves{
    NSMutableArray* resultArray = nil;
    
    if ( finish != nil ) {
        
        resultArray = [NSMutableArray array];
        
        [resultArray addObject:finish];
        
        NSString* backtraceWord = finish;
        
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
    
    return resultArray;
    
}

-(NSSet*)wordsForMove:(int)move currentWords:(NSSet*)currentWords{
    NSMutableSet* nextLevelWords = [NSMutableSet set];
    
    for (NSString* currentWord in currentWords) {
        NSMutableSet* perms = [[WordProvider currentWordProvider] permutationsOfWord:currentWord];
        
        [perms intersectSet:self.words];
        [perms removeObject:currentWord];
        
        for (NSString* permutation in perms) {
            {
                NSMutableSet* levels = [self.levelsDictionary objectForKey:permutation];
                
                if (levels == nil) {
                    levels = [NSMutableSet set];
                    [[self levelsDictionary] setObject:levels forKey:permutation];
                }
                
                [levels addObject:[NSNumber numberWithInt:move]];
            }
            {
                NSMutableSet* sources = [self.sourcesDictionary objectForKey:permutation];
                
                if (sources == nil) {
                    sources = [NSMutableSet set];
                    [[self sourcesDictionary] setObject:sources forKey:permutation];
                }
                
                [sources addObject:currentWord];
            }
        }
        [nextLevelWords unionSet:perms];
    }
    
    return [NSSet setWithSet:nextLevelWords];
}

-(BOOL)isCandidateLegal:(NSString*)candidateWord forWord:(NSString*)word inMoves:(int)moves{
    NSMutableSet* levels = [self.levelsDictionary objectForKey:candidateWord];
    
    return [[WordProvider currentWordProvider] isCandidateLegal:candidateWord forWord:word onLevels:levels inMoves:moves];

}

@end
