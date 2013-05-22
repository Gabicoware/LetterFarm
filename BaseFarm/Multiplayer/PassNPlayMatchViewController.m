//
//  PassNPlayMatchViewController.m
//  LetterFarm
//
//  Created by Daniel Mueller on 1/17/13.
//
//

#import "PassNPlayMatchViewController.h"
#import "PuzzleGame.h"
#import "PassNPlaySourceData.h"

@interface PassNPlayMatchViewController ()

@end

@implementation PassNPlayMatchViewController

-(NSString*)nextRoundText{
    if(self.matchInfo.games.count == 0){
        return @"Start First Round";
    }else{
        return [super nextRoundText];
    }
}

-(NSString*)opponentLabelText{
    
    
    PassNPlaySourceData* passNPlayMatch = OBJECT_IF_OF_CLASS( self.matchInfo.sourceData, PassNPlaySourceData );
    
    NSString* playerOneName = passNPlayMatch.playerOneID;
    NSString* playerTwoName = passNPlayMatch.playerTwoID;
    
    NSString* result = @"";
    
    switch(self.matchInfo.status){
        case MatchStatusYourTurn:
        case MatchStatusYouWon:
        case MatchStatusYouQuit:
            result = [NSString stringWithFormat:@"vs. %@",playerTwoName];
            break;
        case MatchStatusTheirTurn:
        case MatchStatusTheyWon:
        case MatchStatusTheyQuit:
            result = [NSString stringWithFormat:@"vs. %@",playerOneName];
            break;
        case MatchStatusNone:
        case MatchStatusTied:
        case MatchStatusInvalid:
            result = [NSString stringWithFormat:@"%@ vs. %@",playerOneName,playerTwoName];
            break;
    }
    
    return result; 
}

-(NSString*)yourName{
    PassNPlaySourceData* passNPlayMatch = OBJECT_IF_OF_CLASS( self.matchInfo.sourceData, PassNPlaySourceData );
    return passNPlayMatch.playerOneID;
}

-(NSString*)detailTextForIndex:(NSInteger)index{
    
    id<MatchGame> secondGame = [self secondGameAtIndex:index];
    
    NSString* result = @"";
    
    if (secondGame == nil) {
        NSString* playerName = @"Player";
        
        PassNPlaySourceData* passNPlayMatch = OBJECT_IF_OF_CLASS( self.matchInfo.sourceData, PassNPlaySourceData );
        
        if (self.matchInfo.status == MatchStatusYourTurn) {
            playerName = passNPlayMatch.playerOneID;
        }else if (self.matchInfo.status == MatchStatusTheirTurn) {
            playerName = passNPlayMatch.playerTwoID;
        }

        result = [NSString stringWithFormat:@"%@'s Turn, Tap Here", playerName];
    }else{
        result = [super detailTextForIndex:index];
    }
    return result;
    
}

-(BOOL)isActiveAtIndex:(int)index{
    id firstGame = [self firstGameAtIndex:index];
    id secondGame = [self secondGameAtIndex:index];
    
    BOOL hasGame = firstGame != nil;
    BOOL needsPassNPlayTurn = secondGame == nil && self.matchInfo.opponentType == OpponentTypePassNPlay && self.matchInfo.status == MatchStatusTheirTurn;
    BOOL needsPlayersTurn = secondGame == nil && self.matchInfo.status == MatchStatusYourTurn;
    return hasGame && (needsPlayersTurn || needsPassNPlayTurn);
}

@end
