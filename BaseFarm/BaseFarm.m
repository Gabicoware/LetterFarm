//
//  BaseFarm.m
//  Base Farm
//
//  Created by Daniel Mueller on 8/28/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import "BaseFarm.h"

NSString* ProposedWordNotification = @"ProposedWordNotification";
NSString* ExitNotification = @"ExitNotification";
NSString* PassNotification = @"PassNotification";
NSString* MenuNotification = @"MenuNotification";
NSString* PauseNotification = @"PauseNotification";
NSString* ResumeNotification = @"ResumeNotification";

BOOL WordEditStateEquals(WordEditState a, WordEditState b);

BOOL WordEditStateEquals(WordEditState a, WordEditState b){
    return a.dragState == b.dragState && a.index == b.index;
}

const WordEditState WordEditStateNone = {DragStateNone, NSNotFound};
const WordEditState WordEditStateZero = {0, 0};

int MovesWithDifficulty(Difficulty difficulty){
#ifdef LETTER_WORD
    return difficulty;
#endif
#ifdef COLOR_WORD
    int result = 2;
    
    switch (difficulty) {
        case DifficultyEasy:
            result = 2;
            break;
        case DifficultyMedium:
            result = 3;
            break;
        case DifficultyHard:
            result = 4;
            break;
        case DifficultyVeryHard:
            result = 3;
            break;
        case DifficultyBrutal:
            result = 4;
            break;
        case DifficultyNone:
            result = 2;
            break;
    }
    
    return result;
    
    
#endif

}