//
//  GKMatchEngine.m
//  LetterFarm
//
//  Created by Daniel Mueller on 7/14/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import "GKMatchEngine.h"
#import "NSArray+LF.h"
#import "Reachability+LF.h"
#import "MatchInfo+Puzzle.h"
#import "GKSourceData.h"
#import "UIBlockAlertView.h"

NSString* GKMatchEngineHasAuthenticatedKey = @"GKMatchEngineHasAuthenticated";

NSString* GKLocalPlayerDidAuthenticateNotification = @"GKLocalPlayerDidAuthenticateNotification";
NSString* GKHandleInviteNotification = @"GKHandleInviteNotification";
NSString* GKHandleInvitePlayersToInviteKey = @"GKHandleInvitePlayersToInviteKey";

@interface GKTurnBasedMatch (LF)

-(GKTurnBasedParticipant*)localParticipant;

-(BOOL)isLocalPlayerCurrentParticipant;

@end

@interface GKTurnBasedParticipant (LF)

-(BOOL)isLocalPlayer;

@end

@implementation GKTurnBasedMatch (LF)

-(BOOL)isLocalPlayerCurrentParticipant{
    return [self.currentParticipant isLocalPlayer];
}
-(GKTurnBasedParticipant*)localParticipant{
    GKTurnBasedParticipant* localParticipant = nil;
    
    for (GKTurnBasedParticipant* participant in [self participants]) {
        if ([participant isLocalPlayer]) {
            localParticipant = participant;
        }
    }
    
    return localParticipant;
}

                                                 

@end

@implementation GKTurnBasedParticipant (LF)

-(BOOL)isLocalPlayer{
    return [self.playerID isEqualToString:GKLocalPlayer.localPlayer.playerID];
}
@end

@interface GKMatchEngine()

-(GKTurnBasedParticipant*)nextParticipantWithParticipants:(NSArray*)participants;

@end

@implementation GKMatchEngine

@synthesize allMatches=_allMatches;

@synthesize players=_players;

+ (id)sharedGKMatchEngine
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
    });
    return _sharedObject;
}

-(id)init{
    if((self = [super init])){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleReachabilityChangedNotification:) name:kReachabilityChangedNotification object:[Reachability sharedReachability]];
        
        [GKTurnBasedEventHandler sharedTurnBasedEventHandler].delegate = self;
        
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
    return [self isAuthenticated] ? [[GKLocalPlayer localPlayer] playerID] : nil;
}

- (BOOL)isAuthenticated{
    return [self isAvailable] && [GKLocalPlayer localPlayer].authenticated == YES;
}

-(BOOL)hasAuthenticated{
    return [self isAvailable] && [[NSUserDefaults standardUserDefaults] boolForKey:GKMatchEngineHasAuthenticatedKey];
}

- (BOOL)isAvailable {
    // check for presence of GKTurnBasedMatch API
    Class gcClass = (NSClassFromString(@"GKTurnBasedMatch"));
    
    // check if the device is running iOS 4.1 or later
    NSString *reqSysVer = @"5.0";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer     
                                           options:NSNumericSearch] != NSOrderedAscending);
    
    return (gcClass && osVersionSupported);
}

-(void)authenticate{
    
    if (![self isAvailable]) return;
    if (![[Reachability sharedReachability] isReachable]) return;
    
    if ([GKLocalPlayer localPlayer].authenticated == NO) {
        
        [[GKLocalPlayer localPlayer] 
         authenticateWithCompletionHandler:^(NSError* error){
             if (error == nil) {
                 [[NSNotificationCenter defaultCenter] postNotificationName:GKLocalPlayerDidAuthenticateNotification object:self];
                 [self loadMatches];
                 
                 [[NSUserDefaults standardUserDefaults] setBool:YES forKey:GKMatchEngineHasAuthenticatedKey];
                 [[NSUserDefaults standardUserDefaults] synchronize];
             }
         }];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:GKLocalPlayerDidAuthenticateNotification object:self];
        [self loadMatches];
    }

}

