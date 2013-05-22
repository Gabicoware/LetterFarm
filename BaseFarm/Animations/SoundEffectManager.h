//
//  SoundEffectManager.h
//  LetterFarm
//
//  Created by Daniel Mueller on 1/26/13.
//
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface SoundEffectManager : NSObject<AVAudioSessionDelegate>

+(id)sharedSoundEffectManager;

-(void)didStartup;

-(void)playFinalTone;

-(void)playToneForMove:(int)move;

//the name of the groupd of sound effects to use (ie, sheep)
@property (nonatomic) NSString* groupName;

@property (nonatomic) BOOL isMute;

-(void)playIdleGroupSound;

-(void)playStartDragGroupSound;

-(void)playIncorrectGroupSound;

//will randomly play idle sounds
-(void)startIdle;
//will stop randomly playing idle sounds
-(void)endIdle;

@end
