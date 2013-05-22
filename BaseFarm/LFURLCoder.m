//
//  LFURLCoder.m
//  LetterFarm
//
//  Created by Daniel Mueller on 9/20/12.
//
//

#import "LFURLCoder.h"
#import "WordProvider.h"
#import "NSString+LF.h"
#import "SimpleEncrypt.h"
#import "EmailMatch.h"

#define URL_RESOURCE @"http://example.com"

#define NAME_KEY @"playerID"
#define START_KEY @"start"
#define END_KEY @"end"
#define SOLUTION_KEY @"s"
#define GUESS_KEY @"g"
#define COMPLETION_DATE_KEY @"completed"
#define CREATION_DATE_KEY @"created"


@implementation LFURLCoder

+(NSURL*)encodePuzzleGame:(PuzzleGame*)puzzleGame{
    return [LFURLCoder encodePuzzleGame:puzzleGame withVersion:PuzzleURLVersionStandard];
}

+(NSURL*)encodePuzzleGame:(PuzzleGame*)puzzleGame withVersion:(PuzzleURLVersion)version{
    
    NSURL* result = nil;
    
    if (puzzleGame != nil) {
        
        NSDictionary* params = nil;
        
        switch (version) {
            case PuzzleURLVersionOne:
                params = [LFURLCoder v1_dictionaryWithPuzzleGame:puzzleGame];
                break;
            case PuzzleURLVersionTwo:
                params = [LFURLCoder v2_dictionaryWithPuzzleGame:puzzleGame];
                break;
            case PuzzleURLVersionFB:
                params = [LFURLCoder fb_dictionaryWithPuzzleGame:puzzleGame];
                break;
                
            default:
                break;
        }
       
        
        NSString* queryString = [params queryString];
        
        NSString* URLString = [NSString stringWithFormat:@"%@?%@",URL_RESOURCE,queryString];
        
        result = [NSURL URLWithString:URLString];
    }
    
    
    return result;
    
}

+(id)decodeURL:(NSURL*)URL{
    id result = nil;
    if (URL != nil) {
        
        NSDictionary* dict = [self queryDictionaryWithURL:URL];
        
        NSString* versionString = [dict objectForKey:@"v"];
        
#ifndef DISABLE_EMAIL
        if ([versionString isEqualToString:@"e1"]) {
            result = [self e1_emailMatchWithDict:dict];
        }else
#endif
        {
            PuzzleURLVersion version = [self versionFromString:versionString];
            
            switch (version) {
                case PuzzleURLVersionOne:
                    result = [self v1_puzzleGameWithDict:dict];
                    break;
                case PuzzleURLVersionTwo:
                    result = [self v2_puzzleGameWithDict:dict];
                    break;
                    
                case PuzzleURLVersionNone:
                default:
                    break;
            }
            
        }
    }
    return result;
    
}

+(PuzzleURLVersion)versionFromString:(NSString*)string{
    return [string integerValue];
}

+(NSDictionary*)queryDictionaryWithURL:(NSURL*)URL{
    
    NSString* query = [URL query];
    
    return [NSDictionary dictionaryWithQueryString:query];
}

+(NSString*)multiplayerQueryStringWithGame:(PuzzleGame*)puzzleGame{
    NSMutableDictionary* encodedParams = [[LFURLCoder v1_dictionaryWithPuzzleGame:puzzleGame] mutableCopy];
    
    NSString* g = [LFURLCoder solutionStringWithWords: puzzleGame.guessedWords];
    
    if (g != nil) {
        [encodedParams setObject:g forKey:GUESS_KEY];
    }
    
    NSTimeInterval creationInterval = [[puzzleGame creationDate] timeIntervalSince1970];
    
    NSTimeInterval completionInterval = [[puzzleGame completionDate] timeIntervalSince1970];
    
    NSString* creationString = [[NSNumber numberWithDouble:creationInterval] description];

    NSString* completionString = [[NSNumber numberWithDouble:completionInterval] description];
    
    [encodedParams setObject:creationString forKey:CREATION_DATE_KEY];
    [encodedParams setObject:completionString forKey:COMPLETION_DATE_KEY];
    
    return [encodedParams queryString];

}
+(PuzzleGame*)multiplayerGameWithQueryString:(NSString*)queryString{
    
    NSDictionary* gameDict = [NSDictionary dictionaryWithQueryString:queryString];
    
    PuzzleGame* game = [LFURLCoder v1_puzzleGameWithDict:gameDict];
    
    //get the players guesses
    NSString* g = [gameDict objectForKey:GUESS_KEY];
    
    game.guessedWords = [LFURLCoder wordsWithStart:game.startWord end:game.endWord solution:g];
    
    
    //load the creationDate
    NSString* creationString = [gameDict objectForKey:CREATION_DATE_KEY];
    
    NSTimeInterval creationInterval = 0.0;
    
    if (creationString != nil) {
        [[NSScanner scannerWithString:creationString] scanDouble:&creationInterval];
    }

    game.creationDate= [NSDate dateWithTimeIntervalSince1970:creationInterval];
    
    
    //load the completionDate
    NSString* completionString = [gameDict objectForKey:COMPLETION_DATE_KEY];
    
    NSTimeInterval completionInterval = 0.0;
    
    if (completionString != nil) {
        [[NSScanner scannerWithString:completionString] scanDouble:&completionInterval];
    }
    
    game.completionDate= [NSDate dateWithTimeIntervalSince1970:completionInterval];
    
    return game;
}