-(GKTurnBasedParticipant*)nextParticipantWithParticipants:(NSArray*)participants{
    
    if (![self isAuthenticated]) return nil;
    
    GKTurnBasedParticipant* nextParticipant = nil;
    
    if ([GKLocalPlayer localPlayer].authenticated == YES) {     
        
        NSInteger indexOfLocalPlayer = NSNotFound;
        
        for (NSInteger index = 0; index < [participants count]; index++) {
            GKTurnBasedParticipant* participant = [participants objectAtIndex:index];
            if ([participant.playerID isEqualToString:[[GKLocalPlayer localPlayer] playerID]]) {
                indexOfLocalPlayer = index;
            }
            
        }
        
        if (indexOfLocalPlayer != NSNotFound) {
            
            NSInteger indexOfNextParticipant = (indexOfLocalPlayer + 1)%([participants count]);
            
            nextParticipant = [participants objectAtIndex:indexOfNextParticipant];
            
        }
        
    }
    
    return nextParticipant;
}

-(void)loadMatches{
    
    if (![self isAuthenticated]) return;
    
    [GKTurnBasedMatch loadMatchesWithCompletionHandler:^(NSArray *matches, NSError *error){
                
        if (error == nil) {
            if (self.allMatches == nil) {
                self.allMatches = [NSMutableDictionary dictionaryWithCapacity:matches.count];
            }
            
            NSMutableSet* playerIdentifiers = [NSMutableSet setWithCapacity:matches.count];
            
            
#ifdef DEBUG
            GKTurnBasedMatch* endedMatch = nil;
#endif
            
            for(GKTurnBasedMatch* gkMatch in matches){
                
                MatchInfo* matchInfo = [self.allMatches objectForKey:gkMatch.matchID];
                
                if (matchInfo == nil) {
                    matchInfo = [[MatchInfo alloc] init];
                    
                    [self.allMatches setObject:matchInfo forKey:[gkMatch matchID]];
                }
                
                BOOL needsUpdate = [self updateMatchInfo:matchInfo withSourceData: [self sourceDataWithObject:gkMatch] ];
                
                
                if (needsUpdate) {
                    matchInfo.sourceData = nil;
                    
                    [self updateMatchInfo:matchInfo withSourceData: [self sourceDataWithObject:gkMatch] ];
                    
                    [self loadDataForMatch:matchInfo withCompletionHandler:^(BOOL finished) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:MatchesDidLoadNotification object:self];
                        });
                        
                    }];
                }
                
                [self addPlayerIdentifiersFroMatch:gkMatch toIdentifiers:playerIdentifiers];
                
#ifdef DEBUG
                if (gkMatch.status == GKTurnBasedMatchStatusEnded) {
                    endedMatch = gkMatch;
                }
#endif
            
            }
            
            [self loadPlayersForIdentifiers:playerIdentifiers withCompletionHandler:^{
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:MatchesDidLoadNotification object:self];
                });
                
            }];
            
        }
    }];
}

-(GKTurnBasedMatch*)turnBasedMatchWithObject:(id)data{
    GKTurnBasedMatch* turnBasedMatch = OBJECT_IF_OF_CLASS( data, GKTurnBasedMatch);
    
    if (turnBasedMatch == nil) {
        GKSourceData* gkSourceData = [self sourceDataWithObject:data];
        
        turnBasedMatch = gkSourceData.match;

    }
    return turnBasedMatch;
}

-(GKSourceData*)sourceDataWithObject:(id)data{
    GKSourceData* gkSourceData = OBJECT_IF_OF_CLASS( data, GKSourceData);
    
    GKTurnBasedMatch* gkMatch = OBJECT_IF_OF_CLASS( data, GKTurnBasedMatch);
    
    if ( gkSourceData == nil && gkMatch != nil ) {
        
        MatchInfo* matchInfo = [self.allMatches objectForKey:gkMatch.matchID];
        
        gkSourceData = OBJECT_IF_OF_CLASS(matchInfo.sourceData, GKSourceData);
        
        if (gkSourceData == nil) {
            gkSourceData = [[GKSourceData alloc] init];
        }
        
        gkSourceData.match = gkMatch;
        
    }
    
    return gkSourceData;
    
}

