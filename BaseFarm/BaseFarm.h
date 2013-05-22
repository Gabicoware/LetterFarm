//
//  BaseFarm.h
//  Base Farm
//
//  Created by Daniel Mueller on 4/19/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//


extern NSString* UpdateWorldThemeNotification;
extern NSString* UpdateWorldThemeNameKey;
extern NSString* WorldThemeSummer;
extern NSString* WorldThemeAutumn;
extern NSString* WorldThemeWinter;
extern NSString* WorldThemeSpring;

extern NSString* ProposedWordNotification;
extern NSString* MenuNotification;
extern NSString* ExitNotification;
extern NSString* PassNotification;
extern NSString* PauseNotification;
extern NSString* ResumeNotification;

typedef struct{
    int index;
    char letter;
} NeededMove;


#ifdef LETTER_WORD
#define DifficultyStarting 3
#endif
#ifdef COLOR_WORD
#define DifficultyStarting 1
#endif

typedef enum{
    DifficultyNone=0,
    DifficultyEasy=DifficultyStarting,
    DifficultyMedium,
    DifficultyHard,
    DifficultyVeryHard,
    DifficultyBrutal,
}Difficulty;

int MovesWithDifficulty(Difficulty difficulty);

#define NeededMoveEmpty { -1, '\0' }

typedef enum{
    DictionaryTypeNone,
    DictionaryTypeAll=2,//The validation dictionary for all games
    DictionaryTypePuzzle3=3,//The puzzle generation dictionary for 3 letter puzzles
    DictionaryTypePuzzle4=4,
    DictionaryTypePuzzle5=5,
    DictionaryTypeAll3=8,//All three letter words
    DictionaryTypeAll4=9,
    DictionaryTypeAll5=10,
}DictionaryType;

typedef enum _DragState{
    DragStateNone,//no tile is being dragged
    DragStateDragInactive,//the tile is being dragged but the word is not activated
    DragStateDragActiveReplace,//the tile is being dragged and is in position to replace a letter
    DragStateDragActiveInsert,//the tile is being dragged and is in position to be inserted between letters
    DragStateDragActiveDelete
}DragState;

typedef struct {
    DragState dragState;
    NSInteger index;
}WordEditState;

extern BOOL WordEditStateEquals(WordEditState a, WordEditState b);

extern const WordEditState WordEditStateNone;
extern const WordEditState WordEditStateZero;

@protocol GameViewController <NSObject>

@end

@class MatchInfo;
@protocol PauseViewController <NSObject>

@property (nonatomic, retain) id<GameViewController> gameViewController;
@property (nonatomic, retain) MatchInfo* matchInfo;

@end

