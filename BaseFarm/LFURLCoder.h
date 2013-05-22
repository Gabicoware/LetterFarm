//
//  LFURLCoder.h
//  LetterFarm
//
//  Created by Daniel Mueller on 9/20/12.
//
//

#import <Foundation/Foundation.h>
#import "PuzzleGame.h"
#import "MatchInfo.h"

typedef enum _PuzzleURLVersions{
    PuzzleURLVersionNone=0,
    PuzzleURLVersionOne=1,
    PuzzleURLVersionTwo=2,
    PuzzleURLVersionStandard=2,
    PuzzleURLVersionFB=3,//a puzzle only
}PuzzleURLVersion;

@interface LFURLCoder : NSObject

+(NSURL*)encodePuzzleGame:(PuzzleGame*)puzzleGame withVersion:(PuzzleURLVersion)version;

+(NSURL*)encodePuzzleGame:(PuzzleGame*)puzzleGame;

+(id)decodeURL:(NSURL*)URL;

+(NSURL*)encodeMatchInfo:(MatchInfo*)matchInfo;

+(NSString*)multiplayerQueryStringWithGame:(PuzzleGame*)game;
+(PuzzleGame*)multiplayerGameWithQueryString:(NSString*)queryString;

@end

@interface NSURL (Scheme)

-(NSURL*)URLWithScheme:(NSString*)scheme;

@end

@interface NSDictionary (QueryString)

-(NSString*)queryString;

+(id)dictionaryWithQueryString:(NSString*)query;

@end