-(void)loadDataForMatch:(MatchInfo*)match withCompletionHandler:(void (^)(BOOL finished))completionHandler{
    
    GKTurnBasedMatch* gkMatch = [self turnBasedMatchWithObject:match.sourceData];
    
    [gkMatch loadMatchDataWithCompletionHandler:^(NSData *matchData, NSError *error) {
        @try {
            
            GKSourceData* sourceData = [GKSourceData sourceDataWithArchiveData:matchData];
            
            sourceData.match = gkMatch;
            
            match.sourceData = sourceData;
            
            match.startingDifficulty = sourceData.startingDifficulty;
            
            match.games = sourceData.games;
            
            int difficulty =[MatchInfo currentDifficultyWithMin:sourceData.startingDifficulty games:match.games];
            
            match.tileViewLetter = [NSString stringWithFormat:@"%d",difficulty];
            
        }
        @catch (NSException *exception) {}
        @finally {}
        
        completionHandler(match.games != nil);
    }];
    
    
}

-(BOOL)completeMatch:(MatchInfo *)matchInfo{
    if (![self isAuthenticated]) return NO;
    
    GKTurnBasedMatch* gkMatch = [self turnBasedMatchWithObject:matchInfo.sourceData];
    
    MatchStatus status = matchInfo.status;
    
    GKTurnBasedMatchOutcome yourOutcome = GKTurnBasedMatchOutcomeNone;
    GKTurnBasedMatchOutcome theirOutcome = GKTurnBasedMatchOutcomeNone;
        
    switch (status) {
        case MatchStatusYouWon:
            yourOutcome = GKTurnBasedMatchOutcomeWon;
            theirOutcome = GKTurnBasedMatchOutcomeLost;
            break;
        case MatchStatusTheyWon:
            yourOutcome = GKTurnBasedMatchOutcomeLost;
            theirOutcome = GKTurnBasedMatchOutcomeWon;
            break;
        case MatchStatusTied:
            yourOutcome = GKTurnBasedMatchOutcomeTied;
            theirOutcome = GKTurnBasedMatchOutcomeTied;
            break;
        default:
            break;
    }
    
    for (GKTurnBasedParticipant* participant in [gkMatch participants]) {
        if ([[participant playerID] isEqualToString:[[GKLocalPlayer localPlayer] playerID]]) {
            [participant setMatchOutcome:yourOutcome];
        }else{
            [participant setMatchOutcome:theirOutcome];
        }
    }
    
    GKSourceData* sourceData = [self sourceDataWithObject:matchInfo.sourceData];
    sourceData.games = matchInfo.games;
    sourceData.currentGame = matchInfo.currentGame;
    NSData* data = [sourceData archiveData];
    
    if (1000 < data.length) {
        NSLog(@"Data greater than 1kb found");
    }
    
    [gkMatch endMatchInTurnWithMatchData:data completionHandler:^(NSError *error) {
        if (error != nil) {
            NSLog(@"%@",error);
        }else{
            [[GKMatchEngine sharedGKMatchEngine] loadMatches];
        }
    }];
    return NO;
}

-(BOOL)endTurnInMatch:(MatchInfo*)matchInfo{
    if (![self isAuthenticated]) return NO;
    
    GKSourceData* sourceData = [self sourceDataWithObject:matchInfo.sourceData];
    
    GKTurnBasedMatch* gkMatch = sourceData.match;
    
    matchInfo.status = MatchStatusTheirTurn;
    
    GKTurnBasedParticipant * nextParticipant = [[GKMatchEngine sharedGKMatchEngine] nextParticipantWithParticipants:[gkMatch participants]];
    
    sourceData.games = matchInfo.games;
    sourceData.currentGame = matchInfo.currentGame;
    NSData* data = [sourceData archiveData];
    
    if (1000 < data.length) {
        NSLog(@"Data greater than 1kb found");
    }

    [gkMatch endTurnWithNextParticipant:nextParticipant matchData:data 
                    completionHandler:^(NSError* error){
                        if (error != nil) {
                            NSLog(@"%@", error);
                        }else{
                            [self loadMatches];
                            //note that the next player is taking their turn
                        }
                    }];
    return NO;
}

