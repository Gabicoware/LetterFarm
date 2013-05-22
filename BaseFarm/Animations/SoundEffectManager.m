//
//  SoundEffectManager.m
//  LetterFarm
//
//  Created by Daniel Mueller on 1/26/13.
//
//

#import "SoundEffectManager.h"

#define SoundEffectManagerIsMuteKey @"SoundEffectManagerIsMuteKey"

@implementation SoundEffectManager{
    AVAudioPlayer* backgroundAudioPlayer;
    AVAudioPlayer* toneAudioPlayer;
    AVAudioPlayer* groupSoundAudioPlayer;
    
    NSTimer* idleTimer;
    
}

+(id)sharedSoundEffectManager{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
    });
    return _sharedObject;
}

-(id)init{
    if((self = [super init])){
        _isMute = [[NSUserDefaults standardUserDefaults] boolForKey:SoundEffectManagerIsMuteKey];
        
        NSError *sessionError = nil;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:&sessionError];
        [[AVAudioSession sharedInstance] setActive:YES error:&sessionError];
        [[AVAudioSession sharedInstance] setDelegate:self];
    }
    return self;
}

-(void)didStartup{
    if (self.isMute) { return; }
    backgroundAudioPlayer = [self audioPlayerWithName:@"background"];
    backgroundAudioPlayer.numberOfLoops = -1;
    [backgroundAudioPlayer play];
    
}

-(void)setIsMute:(BOOL)isMute{
    _isMute = isMute;
    [[NSUserDefaults standardUserDefaults] setBool:_isMute forKey:SoundEffectManagerIsMuteKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if(isMute){
        [backgroundAudioPlayer stop];
        backgroundAudioPlayer = nil;
        [groupSoundAudioPlayer stop];
        groupSoundAudioPlayer = nil;
        [toneAudioPlayer stop];
        toneAudioPlayer = nil;
    }else{
        [self didStartup];
    }
}

-(void)playFinalTone{
    if (self.isMute) { return; }
    toneAudioPlayer = [self audioPlayerWithName:@"tone_final"];

    [toneAudioPlayer play];
    
}
-(void)playToneForMove:(int)move{
    if (self.isMute) { return; }
    NSString* resourceName = [NSString stringWithFormat:@"tone%d",move];
    
    toneAudioPlayer = [self audioPlayerWithName:resourceName];
    
    [toneAudioPlayer play];
    
}

-(AVAudioPlayer*)audioPlayerWithName:(NSString*)name{
    NSString *path = [[NSBundle mainBundle]pathForResource:name ofType:@"m4a"];
    AVAudioPlayer* audioPLayer = nil;
    if (path != nil) {
        audioPLayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:NULL];
    }
    return audioPLayer;
    
}

-(void)playIdleGroupSound{
    if (self.isMute) { return; }
    int index = (random()%5) + 1;
    NSString* name = [NSString stringWithFormat:@"baa%d", index];
    groupSoundAudioPlayer = [self audioPlayerWithName:name];
    [groupSoundAudioPlayer play];
}

-(void)playStartDragGroupSound{
    if (self.isMute) { return; }
    groupSoundAudioPlayer = [self audioPlayerWithName:@"baa_question_2"];
    [groupSoundAudioPlayer play];
}

-(void)playIncorrectGroupSound{
    if (self.isMute) { return; }
    groupSoundAudioPlayer = [self audioPlayerWithName:@"baa_question_1"];
    [groupSoundAudioPlayer play];
}

- (void)beginInterruption{
}

- (void)endInterruptionWithFlags:(NSUInteger)flags{
}

- (void)endInterruption{
}

- (void)inputIsAvailableChanged:(BOOL)isInputAvailable{
}

//will randomly play idle sounds
-(void)startIdle{
    [idleTimer invalidate];
    idleTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(didFireIdleTimer:) userInfo:nil repeats:YES];
}

-(void)didFireIdleTimer:(id)timer{
    if (!groupSoundAudioPlayer.isPlaying) {
        if(random()%60 == 0){
            [self playIdleGroupSound];
        }
    }
}

//will stop randomly playing idle sounds
-(void)endIdle{
    [idleTimer invalidate];
    idleTimer = nil;
}

@end
