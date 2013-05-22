//
//  EmailMatchEngine.m
//  LetterFarm
//
//  Created by Daniel Mueller on 12/23/12.
//
//

#import "EmailMatchEngine.h"
#import "MatchInfo.h"
#import "PuzzleGame.h"
#import "MatchInfo+Puzzle.h"
#import "EmailMatch.h"
#import "EmailSendMatchController.h"
#import "NSString+LF.h"
#import "LFURLCoder.h"
#import "UIBlockAlertView.h"
#import "LocalConfiguration.h"

#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>


#define EmailMatchDictionaryFileName @"email_matches.lf"

@interface EmailMatchEngine()

@property (nonatomic) EmailSendMatchController* emailSendMatchController;
@property (nonatomic) id completion;

@end

@implementation EmailMatchEngine

@synthesize allMatches=_allMatches;
@synthesize emailSendMatchController=_emailSendMatchController;

+(id)sharedEmailMatchEngine{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
    });
    return _sharedObject;
}

-(BOOL)handleOpenURL:(NSURL*)url{
    EmailMatch* emailMatch = OBJECT_IF_OF_CLASS([LFURLCoder decodeURL:url], EmailMatch);
    
    if (emailMatch != nil) {
        [self loadMatchInfoWithSourceData:emailMatch completionHandler:^(MatchInfo *matchInfo) {
            [[NSNotificationCenter defaultCenter] postNotificationName:MatchEngineSelectMatchNotification object:matchInfo];
        }];
    }
    return emailMatch != nil;
}


-(BOOL)isAvailable{
    return [MFMailComposeViewController canSendMail];
}

-(NSString*)emailMatchFilePath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    return [documentsDirectory stringByAppendingPathComponent:EmailMatchDictionaryFileName];
}

-(void)setPlayerID:(NSString*)playerID{
    [[LocalConfiguration sharedLocalConfiguration] setPlayerEmail:playerID];
}

-(NSString*)playerID{
    return [[LocalConfiguration sharedLocalConfiguration] playerEmail];
}

-(void)setCompletionBlock:(void (^)(void))completion{
    self.completion = [completion copy];
}

-(void)loadMatches{
    
    
    self.allMatches = [NSMutableDictionary dictionary];
    
    NSString* path = [self emailMatchFilePath];
    
    NSData* archiveData = [NSData dataWithContentsOfFile:path];
    
    NSArray* matches = nil;
    if (archiveData != nil) {
        @try {
            matches = [NSKeyedUnarchiver unarchiveObjectWithData:archiveData];
        }
        @catch (NSException *exception) {}
        @finally {}
    }
        
    BOOL hasOneMatchInProgress = NO;
    
    if (matches != nil) {
        
        
        for (EmailMatch* emailMatch in matches) {
            
            MatchInfo* matchInfo = [self.allMatches objectForKey:emailMatch.matchID];
            
            if (matchInfo == nil) {
                matchInfo = [[MatchInfo alloc] init];
                
                [self.allMatches setObject:matchInfo forKey:[emailMatch matchID]];
            }
            
            [self updateMatchInfo:matchInfo withEmailMatch:emailMatch];
            
            if(matchInfo.status == MatchStatusTheirTurn || matchInfo.status == MatchStatusYourTurn){
                hasOneMatchInProgress = YES;
            }
            
        }
        
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:EmailMatchesDidLoadNotification object:self];
    
}

-(BOOL)completeMatch:(MatchInfo*)matchInfo{
    
    EmailMatch* emailMatch = OBJECT_IF_OF_CLASS( matchInfo.sourceData, EmailMatch);
    
    emailMatch.matchStatus = matchInfo.status;
    emailMatch.games = matchInfo.games;
    
    [self sendEmailForMatch:matchInfo];
    
    return YES;
}

-(BOOL)endTurnInMatch:(MatchInfo*)matchInfo{
    
    EmailMatch* emailMatch = OBJECT_IF_OF_CLASS( matchInfo.sourceData, EmailMatch);
        
    emailMatch.matchStatus = MatchStatusTheirTurn;
    emailMatch.games = matchInfo.games;
    matchInfo.status = MatchStatusTheirTurn;
    
    [self sendEmailForMatch:matchInfo];
    
    return YES;
}

-(void)sendEmailForMatch:(MatchInfo*)matchInfo{
    
    EmailSendMatchController* sendMatchController = [[EmailSendMatchController alloc] init];
    
    [sendMatchController sendEmailForMatch:matchInfo withCompletion:^(BOOL didComplete) {
        if (![[self.allMatches allValues] containsObject:matchInfo]) {
            [[self allMatches] setObject:matchInfo forKey:matchInfo.matchID];
        }
        
        [self saveMatches];
        
        if (self.completion != NULL) {
            void (^completionBlock)(void)  = self.completion;
            completionBlock();
        }
        self.completion = NULL;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:EmailMatchesDidLoadNotification object:self];
        self.emailSendMatchController = nil;
    }];
    
    self.emailSendMatchController = sendMatchController;

}