-(void)quitMatch:(MatchInfo*)matchInfo{
    
    GKSourceData* sourceData = [self sourceDataWithObject:matchInfo.sourceData];
    
    GKTurnBasedMatch* gkMatch = sourceData.match;
    
    if (gkMatch.status != GKTurnBasedMatchStatusEnded) {
        
        void (^completionHandler)(NSError* error)=^(NSError *error) {
            if (error != nil) {
                NSLog(@"%@",error);
            }else{
                [self loadMatches];
            }
        };
        
        if([gkMatch isLocalPlayerCurrentParticipant]){
            
            GKTurnBasedParticipant* nextParticipant = [self nextParticipantWithParticipants:[gkMatch participants]];
            
            sourceData.games = matchInfo.games;
            sourceData.currentGame = matchInfo.currentGame;
            NSData* data = [sourceData archiveData];
            
            if (1000 < data.length) {
                NSLog(@"Data greater than 1kb found");
            }

            [gkMatch participantQuitInTurnWithOutcome:GKTurnBasedMatchOutcomeQuit 
                                      nextParticipant:nextParticipant 
                                            matchData:data 
                                    completionHandler:completionHandler];
        }else{
            [gkMatch participantQuitOutOfTurnWithOutcome:GKTurnBasedMatchOutcomeQuit 
                                   withCompletionHandler:completionHandler];
        }
        
    }
}

-(void)saveMatch:(MatchInfo*)matchInfo{
    GKSourceData* sourceData = [self sourceDataWithObject:matchInfo.sourceData];
    
    GKTurnBasedMatch* gkMatch = sourceData.match;
    
    if([gkMatch isLocalPlayerCurrentParticipant] && [gkMatch respondsToSelector:@selector(saveCurrentTurnWithMatchData:completionHandler:)]){
        
        sourceData.games = matchInfo.games;
        sourceData.currentGame = matchInfo.currentGame;
        NSData* data = [sourceData archiveData];
        
        //if there is an error, we are screwed anyway
        [gkMatch saveCurrentTurnWithMatchData:data completionHandler:NULL];
    }

}

-(void)deleteMatch:(MatchInfo*)matchInfo{
    GKTurnBasedMatch* gkMatch = [self turnBasedMatchWithObject:matchInfo.sourceData];
    [gkMatch removeWithCompletionHandler:^(NSError *error) { 
        if(error != nil){ NSLog(@"%@",error);}
    }];
}

-(BOOL)canPlayWithMatchInfo:(MatchInfo*)matchInfo{
    GKTurnBasedMatch* gkMatch = [self turnBasedMatchWithObject:matchInfo.sourceData];
    return [gkMatch isLocalPlayerCurrentParticipant];
}

-(void)addPlayerIdentifiersFroMatch:(GKTurnBasedMatch*)gkMatch toIdentifiers:(NSMutableSet*)identifiers{
    for (GKTurnBasedParticipant* participant in [gkMatch participants] ) {
        
        NSString* playerId = [participant playerID];
        
        if (![participant isLocalPlayer] && [participant playerID] != nil ) {
            [identifiers addObject:playerId];
        }
    }

}

