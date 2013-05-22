//
//  URLTests.m
//  LetterFarm
//
//  Created by Daniel Mueller on 9/20/12.
//
//

#import "URLTests.h"
#import "LFURLCoder.h"
#import "SimpleEncrypt.h"

#define STAssertEqualStrings(string1, string2) STAssertTrue(string1 == string2 || [string1 isEqualToString:string2], @"\"%@\" must be equal to \"%@\"",string1,string2);

#define V0_PUZZLE_URL @"http://lf.gabicoware.com/?v=0&start=tad&end=sit&playerID=Daniel%20Mueller"

//puzzle only, no solution
#define V1_PUZZLE_URL @"http://lf.gabicoware.com/?v=1&start=tad&end=sit&playerID=Daniel%20Mueller"

//puzzle and a solution
#define V1_S1_PUZZLE_URL @"http://lf.gabicoware.com/?v=1&start=tad&end=sit&s=0s2t1i&playerID=Daniel%20Mueller"

//puzzle and an erroneous solution
//does not create the end word
#define V1_S1_E1_PUZZLE_URL @"http://lf.gabicoware.com/?v=1&start=tad&end=sit&s=0s2t1a&playerID=Daniel%20Mueller"
//no solution data
#define V1_S1_E2_PUZZLE_URL @"http://lf.gabicoware.com/?v=1&start=tad&end=sit&s=&playerID=Daniel%20Mueller"
//illegal words
#define V1_S1_E3_PUZZLE_URL @"http://lf.gabicoware.com/?v=1&start=tad&end=sit&s=0z0s2t1i&playerID=Daniel%20Mueller"

#define SWordsForURL(U) [[LFURLCoder decodeURL:[NSURL URLWithString:U]] solutionWords]
#define PGameForURL(U) [LFURLCoder decodeURL:[NSURL URLWithString:U]]
@implementation URLTests

-(void)testVersion1URL{
    PuzzleGame* puzzleGame = PGameForURL(V1_PUZZLE_URL);
    
    STAssertNotNil(puzzleGame, @"PuzzleGame must not be nil");
        
    STAssertTrue([[puzzleGame playerID] isEqualToString: @"Daniel Mueller"], @"playerID must be parsed");
    STAssertTrue([[puzzleGame endWord] isEqualToString:  @"sit"], @"playerID must be parsed");
    STAssertTrue([[puzzleGame startWord] isEqualToString:  @"tad"], @"playerID must be parsed");
    
    STAssertTrue([puzzleGame dictionaryType] == DictionaryTypePuzzle3, @"The dictionary type must be equal to Puzzle3");
    
    STAssertNil([puzzleGame solutionWords], @"solutionWords must be nil");
    
    [self verifyMultipleEncodings:V1_PUZZLE_URL withVersion:PuzzleURLVersionOne];
    
}

-(void)testVersion1S1URL{
    
    //we have avalid solution encoded
    STAssertNotNil(SWordsForURL(V1_S1_PUZZLE_URL), @"solutionWords must not be nil");
    
    [self verifyMultipleEncodings:V1_S1_PUZZLE_URL withVersion:PuzzleURLVersionOne];
}

-(void)testVersion2S1URL{
    
    //we have avalid solution encoded
    STAssertNotNil(SWordsForURL(V1_S1_PUZZLE_URL), @"solutionWords must not be nil");
    
    [self verifyMultipleEncodings:V1_S1_PUZZLE_URL withVersion:PuzzleURLVersionTwo];
}


-(void)testVersion1S1_Errors_URL{
    
    STAssertNil(SWordsForURL(V1_S1_E1_PUZZLE_URL), @"solutionWords must be nil");
    STAssertNil(SWordsForURL(V1_S1_E2_PUZZLE_URL), @"solutionWords must be nil");
    STAssertNil(SWordsForURL(V1_S1_E3_PUZZLE_URL), @"solutionWords must be nil");
    
}


-(void)testNilURL{
    
    NSURL* nilURL = [LFURLCoder encodePuzzleGame:nil];
    
    STAssertNil(nilURL, @"URL must be nil");
    
    PuzzleGame* puzzleGame = [LFURLCoder decodeURL:nil];
    
    STAssertNil(puzzleGame, @"PuzzleGame must be nil");
    
    PuzzleGame* v0PuzzleGame = PGameForURL(V0_PUZZLE_URL);
    
    STAssertNil(v0PuzzleGame, @"PuzzleGame must be nil");
}

-(void)verifyMultipleEncodings:(NSString*)sourceURLString withVersion:(PuzzleURLVersion)version{
    PuzzleGame* decodeGame_1 = PGameForURL(sourceURLString);
    
    NSURL* encodeURL_1 = [LFURLCoder encodePuzzleGame:decodeGame_1 withVersion:version];
    
    PuzzleGame* decodeGame_2 = [LFURLCoder decodeURL:encodeURL_1];
    
    NSURL* encodeURL_2 = [LFURLCoder encodePuzzleGame:decodeGame_2 withVersion:version];
    
    STAssertNotNil(decodeGame_1, @"decodeGame_1 should not be nil");
    STAssertNotNil(decodeGame_2, @"decodeGame_2 should not be nil");
    STAssertNotNil(encodeURL_1, @"encodeURL_1 should not be nil");
    STAssertNotNil(encodeURL_2, @"encodeURL_2 should not be nil");
    
    STAssertEqualStrings([decodeGame_2 playerID], [decodeGame_1 playerID]);
    STAssertEqualStrings([decodeGame_2 startWord], [decodeGame_1 startWord]);
    STAssertEqualStrings([decodeGame_2 endWord], [decodeGame_1 endWord]);
    STAssertEqualObjects([decodeGame_2 solutionWords], [decodeGame_1 solutionWords], @"solution should be equal");
    
    
    STAssertEqualStrings([encodeURL_1 absoluteString], [encodeURL_2 absoluteString]);
    
}

-(void)testSimpleEncrypt{
    
    NSString* originalString = @"1460&=asjbrkjhdsn";
    
    NSString* encryptedString = [SimpleEncrypt encrypt:originalString];
    
    NSString* decryptedString = [SimpleEncrypt decrypt:encryptedString];
    
    STAssertEqualObjects(originalString, decryptedString, @"the strings must be equal");
    
}

#define LF @"lf"

-(void)testScheme{
    
    NSString* originalURLString = @"http://example.com";
    
    NSURL* originalURL = [NSURL URLWithString:originalURLString];
    
    NSURL* updatedURL = [originalURL URLWithScheme:@"lf"];
    
    STAssertTrue([[updatedURL scheme] isEqualToString: @"lf"], @"should be lf");
    
    NSURL* broken1URL = [NSURL URLWithString:@"http"];
    NSURL* broken2URL = [NSURL URLWithString:@""];
    
    STAssertNoThrow([broken1URL URLWithScheme:@"lf"], @"Shouldn't throw an error");
    STAssertNoThrow([broken2URL URLWithScheme:@"lf"], @"Shouldn't throw an error");
    
    
}

#ifndef DISABLE_EMAIL

-(void)testEmail{
    
    NSString* originalURLString = @"http://example.com?v=e1";
    
    id emailMatch = [LFURLCoder decodeURL:[NSURL URLWithString:originalURLString]];
    
    STAssertNotNil(emailMatch, @"should not be nil");
    
}

#endif

@end
