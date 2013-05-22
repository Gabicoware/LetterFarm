//
//  FBMatchEngine.m
//  LetterFarm
//
//  Created by Daniel Mueller on 12/12/12.
//
//

#import "FBMatchEngine.h"
#import "FBInviteController.h"
#import "NSArray+LF.h"
#import "Reachability+LF.h"
#import "MatchInfo.h"
#import "Facebook.h"
#import "FBGraphObjectURLFactory.h"
#import "UIBlockAlertView.h"

NSString* FBMatchEngineHasAuthenticated = @"FBMatchEngineHasAuthenticated";

NSString* FBLocalPlayerDidAuthenticateNotification = @"FBLocalPlayerDidAuthenticateNotification";
NSString* FBFriendsDidLoadNotification = @"FBFriendsDidLoadNotification";

@protocol LFOGGame<FBGraphObject>

@property (retain, nonatomic) NSString *id;
@property (retain, nonatomic) NSString *url;

@end

@protocol LFOGPlayGameAction<FBOpenGraphAction>

@property (retain, nonatomic) id<LFOGGame> game;

@end

@protocol LFOGMatch<FBGraphObject>

@property (retain, nonatomic) NSString *id;
@property (retain, nonatomic) NSString *url;

@end

@protocol LFOGStartPlayingMatchAction<FBOpenGraphAction>

@property (retain, nonatomic) id<LFOGMatch> match;

@end


@interface FBMatchEngine()

@property (nonatomic) FBGraphObject* fbPlayer;
@property (nonatomic) FBInviteController* inviteController;

@property (nonatomic) id completion;

@end

@implementation FBMatchEngine

@synthesize fbPlayer, inviteController, completion=_completion;

+(id)sharedFBMatchEngine
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
    });
    return _sharedObject;
}

@synthesize allMatches=_allMatches;

-(id)init{
    if((self = [super init])){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleReachabilityChangedNotification:) name:kReachabilityChangedNotification object:[Reachability sharedReachability]];
    }
    return self;
}


-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)handleReachabilityChangedNotification:(id)notification{
    if ([self hasAuthenticated] && ![self isAuthenticated]) {
        [self authenticate];
    }
}

-(NSString*)playerID{
    return [self isAuthenticated] ? [self.fbPlayer objectForKey:@"id"] : nil;
}

- (BOOL)isAuthenticated{
    return [self isFBAvailable] && [[FBSession activeSession] isOpen];
}

-(BOOL)hasAuthenticated{
    return [self isFBAvailable] && [[NSUserDefaults standardUserDefaults] boolForKey:FBMatchEngineHasAuthenticated];
}

- (BOOL)isAvailable {
    return YES;
}

-(BOOL)handleOpenURL:(NSURL*)URL{
    return [[FBSession activeSession] handleOpenURL:URL];
}

-(void)authenticate{
    
    if (![self isFBAvailable]) return;
    if (![[Reachability sharedReachability] isReachable]) return;
    
    //pull these blocks out for readability and reusability
    
    //if the session opens, and we get the "me" request
    FBRequestHandler requestHandler = ^void(FBRequestConnection *request,
                                            id result,
                                            NSError *error) {
        if (!error) {
            
            self.fbPlayer = result;
            
            // get json from result
            [[NSNotificationCenter defaultCenter] postNotificationName:FBLocalPlayerDidAuthenticateNotification object:self];
            [self loadMatches];
        }
    };
    
    //if the session opens
    FBSessionStateHandler stateHandler = ^(FBSession *session,
                                           FBSessionState status,
                                           NSError *error) {
        if (session.isOpen) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:FBMatchEngineHasAuthenticated];
            [[NSUserDefaults standardUserDefaults] synchronize];
            // request basic information for the user
            [FBRequestConnection startWithGraphPath:@"me"
                                  completionHandler:requestHandler];
            
            _facebook = [[Facebook alloc] initWithAppId:session.appID andDelegate:nil];
            
            // Store the Facebook session information
            self.facebook.accessToken = session.accessToken;
            self.facebook.expirationDate = session.expirationDate;        }
    };
    
    if ([[FBSession activeSession] isOpen] == NO) {
        // log on to Facebook
        [[FBSession activeSession] openWithBehavior:FBSessionLoginBehaviorUseSystemAccountIfPresent
                  completionHandler:stateHandler];
        
    } else if(self.fbPlayer == nil){
        stateHandler([FBSession activeSession], [[FBSession activeSession] state], nil);
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:FBLocalPlayerDidAuthenticateNotification object:self];
        [self loadMatches];
    }
    
}