+(NSDictionary*)v2_dictionaryWithPuzzleGame:(PuzzleGame*)puzzleGame{
    
    NSMutableDictionary* encodedParams = [NSMutableDictionary dictionary];
    
    
    [encodedParams setObject:puzzleGame.startWord forKey:START_KEY];
    [encodedParams setObject:puzzleGame.endWord forKey:END_KEY];
    
    NSString* s = [LFURLCoder solutionStringWithWords: puzzleGame.solutionWords];
    
    if (s != nil) {
        [encodedParams setObject:s forKey:SOLUTION_KEY];
    }
    
    //encode the params
    
    NSString* queryString = [encodedParams queryString];
    
    NSString* g = [SimpleEncrypt encrypt:queryString] ;
    
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    
    [params setObject:g forKey:@"g"];
    [params setObject:@"2" forKey:@"v"];
    
    if (puzzleGame.playerID != nil) {
        [params setObject:puzzleGame.playerID forKey:NAME_KEY];
    }
    return params;
}

+(PuzzleGame*)v2_puzzleGameWithDict:(NSDictionary*)dict{
    NSString* encryptedGameString = [dict objectForKey:@"g"];
    
    NSString* gameString = [SimpleEncrypt decrypt:encryptedGameString];
    
    NSDictionary* gameDict = [NSDictionary dictionaryWithQueryString:gameString];
    
    PuzzleGame* game = [LFURLCoder v1_puzzleGameWithDict:gameDict];
    
    game.playerID = [dict objectForKey:NAME_KEY];
    
    return game;
}

// fb is identical to version one, MINUS the personalization information
+(NSDictionary*)fb_dictionaryWithPuzzleGame:(PuzzleGame*)puzzleGame{
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setObject:@"1" forKey:@"v"];
    [params setObject:puzzleGame.startWord forKey:START_KEY];
    [params setObject:puzzleGame.endWord forKey:END_KEY];
    return params;
}

+(NSDictionary*)v1_dictionaryWithPuzzleGame:(PuzzleGame*)puzzleGame{
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    
    [params setObject:@"1" forKey:@"v"];
    [params setObject:puzzleGame.startWord forKey:START_KEY];
    [params setObject:puzzleGame.endWord forKey:END_KEY];
    
    if (puzzleGame.playerID != nil) {
        [params setObject:puzzleGame.playerID forKey:NAME_KEY];
    }
    
    NSString* s = [LFURLCoder solutionStringWithWords: puzzleGame.solutionWords];
    
    if (s != nil) {
        [params setObject:s forKey:SOLUTION_KEY];
    }
    
    return params;
}

+(PuzzleGame*)v1_puzzleGameWithDict:(NSDictionary*)dict{
    PuzzleGame* game = nil;
    NSString* start = [dict objectForKey:START_KEY];
    NSString* end = [dict objectForKey:END_KEY];
    
    
    if (start != nil && end != nil && [end length] == [start length]) {
        game = [PuzzleGame new];
        
        
        game.endWord = end;
        game.startWord = start;
        
        game.playerID = [dict objectForKey:NAME_KEY];
        
        game.guessedWords = [NSArray arrayWithObject:start];
        
        game.dictionaryType = DictionaryTypePuzzle3;
        
        if (3 <= [start length] && [start length] <= 5 ) {
            game.dictionaryType = [start length];
        }
        
        NSString* s = [dict objectForKey:@"s"];
        
        game.solutionWords = [LFURLCoder wordsWithStart:start end:end solution:s];
        
    }
    
    return game;
}