-(BOOL)updateMatchInfo:(MatchInfo*)matchInfo withSourceData:(GKSourceData*)sourceData{
    
    BOOL needsUpdate = NO;
    
#ifndef DISABLE_GK
    
    GKTurnBasedMatch* gkMatch = sourceData.match;
    
    matchInfo.matchID = [NSString stringWithFormat:@"%d%@",OpponentTypeGK,gkMatch.matchID];
    
    matchInfo.opponentType = OpponentTypeGK;
    matchInfo.sourceData = gkMatch;
    
    matchInfo.createdDate = gkMatch.creationDate;
    
    BOOL hasSetStatus = NO;
    
    NSDate* updatedDate = gkMatch.creationDate;
    
    for (GKTurnBasedParticipant* participant in [gkMatch participants] ) {
        
        GKTurnBasedMatchOutcome status = [participant matchOutcome];
        
        if (0 < [[participant lastTurnDate] timeIntervalSinceDate:updatedDate]) {
            updatedDate = [participant lastTurnDate];
        }
        
        if (status == GKTurnBasedMatchOutcomeWon) {
            hasSetStatus = YES;
            if ([participant isLocalPlayer]) {
                matchInfo.status = MatchStatusYouWon;
            }else{
                matchInfo.status = MatchStatusTheyWon;
            }
        }else if (status == GKTurnBasedMatchOutcomeQuit || status == GKTurnBasedMatchOutcomeTimeExpired) {
            hasSetStatus = YES;
            if ([participant isLocalPlayer]) {
                matchInfo.status = MatchStatusYouQuit;
            }else{
                matchInfo.status = MatchStatusTheyQuit;
            }
        }
                
        if (![participant isLocalPlayer]){
            
            if ([participant playerID] == nil) {
                [matchInfo setOpponentID:nil];
                [matchInfo setOpponentName:nil];
            }else{
                [matchInfo setOpponentID:[participant playerID]];
                [matchInfo setOpponentName:nil];
            }
            
        }
    }
    
    needsUpdate = matchInfo.updatedDate != nil && [updatedDate timeIntervalSinceDate:matchInfo.updatedDate] != 0;
    
    matchInfo.updatedDate = updatedDate;
    
    if (!hasSetStatus && gkMatch.status != GKTurnBasedMatchStatusEnded) {
        if ([gkMatch isLocalPlayerCurrentParticipant]) {
            matchInfo.status = MatchStatusYourTurn;
        }else{
            matchInfo.status = MatchStatusTheirTurn;
        }
    }
#endif
    return needsUpdate;
}


-(void)loadMatchInfoWithSourceData:(id)sourceData completionHandler:( void (^) (MatchInfo* matchInfo))completionHandler{
    
    GKSourceData* gkSourceData = [self sourceDataWithObject:sourceData];
    
    GKTurnBasedMatch* gkMatch = gkSourceData.match;
    
    
    NSMutableSet* playerIdentifiers = [NSMutableSet set];
    
    MatchInfo* matchInfo = [self.allMatches objectForKey:gkMatch.matchID];
    
    if (matchInfo == nil) {
        matchInfo = [[MatchInfo alloc] init];
        [self.allMatches setObject:matchInfo forKey:[gkMatch matchID]];
    }
    
    [self updateMatchInfo:matchInfo withSourceData:gkSourceData];
    
    [self addPlayerIdentifiersFroMatch:gkMatch toIdentifiers:playerIdentifiers];
    
    [self loadPlayersForIdentifiers:playerIdentifiers withCompletionHandler:^{
        [self loadDataForMatch:matchInfo withCompletionHandler:^(BOOL finished) {
            
            
            
            completionHandler(matchInfo);
        }];
    }];

}

-(void)loadPlayersForIdentifiers:(NSSet*)identifiers withCompletionHandler:(void(^)(void))completionHandler{
    
    
    if ( 0 < [identifiers count]) {
        
        [GKPlayer loadPlayersForIdentifiers:[identifiers allObjects] withCompletionHandler:^(NSArray *players, NSError *error) {
            
            if (error == nil) {
                
                if (self.players == nil) {
                    self.players = [NSMutableDictionary dictionaryWithCapacity:players.count];
                }
                for (GKPlayer* player in players) {
                    [self.players setObject:player forKey:[player playerID]];
                }
                for(MatchInfo* matchInfo in [[self allMatches] allValues]){
                    
                    if ([matchInfo opponentID] != nil) {
                        
                        GKPlayer* player = [[self players] objectForKey:[matchInfo opponentID]];
                        
                        if (player != nil) {
                            [matchInfo setOpponentName:[player alias]];
                        }
                    
                    }
                    
                }
                
                completionHandler();
                
            }
        }];
    }else{
        completionHandler();
    }
}

#pragma mark GKTurnBasedEventHandlerDelegate

