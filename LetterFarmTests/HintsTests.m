//
//  HintsTests.m
//  LetterFarm
//
//  Created by Daniel Mueller on 9/16/12.
//
//

#import "HintsTests.h"
#import "HintGenerator.h"
#import "LetterWordUtilities.h"

@implementation HintsTests

-(void)testHints{
    NSSet* words = [LetterWordUtilities wordsForDictionaryType:DictionaryTypePuzzle3];
    
    HintGenerator* generator = [[HintGenerator alloc] initWithWords:words];
    
    generator.startWord = @"bad";
    generator.finalWord = @"say";
    
    [generator generate];
    
    NSArray* hint = OBJECT_IF_OF_CLASS(generator.result, NSArray);
    
    STAssertNotNil(hint, @"should be able to find a hint");
    
    STAssertTrueNoThrow([@"bad" isEqualToString:[hint objectAtIndex:0]] , @"The first object should equal bad");
    STAssertTrueNoThrow([@"say" isEqualToString:[hint lastObject]] , @"The last object should equal say");
    STAssertTrue(2 < hint.count, @"The length of the hints should be at least 3");
    
    generator.startWord = @"xxx";
    generator.finalWord = @"yyy";
    
    [generator generate];
    
    hint = OBJECT_IF_OF_CLASS(generator.result, NSArray);
    STAssertNil(hint, @"should not be able to find a hint");
}

@end