+(NSArray*)wordsWithStart:(NSString*)start end:(NSString*)end solution:(NSString*)s{
    
    NSArray* result = nil;
        
    //in order for the solution to be valid it must
    if (s != nil && 0 < [s length] && 0 == [s length]%2 ) {
        
        int moveCount = [s length]/2;
        
        NSString* currentWord = start;
        
        NSMutableArray* mSolution = [NSMutableArray arrayWithObject:currentWord];
        
        BOOL allWordsAreValid = YES;
        
        for (int index = 0; index < moveCount; index++) {
            int letterIndex = [s substringWithRange:NSMakeRange(index * 2, 1)].integerValue ;
            NSString* letter = [s substringWithRange:NSMakeRange(index * 2 + 1, 1)];
            
            currentWord = [currentWord stringByReplacingCharactersInRange:NSMakeRange(letterIndex, 1) withString:letter];
            
            if ([[WordProvider currentWordProvider] isValidWord:currentWord]) {
                [mSolution addObject:currentWord];
            }else{
                allWordsAreValid = NO;
                /*
                 An early break, as the solution has been determined to be invalid
                 */
                break;
            }
            
        }
        
        if (allWordsAreValid && [[mSolution lastObject] isEqualToString:end]) {
            
            result = [NSArray arrayWithArray:mSolution];
        }
        
    }
    
    return result;
}

+(NSString*)solutionStringWithWords:(NSArray*)words{
    NSString* s = nil;
    
    if (0 < words.count) {
        NSString* previousWord = [words objectAtIndex:0];
        
        NSMutableString* resultString = [NSMutableString string];
        
        int wordLength = [previousWord length];
        
        for (int wordIndex = 1; wordIndex < words.count; wordIndex++) {
            NSString* nextWord = [words objectAtIndex:wordIndex];
            for(NSInteger letterIndex = 0; letterIndex < wordLength; letterIndex++){
                if(![[previousWord letterAtIndex:letterIndex] isEqualToString:[nextWord letterAtIndex:letterIndex]]){
                    [resultString appendFormat:@"%d%@",letterIndex,[nextWord letterAtIndex:letterIndex]];
                }
            }
            previousWord = nextWord;
        }
        
        if ([resultString length] / 2 == words.count - 1) {
            s = [NSString stringWithString:resultString];
        }
    }
    
    return s;
}

#define EMAIL_BASE_URL @"http://example.com/email.html"
#define MATCH_BASE_URL @"http://example.com/match.html"

+(NSURL*)encodeMatchInfo:(MatchInfo*)matchInfo{
    NSURL* result = nil;
#ifndef DISABLE_EMAIL
    if (matchInfo.opponentType == OpponentTypeEmail) {
        result = nil;
        
        NSDictionary* params = [self e1_dictionaryWithEmailMatch:matchInfo.sourceData];
        
        NSString* queryString = [params queryString];
        
        NSString* URLString = [NSString stringWithFormat:@"%@?%@",EMAIL_BASE_URL,queryString];
        
        result = [NSURL URLWithString:URLString];
        
    }else
#endif
    {
        result = [NSURL URLWithString:MATCH_BASE_URL];
    }
    
    return result;
}

#ifndef DISABLE_EMAIL
+(NSDictionary*)e1_dictionaryWithEmailMatch:(EmailMatch*)emailMatch{
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    
    [params setObject:@"e1" forKey:@"v"];
    [params setObject:emailMatch.matchID forKey:@"matchID"];
    [params setObject:emailMatch.targetEmail forKey:@"targetEmail"];
    [params setObject:emailMatch.sourceEmail forKey:@"sourceEmail"];
    
    NSString* timeString = [NSString stringWithFormat:@"%d",emailMatch.timeSinceEpoch];
    
    [params setObject:timeString forKey:@"time"];
    
    NSString* gamesString = [self stringWithGames:emailMatch.games];
    
    NSString* encryptedGameString = [SimpleEncrypt encrypt:gamesString];
    
    [params setObject:encryptedGameString forKey:@"games"];
    
    return params;
}

