//
//  LetterFarmTests.m
//  LetterFarmTests
//
//  Created by Daniel Mueller on 4/21/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import "LetterFarmTests.h"
#import "LetterWordUtilities.h"
#import "BaseFarm.h"

@interface LetterFarmTests()

-(void)checkWord:(NSString*)word shouldFind:(BOOL)shouldFind;

@end

@implementation LetterFarmTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}



-(void)testWordValidity{
    
    [self checkWord:@"yes" shouldFind:YES];
    [self checkWord:@"ye" shouldFind:NO];
    [self checkWord:@"nope" shouldFind:YES];
    [self checkWord:@"no" shouldFind:NO];
}


-(void)checkWord:(NSString*)word shouldFind:(BOOL)shouldFind{
    
    BOOL isValid = [LetterWordUtilities isValidWord:word];
    
    if (shouldFind) {
        STAssertTrue(isValid,@"should have found %@", word);
    }else{
        STAssertFalse(isValid,@"should not have found %@", word);
    }
    
}

-(void)testFilteredDictionary{
    NSSet* all3Words = [LetterWordUtilities wordsForDictionaryType:DictionaryTypeAll3];
    
    STAssertNotNil(all3Words, @"Must not be nil");
    
    STAssertTrue(0 < [all3Words count], @"must have at least one word");
    
    for (NSString* string in all3Words) {
        STAssertTrue(3 == [string length], @"string must be 3 letters long");
    }
    
}

-(void)testMoveFilteredDictionary{
    NSSet* move4_3Words = [LetterWordUtilities wordsForDictionaryType:DictionaryTypePuzzle3 moveCount:4];
    
    STAssertNotNil(move4_3Words, @"Must not be nil");
    
    STAssertTrue(0 < [move4_3Words count], @"must have at least one word");
    
    NSSet* move4_4Words = [LetterWordUtilities wordsForDictionaryType:DictionaryTypePuzzle4 moveCount:4];
    
    STAssertNotNil(move4_4Words, @"Must not be nil");
    
    STAssertTrue(0 < [move4_4Words count], @"must have at least one word");

    NSSet* move4_5Words = [LetterWordUtilities wordsForDictionaryType:DictionaryTypePuzzle5 moveCount:4];
    
    STAssertNotNil(move4_5Words, @"Must not be nil");
    
    STAssertTrue(0 < [move4_5Words count], @"must have at least one word");
}


@end
