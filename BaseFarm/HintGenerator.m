//
//  HintGenerator.m
//  LetterFarm
//
//  Created by Daniel Mueller on 9/16/12.
//
//

#import "HintGenerator.h"


@implementation HintGenerator

-(id)generateResult{
    return [self generateHintWithStartWord:self.startWord finalWord:self.finalWord inMoves:6];
}

-(NSMutableArray*)generateHintWithStartWord:(NSString*)word finalWord:(NSString*)finalWord inMoves:(int)moves{
    
    
    self.levelsDictionary = [NSMutableDictionary dictionary];
    self.sourcesDictionary = [NSMutableDictionary dictionary];
    
    NSSet* currentLevelWords = [NSSet setWithObject:word];
    
    BOOL hasFoundFinalWord = NO;
    
    //if we find the ginal word, there's no reason to continue
    for (int move = 0; move < moves && !hasFoundFinalWord; move++) {
        
        currentLevelWords = [self wordsForMove:move currentWords:currentLevelWords];
        
        hasFoundFinalWord = [currentLevelWords containsObject:finalWord];
        
    }
    
    
    NSMutableArray* resultArray = nil;
    
    if ( hasFoundFinalWord ) {
        
        resultArray = [self resultWordsWithStart:word finish:finalWord moves:moves];
        
    }
    
    return resultArray;
    
}

@end