-(void)loadMatches{
    
    if (![self isAuthenticated]) return;
    
#warning the load matches logic needs to go here, under the best circumstances, we will load ALL the data for all the users friends at once

}

-(void)loadDataForMatch:(MatchInfo*)match withCompletionHandler:(void (^)(BOOL finished))completionHandler{
    
#warning This will most likely require loading the OTHER users actions for this app, and finding the actions that match the current game
    
}

-(BOOL)completeMatch:(MatchInfo *)matchInfo{
    if (![self isAuthenticated]) return NO;
    return NO;
}

-(BOOL)endTurnInMatch:(MatchInfo*)matchInfo{
    if (![self isAuthenticated]) return NO;
    
    BOOL requiresUI = NO;
    
    //we need to show UI when there is an invite
    if (matchInfo.games.count == 1) {
        requiresUI = YES;
    }
    
    [[FBRequest requestForGraphPath:@"me/permissions"] startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        
        id permissions = [[result objectForKey:@"data"] objectAtIndex:0];
        
        //if we have permissions
        if ([permissions objectForKey:@"publish_actions"] != nil) {
            //if this is the first game ever in the match an invitation must be sent
            if (matchInfo.games.count == 1) {
                
                self.inviteController = [[FBInviteController alloc] init];
                self.inviteController.facebook = self.facebook;
                [self.inviteController sendInviteForMatch:matchInfo withCompletion:^(BOOL didComplete){
                    if (self.completion != NULL) {
                        void (^completionBlock)(void)  = self.completion;
                        completionBlock();
                    }
                    self.completion = NULL;
                    if (didComplete) {
                        //create the match action and the game action
                        [self postActionForMatch:matchInfo completion:^{
                            [self postActionForGame:matchInfo.games.lastObject];
                        }];
                    }
                    int64_t delayInSeconds = 0.1;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        self.inviteController = nil;
                    });
                }];
                
            }else{
                [self postActionForGame:matchInfo.games.lastObject];
            }
        }else{
        
            void (^alertCompletion)(BOOL, NSInteger) = ^(BOOL cancelled, NSInteger buttonIndex){
                if (!cancelled) {
                    [[FBSession activeSession] reauthorizeWithPublishPermissions:@[@"publish_actions"]
                                                                 defaultAudience:FBSessionDefaultAudienceFriends
                                                               completionHandler:^(FBSession *session, NSError *error) {
                                                                   if (error == nil && [[session permissions] containsObject:@"publish_actions"]) {
                                                                       [self endTurnInMatch:matchInfo];
                                                                   }else{
                                                                       if (self.completion != NULL) {
                                                                           void (^completionBlock)(void)  = self.completion;
                                                                           completionBlock();
                                                                       }
                                                                       self.completion = NULL;
                                                                   }
                                                               }];
                }
            };
        
            UIBlockAlertView* alertView = [[UIBlockAlertView alloc] initWithTitle:@"Facebook Permissions"
                                                                          message:@"To play please approve permission for Letter Farm to publish to your stream ."
                                                                       completion:alertCompletion
                                                                cancelButtonTitle:@"No thanks"
                                                                otherButtonTitles:@"Ok", nil];
            [alertView show];
        }
    }];
    
    
    return requiresUI;
    //also, an action and object must be sent indicating the object
}

