//
//  FBInviteController.h
//  LetterFarm
//
//  Created by Daniel Mueller on 12/21/12.
//
//

#import <Foundation/Foundation.h>
#import "MatchInfo.h"
#import "Facebook.h"

typedef void(^FBInviteCompleteHandler)(BOOL didComplete);

@interface FBInviteController : NSObject<FBDialogDelegate>

-(void)sendInviteForMatch:(MatchInfo*)matchInfo withCompletion:(FBInviteCompleteHandler)completionBlock;

@property (nonatomic, retain) Facebook* facebook;

@end