-(void)quitMatch:(MatchInfo*)matchInfo{
    
    EmailMatch* emailMatch = OBJECT_IF_OF_CLASS(matchInfo.sourceData, EmailMatch);
    matchInfo.status = MatchStatusYouQuit;
    emailMatch.matchStatus = MatchStatusYouQuit;
    [[self allMatches] setObject:matchInfo forKey:emailMatch.matchID];
    [self saveMatches];
    [[NSNotificationCenter defaultCenter] postNotificationName:EmailMatchesDidLoadNotification object:self];
}

-(void)deleteMatch:(MatchInfo*)match{
    
    EmailMatch* emailMatch = OBJECT_IF_OF_CLASS(match.sourceData, EmailMatch);
    
    [[self allMatches] removeObjectForKey:emailMatch.matchID];
    
    [self saveMatches];
    [[NSNotificationCenter defaultCenter] postNotificationName:EmailMatchesDidLoadNotification object:self];
}

-(BOOL)canPlayWithMatchInfo:(MatchInfo*)matchInfo{
    return matchInfo.status == MatchStatusYourTurn ;
}

-(void)saveMatches{
    
    NSMutableArray* matches = [NSMutableArray array];
    for (MatchInfo* info in self.allMatches.allValues) {
        EmailMatch* emailMatch = OBJECT_IF_OF_CLASS(info.sourceData, EmailMatch);
        [matches addObject:emailMatch];
    }
    
    NSArray* result = [NSArray arrayWithArray:matches];
    
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:result];
    
    [data writeToFile:[self emailMatchFilePath] atomically:YES];
    
}

-(void)loadMatchInfoWithSourceData:(id)sourceData completionHandler:( void (^) (MatchInfo* matchInfo))completionHandler{
    EmailMatch* emailMatch = OBJECT_IF_OF_CLASS(sourceData, EmailMatch);
    
    if ([emailMatch.sourceEmail isEqualToString:self.playerID]) {
        emailMatch.isSource = YES;
    }
    
    if (self.playerID == nil){
        
        if(emailMatch.games.count == 1) {
            [self setPlayerID:emailMatch.targetEmail];
        }else if(emailMatch.games.count > 1){
            UIBlockAlertView* alertView = [[UIBlockAlertView alloc] initWithTitle:nil message:@"Please select your email" completion:^(BOOL cancelled, NSInteger buttonIndex) {
                if (buttonIndex == 1) {
                    self.playerID = emailMatch.targetEmail;
                    emailMatch.isSource = NO;
                }else if(buttonIndex == 2){
                    self.playerID = emailMatch.sourceEmail;
                    emailMatch.isSource = YES;
                }
                if (self.playerID != nil) {
                    [self loadMatchInfoWithSourceData:sourceData
                                    completionHandler:completionHandler];
                }
            } cancelButtonTitle:@"Cancel" otherButtonTitles:emailMatch.targetEmail,emailMatch.sourceEmail, nil];
            [alertView show];
            return;
        }
    }
    
    if (emailMatch.matchID == nil) {
        //create match id
        NSString* seed = [NSString stringWithFormat:@"%@-%@-%@",emailMatch.sourceEmail, emailMatch.targetEmail, emailMatch.creationDate];
        emailMatch.matchID = [seed md5HexDigest];
        emailMatch.timeSinceEpoch = (long)[emailMatch.creationDate timeIntervalSince1970];
    }
    
    MatchInfo* matchInfo = [self.allMatches objectForKey:emailMatch.matchID];
    
    BOOL isValid = NO;
    
    if (matchInfo == nil) {
        matchInfo = [[MatchInfo alloc] init];
        
        [self.allMatches setObject:matchInfo forKey:[emailMatch matchID]];
        isValid = YES;
        
    }else if ( matchInfo.games.count < emailMatch.games.count){
        isValid = YES;
    }
    
    if (isValid) {
        [self updateMatchInfo:matchInfo withEmailMatch:emailMatch];
    }
    
    completionHandler(matchInfo);
    
}

-(void)updateMatchInfo:(MatchInfo*)matchInfo withEmailMatch:(EmailMatch*)emailMatch{
    
    matchInfo.opponentType = OpponentTypeEmail;
    matchInfo.sourceData = emailMatch;
    matchInfo.matchID = [NSString stringWithFormat:@"%d%@",OpponentTypeEmail,emailMatch.matchID];
    
    matchInfo.createdDate = emailMatch.creationDate;
    matchInfo.games = emailMatch.games;
    
    matchInfo.opponentID = emailMatch.isSource ? emailMatch.targetEmail : emailMatch.sourceEmail;
    NSRange atRange = [matchInfo.opponentID rangeOfString:@"@"];
    matchInfo.opponentName = [matchInfo.opponentID substringToIndex:atRange.location];
    
    matchInfo.tileViewLetter = [matchInfo.opponentID substringToIndex:1];
    
    matchInfo.status = emailMatch.matchStatus;
}

@end
