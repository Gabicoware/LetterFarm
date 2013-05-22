//
//  PassNPlayOpponentController.m
//  LetterFarm
//
//  Created by Daniel Mueller on 1/15/13.
//
//

#import "PassNPlayOpponentController.h"
#import "PassNPlayMatchEngine.h"
#import "LFAlertView.h"
#import <QuartzCore/QuartzCore.h>

#define PLAYER_ONE_KEY @"PassNPlayOpponentController.playerOne.text"
#define PLAYER_TWO_KEY @"PassNPlayOpponentController.playerTwo.text"

@interface PassNPlayOpponentController()

-(IBAction)didTapDoneButton:(id)sender;
-(IBAction)didTapCancelButton:(id)sender;

@property (nonatomic) LFAlertView* alertView;
@property (nonatomic) IBOutlet UITextField* playerOneTextField;
@property (nonatomic) IBOutlet UITextField* playerTwoTextField;

@end


@implementation PassNPlayOpponentController

@synthesize matchInfo=_matchInfo;
@synthesize startingDifficulty=_startingDifficultyp;

-(id<MatchEngine>)matchEngine{
    return [PassNPlayMatchEngine sharedPassNPlayMatchEngine];
}

-(IBAction)didTapDoneButton:(id)sender{
    [self sendMatch];
    [self.alertView remove];
    self.alertView = nil;
    self.playerOneTextField = nil;
    self.playerTwoTextField = nil;
}

-(IBAction)didTapCancelButton:(id)sender{
    [self.alertView remove];
    self.alertView = nil;
    self.playerOneTextField = nil;
    self.playerTwoTextField = nil;
}

-(void)selectOpponentWithViewController:(UIViewController*)controller{
    
    NSArray* objects = [[NSBundle mainBundle] loadNibNamed:@"PNPOpponentAlertView" owner:self options:nil];
    
    self.alertView = OBJECT_IF_OF_CLASS(objects[0], LFAlertView);
    
    self.alertView.isModal = YES;
    
    self.alertView.layer.cornerRadius = 10;
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:PLAYER_ONE_KEY] != nil) {
        self.playerOneTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:PLAYER_ONE_KEY];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:PLAYER_TWO_KEY] != nil) {
        self.playerTwoTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:PLAYER_TWO_KEY];
    }
    
    [self.alertView show];
    
}
-(void)sendMatch{
    PassNPlaySourceData* match = [[PassNPlaySourceData alloc] init];
    match.matchStatus = MatchStatusYourTurn;
    match.games = [NSArray array];
    
    if (self.playerOneTextField.text.length == 0) {
        match.playerOneID = @"Player 1";
    }else{
        match.playerOneID = self.playerOneTextField.text;
        [[NSUserDefaults standardUserDefaults] setObject:match.playerOneID forKey:PLAYER_ONE_KEY];
    }
    if (self.playerTwoTextField.text.length == 0) {
        match.playerTwoID = @"Player 2";
    }else{
        match.playerTwoID = self.playerTwoTextField.text;
        [[NSUserDefaults standardUserDefaults] setObject:match.playerTwoID forKey:PLAYER_TWO_KEY];
    }
    
    self.matchInfo = nil;
    
    [[self matchEngine] loadMatchInfoWithSourceData:match completionHandler:^(MatchInfo *matchInfo) {
        
        self.matchInfo = matchInfo;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:OpponentSelectedNotification object:self];
            
            //[controller dismissModalViewControllerAnimated:YES];
        });
    } ];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if ([textField isEqual:self.playerOneTextField]) {
        [self.playerTwoTextField becomeFirstResponder];
    }else if ([textField isEqual:self.playerTwoTextField]) {
        [self didTapDoneButton:nil];
    }
    return NO;
}


@end
