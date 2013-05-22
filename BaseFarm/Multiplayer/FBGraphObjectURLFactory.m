//
//  FBGraphObjectURLFactory.m
//  LetterFarm
//
//  Created by Daniel Mueller on 12/22/12.
//
//

#import "FBGraphObjectURLFactory.h"
#import "PuzzleGame.h"
#import "MatchInfo.h"
#import "LFURLCoder.h"

@implementation FBGraphObjectURLFactory

+(NSURL*)graphObjectURLWithObject:(id)object{
    
    NSURL* result = nil;
    
    PuzzleGame* game = OBJECT_IF_OF_CLASS(object, PuzzleGame);
    if (game != nil) {
        result = [LFURLCoder encodePuzzleGame:game withVersion:PuzzleURLVersionFB];
    }
    
    MatchInfo* matchInfo = OBJECT_IF_OF_CLASS(object, MatchInfo);
    if (matchInfo != nil) {
        result = [LFURLCoder encodeMatchInfo:matchInfo];
    }
    
    return result;
}

@end