+(EmailMatch*)e1_emailMatchWithDict:(NSDictionary*)dict{
    EmailMatch* result = [[EmailMatch alloc] init];
    
    result.matchID = [dict objectForKey:@"matchID"];
    result.sourceEmail = [dict objectForKey:@"sourceEmail"];
    result.targetEmail = [dict objectForKey:@"targetEmail"];
    
    NSNumber* timeValue = [dict objectForKey:@"time"];
    
    result.timeSinceEpoch = [timeValue intValue];
    
    NSString* encryptedGameString = [dict objectForKey:@"games"];
    
    NSString* gamesString = [SimpleEncrypt decrypt:encryptedGameString];
    
    result.games = [LFURLCoder gamesWithString:gamesString];
    
    for (int index = 0; index < result.games.count; index++) {
        BOOL isSource = index == 0 || ((((( index - 1 ) - (( index - 1 )%2))/2)%2) == 1);
        
        PuzzleGame* game = [result.games objectAtIndex:index];
        
        if (isSource) {
            game.playerID = result.sourceEmail;
        }else{
            game.playerID = result.targetEmail;
        }
    }
    
    return result;
}
#endif
+(NSArray*)gamesWithString:(NSString*)gamesString{
    NSArray* gameComponents = [gamesString componentsSeparatedByString:@","];
    
    NSMutableArray* result = [NSMutableArray array];
    
    for (int index =0; index+2 < gameComponents.count; index+=3) {
        NSString* startWord = [gameComponents objectAtIndex:index];
        NSString* endWord = [gameComponents objectAtIndex:index +1];
        NSString* solutionString = [gameComponents objectAtIndex:index+2];
        
        PuzzleGame* game = [PuzzleGame new];
        
        
        game.endWord = endWord;
        game.startWord = startWord;
        
        game.solutionWords = [LFURLCoder wordsWithStart:startWord end:endWord solution:solutionString];
        game.guessedWords = game.solutionWords;
        
        game.dictionaryType = DictionaryTypePuzzle3;
        
        if (3 <= [startWord length] && [startWord length] <= 5 ) {
            game.dictionaryType = [startWord length];
        }
        
        [result addObject:game];

    }
    
    return result;
}

+(NSString*)stringWithGames:(NSArray*)games{
    
    NSMutableArray* gameComponents = [NSMutableArray array];
    
    for (PuzzleGame* game in games) {
        [gameComponents addObject:game.startWord];
        [gameComponents addObject:game.endWord];
        NSString* solutionString = [self solutionStringWithWords:game.guessedWords];
        [gameComponents addObject:solutionString];
    }
    
    return [gameComponents componentsJoinedByString:@","];
}


@end

@implementation NSDictionary (QueryString)

-(NSString*)queryString{
    
    NSMutableArray* pieces = [NSMutableArray array];
    
    NSArray* keys = [[self allKeys] sortedArrayUsingSelector:@selector(compare:)];
    
    for (NSString* key in keys) {
        NSString* object = [[self objectForKey:key] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
        NSString* piece = [NSString stringWithFormat:@"%@=%@",key,object];
        [pieces addObject:piece];
    }
    
    return [pieces componentsJoinedByString:@"&"];
}

+(id)dictionaryWithQueryString:(NSString*)query{
    
    NSMutableDictionary* mResult = [NSMutableDictionary dictionary];
    if ([query rangeOfString:@"#"].location != NSNotFound) {
        query = [query substringToIndex:[query rangeOfString:@"#"].location];
    }
    NSArray* pieces = [query componentsSeparatedByString:@"&"];
    for (NSString* piece in pieces) {
        NSArray* keyAndValue = [piece componentsSeparatedByString:@"="];
        if ([keyAndValue count] == 2) {
            id object = [[keyAndValue objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
            [mResult setObject:object forKey:[keyAndValue objectAtIndex:0]];
        }
    }
    return [NSDictionary dictionaryWithDictionary:mResult];
}

@end

@implementation NSURL (Scheme)

-(NSURL*)URLWithScheme:(NSString*)scheme{
    NSString* originalScheme = [self scheme];
    NSString* originalURLString = [self absoluteString];
    
    NSURL* result = nil;
    
    if (originalURLString != nil && originalScheme != nil) {
        NSRange schemeRange = [[self absoluteString] rangeOfString:[self scheme]];
        NSString* updatedURLString = [[self absoluteString] stringByReplacingCharactersInRange:schemeRange withString:scheme];
        
        result = [NSURL URLWithString:updatedURLString];
    }else{
        result = [NSURL URLWithString:scheme];
    }
    
    return result;
}

@end
