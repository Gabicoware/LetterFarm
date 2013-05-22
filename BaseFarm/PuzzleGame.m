//
//  PuzzleGame.m
//  Letter Farm
//
//  Created by Daniel Mueller on 5/7/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import "PuzzleGame.h"

@implementation PuzzleGame

@synthesize guessedWords=_guessedWords; 
@synthesize endWord=_finalWord; 
@synthesize startWord=_startWord;
@synthesize dictionaryType=_dictionaryType;
@synthesize solutionWords=_solutionWords;
@synthesize completionDate=_completionDate;
@synthesize creationDate=_creationDate;
@synthesize playerID=_playerID;

-(NSArray*)gameWords{
    return self.guessedWords;
}

-(MatchGameOutcome)outcomeAgainstGame:(id<MatchGame>)game{
    PuzzleGame* puzzleGame = OBJECT_IF_OF_CLASS(game, PuzzleGame);
    
    MatchGameOutcome result = MatchGameNone;
    
    if (puzzleGame != nil) {
        
        BOOL selfDidComplete = [[self.guessedWords lastObject] isEqual:self.endWord];
        BOOL otherDidComplete = [[puzzleGame.guessedWords lastObject] isEqual:self.endWord];
        
        if(selfDidComplete && otherDidComplete){
            NSUInteger selfWordCount = self.guessedWords.count;
            NSUInteger gameWordCount = puzzleGame.guessedWords.count;
            
            if (selfWordCount < gameWordCount) {
                result =  MatchGameWon;
            }else if(gameWordCount < selfWordCount){
                result =  MatchGameLost;
            }else{
                result = MatchGameTied;
            }
        }else if(!selfDidComplete && !otherDidComplete){
            result = MatchGameDraw;
        }else if(selfDidComplete && !otherDidComplete){
            result = MatchGameWon;
        }else if(!selfDidComplete && otherDidComplete){
            result = MatchGameLost;
        }
        
    }
    
    return result;
}

-(NSTimeInterval)interval{
    if (self.completionDate == nil ||  self.creationDate == nil) {
        return 0;
    }else{
        return [self.completionDate timeIntervalSinceDate:self.creationDate];
    }
}

-(void)incrementGuessCount{
    _guessCount++;
}

-(NSString*)description{
    
    NSString* propertiesString = @"invalid";
    
    if (self.solutionWords != nil) {
        propertiesString = [NSString stringWithFormat:@"solution='%@'",[self.solutionWords componentsJoinedByString:@","] ];
    }else if(self.startWord != nil && self.endWord != nil){
        propertiesString = [NSString stringWithFormat:@"endWord='%@' startWord=''%@",self.startWord,self.endWord ];
    }
    
    return [NSString stringWithFormat:@"<%@: 0x%d %@ >",NSStringFromClass([self class]),(int)self,propertiesString ];
}


#define dictionaryTypeKEY @"dictionaryType"
#define endWordKEY @"endWord"
#define startWordKEY @"startWord"
#define guessedWordsKEY @"guessedWords"
#define solutionWordsKEY @"solutionWords"
#define playerIDKEY @"playerID"
#define completionDateKEY @"completionDate"
#define creationDateKEY @"creationDate"
#define guessCountKEY @"guessCount"

-(id)initWithCoder:(NSCoder *)aDecoder{
    if ((self = [super init])) {
        self.playerID = [aDecoder decodeObjectForKey:playerIDKEY];
        self.completionDate = [aDecoder decodeObjectForKey:completionDateKEY];
        self.creationDate = [aDecoder decodeObjectForKey:creationDateKEY];
        self.dictionaryType = [aDecoder decodeIntForKey:dictionaryTypeKEY];
        self.endWord = [aDecoder decodeObjectForKey:endWordKEY];
        self.startWord = [aDecoder decodeObjectForKey:startWordKEY];
        self.guessedWords = [aDecoder decodeObjectForKey:guessedWordsKEY];
        self.solutionWords = [aDecoder decodeObjectForKey:solutionWordsKEY];
        self.guessCount = [aDecoder decodeIntForKey:guessCountKEY];
        
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.playerID forKey:playerIDKEY];
    [aCoder encodeObject:self.completionDate forKey:completionDateKEY];
    [aCoder encodeObject:self.creationDate forKey:creationDateKEY];
    [aCoder encodeInt:self.dictionaryType forKey:dictionaryTypeKEY];
    [aCoder encodeObject:self.endWord forKey:endWordKEY];
    [aCoder encodeObject:self.startWord forKey:startWordKEY];
    [aCoder encodeObject:self.guessedWords forKey:guessedWordsKEY];
    [aCoder encodeObject:self.solutionWords forKey:solutionWordsKEY];
    [aCoder encodeInt:(int)self.guessCount forKey:guessCountKEY];
}

- (id)copyWithZone:(NSZone *)zone{
    PuzzleGame* game = [[[self class] allocWithZone:zone] init];
    
    game.playerID = self.playerID;
    game.completionDate = self.completionDate;
    game.creationDate = self.creationDate;
    game.guessCount = self.guessCount;
    game.dictionaryType = self.dictionaryType;
    game.endWord = self.endWord;
    game.startWord = self.startWord;
    game.guessedWords = self.guessedWords;
    game.solutionWords = self.solutionWords;
    
    return game;
}

+(id)puzzleGameWithWords:(NSArray*)words{
    PuzzleGame* result = [[PuzzleGame alloc] init];
    
    result.solutionWords = words;
    result.startWord = [words objectAtIndex:0];
    result.endWord = [words lastObject];
    result.guessedWords = [NSArray arrayWithObject:result.startWord];
    
    result.dictionaryType = result.startWord.length;
    
    return result;
}


@end
