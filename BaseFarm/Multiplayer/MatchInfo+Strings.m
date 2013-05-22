//
//  MatchInfo+Strings.m
//  LetterFarm
//
//  Created by Daniel Mueller on 2/23/13.
//
//

#import "MatchInfo+Strings.h"
#import "PassNPlaySourceData.h"

@implementation MatchInfo (Strings)

-(NSString*)outcomeString{
    NSString* outcomeString = @"";
    
    if (self.opponentType == OpponentTypePassNPlay) {
        outcomeString = [self passNPlayOutcomeString];
    }else{
        outcomeString = [self multiplayerOutcomeString];
    }
    
    return outcomeString;
}

-(NSString*)passNPlayOutcomeString{
    
    PassNPlaySourceData* passNPlayMatch = OBJECT_IF_OF_CLASS( self.sourceData, PassNPlaySourceData );
    
    NSString* playerOneName = passNPlayMatch.playerOneID;
    NSString* playerTwoName = passNPlayMatch.playerTwoID;
    
    NSString* outcomeString = @"";
    
    switch(self.status){
        case MatchStatusNone:
            outcomeString = @"This game has not started yet.";
            break;
        case MatchStatusYourTurn:
            outcomeString = [NSString stringWithFormat:@"%@'s Turn", playerOneName];
            break;
        case MatchStatusTheirTurn:
            outcomeString = [NSString stringWithFormat:@"%@'s Turn", playerTwoName];
            break;
        case MatchStatusYouWon:
            outcomeString = [NSString stringWithFormat:@"%@ Won", playerOneName];
            break;
        case MatchStatusTheyWon:
            outcomeString = [NSString stringWithFormat:@"%@ Won", playerTwoName];
            break;
        case MatchStatusTied:
            outcomeString = @"Match Tied";
            break;
        case MatchStatusYouQuit:
            outcomeString = [NSString stringWithFormat:@"%@ Forfeited", playerOneName];
            break;
        case MatchStatusTheyQuit:
            outcomeString = [NSString stringWithFormat:@"%@ Forfeited", playerTwoName];
            break;
        case MatchStatusInvalid:
            outcomeString = @"Sorry, this game could not be retrieved.";
            break;
    }
    return outcomeString;
}

-(NSString*)multiplayerOutcomeString{
    NSString* outcomeString = @"";
    
    switch(self.status){
        case MatchStatusNone:
            outcomeString = @"This game has not started yet.";
            break;
        case MatchStatusYourTurn:
            outcomeString = @"Your Turn";
            break;
        case MatchStatusTheirTurn:
            outcomeString = @"Waiting For Opponent";
            break;
        case MatchStatusYouWon:
            outcomeString = @"You Won";
            break;
        case MatchStatusTheyWon:
            outcomeString = @"You Lost";
            break;
        case MatchStatusTied:
            outcomeString = @"Match Tied";
            break;
        case MatchStatusYouQuit:
            outcomeString = @"You Forfeited";
            break;
        case MatchStatusTheyQuit:
            outcomeString = @"You Won by Forfeit";
            break;
        case MatchStatusInvalid:
            outcomeString = @"Sorry, this game could not be retrieved.";
            break;
    }
    return outcomeString;
}

-(NSString*)vsString{
    NSString* vsString = @"";
    
    if (self.opponentType == OpponentTypePassNPlay) {
        PassNPlaySourceData* passNPlayMatch = OBJECT_IF_OF_CLASS( self.sourceData, PassNPlaySourceData );
        
        NSString* playerOneName = passNPlayMatch.playerOneID;
        NSString* playerTwoName = passNPlayMatch.playerTwoID;
        
        vsString = [NSString stringWithFormat:@"%@ vs. %@",playerOneName,playerTwoName];
        
    }else{
        vsString = [NSString stringWithFormat:@"vs. %@",self.opponentName];
    }
    
    return vsString;
}


-(NSString*)mainString{
    
    NSString* mainString = @"Automatching";
    
    if ([self opponentName] != nil) {
        mainString = [self vsString];
    }
    return mainString;
}



-(NSString*)roundString{
    
    int round = self.roundCount;
    
    NSString* result = @"";
    
    MatchStatus matchStatus = self.status;
    
    BOOL isActive = matchStatus == MatchStatusNone || matchStatus ==MatchStatusYourTurn || matchStatus == MatchStatusTheirTurn;
    
    if (isActive) {
        if (self.games.count == 0) {
            result = @"Created";
        }else{
            result = [NSString stringWithFormat:@"Round %d updated ", round];
        }
    }else{
        result = [NSString stringWithFormat:@"%d Rounds completed ", round];
    }
    
    return result;
    
}

+(UIColor*)neutralColor{
    return [UIColor colorWithWhite:0.80 alpha:1.0];
}

-(UIColor*)matchColor{
    if ( self.status == MatchStatusTheyWon) {
        return [UIColor colorWithRed:1.0 green:0.80 blue:0.80 alpha:1.0];
    }else if( self.status == MatchStatusYouWon){
        return [UIColor colorWithRed:0.80 green:1.0 blue:0.80 alpha:1.0];
    }else{
        return [MatchInfo neutralColor];
    }
}


-(NSString*)timeString{
    
    return [MatchInfo timeStringWithDate:self.updatedDate];
    
}

+(NSString*)timeStringWithDate:(NSDate*)date{
    NSString* completionDateString = @"";
        
    if (date != nil) {
        
        NSTimeInterval f_interval = -1*[date timeIntervalSinceNow];
        
        if (f_interval < 120) {
            completionDateString = @"a minute ago";
        }else if(f_interval < 55*60){
            int i_min = roundf(f_interval/60.0);
            
            completionDateString = [NSString stringWithFormat:@"%d minutes ago",i_min];
        }else if(f_interval < 90*60){
            completionDateString = @"an hour ago";
        }else if(f_interval < 20*60*60){
            int i_min = roundf(f_interval/(60.0*60.0));
            
            completionDateString = [NSString stringWithFormat:@"%d hours ago",i_min];
            
        }else if(f_interval < 36*60*60){
            completionDateString = @"yesterday";
        }else if(f_interval < 6.5*24*60*60){
            int i_min = roundf(f_interval/(24.0*60.0*60.0));
            
            completionDateString = [NSString stringWithFormat:@"%d days ago",i_min];
            
        }else if(f_interval < 1.5*7.0*24*60*60){
            completionDateString = @"a week ago";
        }else{
            int i_min = roundf(f_interval/(7.0*24.0*60.0*60.0));
            
            completionDateString = [NSString stringWithFormat:@"%d weeks ago",i_min];
            
        }
        
    }
    
    return completionDateString;
}


-(NSString*)detailString{
    
    NSString* roundString = [self roundString];
    
    NSString* timeString = [self timeString];
    
    return [NSString stringWithFormat:@"%@ %@",roundString,timeString];
}


@end