#define INVITE_MESSAGE @"You have been invited to play a match vs. %@. Would you like to accept?"

-(void)handleInviteFromGameCenter:(NSArray *)playersToInvite {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:GKHandleInviteNotification
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:playersToInvite
                                                                                           forKey:GKHandleInvitePlayersToInviteKey]];
}

- (void)handleTurnEventForMatch:(GKTurnBasedMatch *)match didBecomeActive:(BOOL)didBecomeActive{
    [self loadMatches];
    
    if ( [self.allMatches objectForKey:match.matchID] != nil  ) {
        
        MatchInfo* matchInfo = [self.allMatches objectForKey:match.matchID];
        [self updateMatchInfo:matchInfo withSourceData: [self sourceDataWithObject:match] ];
        
        [self loadDataForMatch:matchInfo withCompletionHandler:^(BOOL finished) {
            
            NSDictionary* userInfo = [NSDictionary dictionaryWithObject:matchInfo forKey:MatchDidUpdateMatchKey];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:MatchDidUpdateNotification object:self userInfo:userInfo];
        }];
    }
}
- (void)handleTurnEventForMatch:(GKTurnBasedMatch *)match{
    [self handleTurnEventForMatch:match didBecomeActive:YES];
}

#define ENDED_WIN_MESSAGE @"You won your match with %@. View now?"
#define ENDED_LOSE_MESSAGE @"You won your match with %@. View now?"
#define ENDED_MESSAGE @"Your match with %@ is complete. View now?"

#define ENDED_TITLE @"Match Complete"

- (void)handleMatchEnded:(GKTurnBasedMatch *)match{
    
    [self loadMatches];
    
    if ( [self.allMatches objectForKey:match.matchID] != nil  ) {
        
        MatchInfo* matchInfo = [self.allMatches objectForKey:match.matchID];
        [self updateMatchInfo:matchInfo withSourceData: [self sourceDataWithObject:match] ];
        
    }
    
    NSString* playerID = nil;
    
    GKTurnBasedParticipant* currentParticipant = nil;
    
    for (GKTurnBasedParticipant* participant in match.participants) {
        if(![[[GKLocalPlayer localPlayer] playerID] isEqualToString:participant.playerID]){
            playerID = participant.playerID;
        }else{
            currentParticipant = participant;
        }
    }
    
    if (playerID != nil) {
        
        NSArray* playerIdentifiers = [NSArray arrayWithObject:playerID];
        
        [GKPlayer loadPlayersForIdentifiers:playerIdentifiers withCompletionHandler:^(NSArray *players, NSError *error) {
            
            if (error == nil && [self.allMatches objectForKey:match.matchID] != nil  ) {
                
                
                GKPlayer* player = OBJECT_AT_INDEX_IF_OF_CLASS(players, 0, GKPlayer);
                
                NSString* message = nil;
                
                if (currentParticipant.matchOutcome == GKTurnBasedMatchOutcomeWon) {
                    message = [NSString stringWithFormat:ENDED_WIN_MESSAGE, player.displayName];
                }else if (currentParticipant.matchOutcome == GKTurnBasedMatchOutcomeLost) {
                    message = [NSString stringWithFormat:ENDED_LOSE_MESSAGE, player.displayName];
                }else{
                    message = [NSString stringWithFormat:ENDED_MESSAGE, player.displayName];
                }
                
                UIBlockAlertView* alertView = [[UIBlockAlertView alloc] initWithTitle:ENDED_TITLE
                                                                              message:message
                                                                           completion:^(BOOL cancelled, NSInteger buttonIndex) {
                                                                               if (buttonIndex == 1) {
                                                                                   MatchInfo* matchInfo = [self.allMatches objectForKey:match.matchID];
                                                                                   [[NSNotificationCenter defaultCenter] postNotificationName:MatchEngineSelectMatchNotification object:matchInfo];
                                                                               }
                                                                           } cancelButtonTitle:@"Close" otherButtonTitles:@"View", nil];
                
                [alertView show];
                
            }
        }];

    }
    

}

-(BOOL)doesNeedReachability{
    return YES;
}

@end
