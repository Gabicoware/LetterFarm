//
//  SelectMatchViewController.h
//  LetterFarm
//
//  Created by Daniel Mueller on 11/29/12.
//
//

#import "MatchesViewController.h"
#import "MatchListComponent.h"

@interface SelectMatchViewController : MatchesViewController<MatchListComponent>

+(int)defaultStartingDifficulty;

@property (nonatomic) OpponentType opponentType;

-(void)reloadData;

-(NSMutableArray*)allEndedMatches;

@end
