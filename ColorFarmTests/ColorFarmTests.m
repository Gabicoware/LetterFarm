//
//  ColorFarmTests.m
//  ColorFarmTests
//
//  Created by Daniel Mueller on 4/3/13.
//
//

#import "ColorFarmTests.h"
#import "ColorWordUtilities.h"
#import "STAssertsEqualStrings.h"
#import "WordProvider.h"
#import "PuzzleGeneratorFactory.h"

@implementation ColorFarmTests

- (void)testMixing
{
    NSString* mixedColor = MixColors(@"r", @"o");
    
    STAssertEqualStrings(mixedColor, @"o", @"The mixing must produce orange");
    
}

- (void)testPermutations
{
    NSSet* perms = [[WordProvider currentWordProvider] permutationsOfWord:@"roy"];
    
    STAssertNotNil(perms, @"We shouldn't get nil");
    
}

- (void)testParticularPermutation
{
    NSString* perm = [ColorWordUtilities permutateWord:@"orogo" color:@"r" index:0];
    
    STAssertEqualStrings(perm, @"rrogo", @"should permutate correctly");
        
}


- (void)testIsValid
{
    BOOL isValidWord;
    
    isValidWord = [ColorWordUtilities isValidWord:@"oybrgpw"];
    
    STAssertTrue(isValidWord, @"Must be valid");
        
    isValidWord = [ColorWordUtilities isValidWord:@"oybtrgpw"];
    
    STAssertFalse(isValidWord, @"Must be invalid");
    
    isValidWord = [ColorWordUtilities isValidWord:@"oybrgpwt"];
    
    STAssertFalse(isValidWord, @"Must be invalid");
    
    isValidWord = [ColorWordUtilities isValidWord:@"toybrgpw"];
    
    STAssertFalse(isValidWord, @"Must be invalid");
    
}


-(void)test5Generator{
    
    PuzzleGenerator* generator = [PuzzleGeneratorFactory newGameGeneratorForType:5 withDifficulty:DifficultyVeryHard];

    [generator generate];
    
    PuzzleGame* game = OBJECT_IF_OF_CLASS([generator result], PuzzleGame);
    
    STAssertNotNil([game solutionWords], @"solution should not be nil");
}

-(void)test3Generator{
    
    for (int index = 0; index < 100; index++) {
        
        PuzzleGenerator* generator = [PuzzleGeneratorFactory newGameGeneratorForType:3 withDifficulty:DifficultyHard];
        
        [generator generate];
        
        PuzzleGame* game = OBJECT_IF_OF_CLASS([generator result], PuzzleGame);
        
        STAssertNotNil([game solutionWords], @"solution should not be nil");
        
    }
}



@end
