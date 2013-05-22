//
//  GKSourceData.m
//  LetterFarm
//
//  Created by Daniel Mueller on 3/15/13.
//
//

#import "GKSourceData.h"
#import "MatchInfo+Puzzle.h"
#import "PuzzleGame.h"
#import "LFURLCoder.h"

#define startingDifficultyKEY @"startingDifficulty"
#define hasCurrentGameKEY @"hasCurrentGame"

@implementation GKSourceData

-(NSData*)archiveData{
    
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    
    [params setObject:[NSString stringWithFormat:@"%d",self.startingDifficulty] forKey:startingDifficultyKEY];
    
    NSMutableArray* strings = [NSMutableArray array];
    
    if (self.currentGame != nil) {
        [params setObject:@"1" forKey:hasCurrentGameKEY];
    }
    
    NSString* objectString = [params queryString];
    
    [strings addObject:objectString];
    
    if (self.currentGame != nil) {
        NSString* gameURL = [LFURLCoder multiplayerQueryStringWithGame:(PuzzleGame*)self.currentGame];
        [strings addObject:gameURL];
    }
    
    for(PuzzleGame* game in self.games){
        NSString* gameURL = [LFURLCoder multiplayerQueryStringWithGame:game];
        [strings addObject:gameURL];
    }
    
    NSString* mainString = [strings componentsJoinedByString:@"\n"];
    
    NSData* data = [mainString dataUsingEncoding:NSASCIIStringEncoding];
    
    return data;
}

-(void)updateWithArchiveData:(NSData*)data{
    
    NSString* string = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    
    NSArray* strings = [string componentsSeparatedByString:@"\n"];
    
    NSString* objectString = [strings objectAtIndex:0];
    
    NSDictionary* properties = [NSDictionary dictionaryWithQueryString:objectString];
    
    int startingDifficulty = 0;
    
    NSString* diffStr = [properties objectForKey:startingDifficultyKEY];
    
    if (diffStr != nil) {
        
        [[NSScanner scannerWithString:diffStr] scanInt:&startingDifficulty];
        
    }
    
    
    self.startingDifficulty = startingDifficulty;
    
    BOOL hasCurrentGame = [properties objectForKey:hasCurrentGameKEY] != nil;
    
    NSMutableArray* games = [NSMutableArray array];
    
    for (int index = 1; index < [strings count]; index++) {
        @try {
            NSString* gameString = [strings objectAtIndex:index];
            
            PuzzleGame* game = [LFURLCoder multiplayerGameWithQueryString:gameString];
            
            if (hasCurrentGame && index == 1) {
                self.currentGame = game;
            }else{
                [games addObject:game];
            }
            
        }
        @catch (NSException *exception) {}
        @finally {}
    }
    
    self.games = [NSArray arrayWithArray:games];
    

}

+(id)sourceDataWithArchiveData:(NSData*)data{
    GKSourceData* sourceData = [[GKSourceData alloc] init];
    
    [sourceData updateWithArchiveData:data];
    
    return sourceData;
}

@end
