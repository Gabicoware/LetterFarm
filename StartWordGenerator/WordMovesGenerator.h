//
//  LengthGenerator.h
//  LetterFarm
//
//  Created by Daniel Mueller on 10/16/12.
//
//

#import "BaseGenerator.h"

//When run generates the max number of moves the startWord can make
@interface WordMovesGenerator : BaseGenerator

//the max moves to calculate
@property (nonatomic) int maxMoves;

@property (nonatomic) NSString* startWord;

@end