-(void)setCompletionBlock:(void (^)(void))completion{
    self.completion = [completion copy];
}

-(void)postActionForMatch:(id)match completion:(void (^)(void))completion{
    // First create the Open Graph meal object for the meal we ate.
    id matchObject = [self graphObjectForObject:match];
    
    // Now create an Open Graph eat action with the meal, our location,
    // and the people we were with.
    id<LFOGStartPlayingMatchAction> action = (id<LFOGStartPlayingMatchAction>)[FBGraphObject graphObject];
    action.match = matchObject;
    
    // Create the request and post the action to the
    // "me/<YOUR_APP_NAMESPACE>:eat" path.
    [FBRequestConnection startForPostWithGraphPath:@"me/letterfarm:start_playing"
                                       graphObject:action
                                 completionHandler:
     ^(FBRequestConnection *connection, id result, NSError *error) {
         NSLog(@"%@",result);
         if (error != nil) {
             completion();
         }
     }
     ];

}


-(void)postActionForGame:(id)game{
    // First create the Open Graph meal object for the meal we ate.
    id gameObject = [self graphObjectForObject:game];
    
    // Now create an Open Graph eat action with the meal, our location,
    // and the people we were with.
    id<LFOGPlayGameAction> action = (id<LFOGPlayGameAction>)[FBGraphObject graphObject];
    action.game = gameObject;
    
    // Create the request and post the action to the
    // "me/<YOUR_APP_NAMESPACE>:eat" path.
    [FBRequestConnection startForPostWithGraphPath:@"me/letterfarm:play"
                                       graphObject:action
                                 completionHandler:
     ^(FBRequestConnection *connection, id result, NSError *error) {
         NSLog(@"%@",result);
     }
     ];
}

-(void)quitMatch:(MatchInfo*)matchInfo{
    if (![self isAuthenticated]) return;
    
}

-(void)deleteMatch:(MatchInfo*)matchInfo{
    if (![self isAuthenticated]) return;
}

-(BOOL)canPlayWithMatchInfo:(MatchInfo*)matchInfo{
    return matchInfo.status == MatchStatusYourTurn;
}

-(void)updateMatchInfo:(MatchInfo*)matchInfo withSourceData:(id)sourceData{
    
}


-(void)loadMatchInfoWithSourceData:(id)sourceData completionHandler:( void (^) (MatchInfo* matchInfo))completionHandler{
    
}

-(void)loadFriends{
    
    FBRequest* request = [FBRequest requestForGraphPath:@"me/friends?fields=installed,id,name"];
    
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        self.friends = [result objectForKey:@"data"];
        [[NSNotificationCenter defaultCenter] postNotificationName:FBFriendsDidLoadNotification object:self];
    }];
}

-(MatchInfo*)matchInfoWithOpponent:(id)opponent{
    MatchInfo* result = nil;
    
    FBGraphObject* object = OBJECT_IF_OF_CLASS(opponent, FBGraphObject);
    if (object != nil) {
        
        result = [[MatchInfo alloc] init];
        
        result.opponentID = [object objectForKey:@"id"];
        result.opponentName = [object objectForKey:@"name"];
#ifndef DISABLE_FB
        result.opponentType = OpponentTypeFB;
#endif
        result.status = MatchStatusYourTurn;
        result.games = [NSArray array];
        result.tileViewLetter = [[result.opponentName substringToIndex:1] uppercaseString];
    }
    return result;
}

- (id)graphObjectForObject:(NSObject*)object
{
    
    NSURL* url = [FBGraphObjectURLFactory graphObjectURLWithObject:object];
    
    NSMutableDictionary* result = nil;
    
    if (url) {
        result = [FBGraphObject graphObject];
        [result setObject:[url absoluteString] forKey:@"url"];
    }
    return result;
}

@end
