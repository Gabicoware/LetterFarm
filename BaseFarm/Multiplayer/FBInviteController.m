//
//  FBInviteController.m
//  LetterFarm
//
//  Created by Daniel Mueller on 12/21/12.
//
//

#import "FBInviteController.h"

@interface FBInviteController ()

//for convenience, we set the completionBlock, instead of passing it in
@property (nonatomic, retain) id completionBlock;

@end

@implementation FBInviteController

-(void)sendInviteForMatch:(MatchInfo*)matchInfo withCompletion:(FBInviteCompleteHandler)completionBlock{
    
    self.completionBlock = [completionBlock copy];
    
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   matchInfo.opponentID,@"to",
                                   @"Let's play some rounds of Letter Farm!",@"message",
                                   nil];
    [[self facebook] dialog:@"apprequests" andParams:params andDelegate:self];
}

- (void)dialogCompleteWithUrl:(NSURL *)url{
    [self executeCompleteBlock:YES];
}

- (void)dialogDidNotCompleteWithUrl:(NSURL *)url{
    [self executeCompleteBlock:NO];
}

- (void)dialog:(FBDialog*)dialog didFailWithError:(NSError *)error{
    [self executeCompleteBlock:NO];
}

- (BOOL)dialog:(FBDialog*)dialog shouldOpenURLInExternalBrowser:(NSURL *)url{
    return NO;
}

-(void)executeCompleteBlock:(BOOL)didComplete{
    FBInviteCompleteHandler complete = self.completionBlock;
    if (complete != NULL) {
        complete(didComplete);
    }
    self.completionBlock = NULL;
}

@end
