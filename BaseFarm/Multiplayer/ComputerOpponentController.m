//
//  LocalOpponentController.m
//  LetterFarm
//
//  Created by Daniel Mueller on 7/23/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import "ComputerOpponentController.h"
#import "ComputerMatchEngine.h"

@interface ComputerOpponentController()

@end


@implementation ComputerOpponentController

@synthesize matchInfo=_matchInfo;
@synthesize startingDifficulty=_startingDifficulty;

-(id<MatchEngine>)matchEngine{
    return [ComputerMatchEngine sharedComputerMatchEngine];
}

-(void)selectOpponentWithViewController:(UIViewController*)controller{
    LocalSourceData* match = [[LocalSourceData alloc] init];
    match.matchStatus = MatchStatusYourTurn;
    match.games = [NSArray array];
    match.startingDifficulty = self.startingDifficulty;
    self.matchInfo = nil;
    
    [[self matchEngine] loadMatchInfoWithSourceData:match completionHandler:^(MatchInfo *matchInfo) {
        
        self.matchInfo = matchInfo;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:OpponentSelectedNotification object:self];
            
            [controller dismissModalViewControllerAnimated:YES];
        });
    } ];

}

@end
