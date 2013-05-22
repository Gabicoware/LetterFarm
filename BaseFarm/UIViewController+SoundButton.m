//
//  UIViewController+SoundButton.m
//  LetterFarm
//
//  Created by Daniel Mueller on 1/28/13.
//
//

#import "UIViewController+SoundButton.h"
#import "SoundEffectManager.h"


@implementation UIViewController (SoundButton)

-(void)updateRightBarButton{
    
    if (self.navigationItem.rightBarButtonItem == nil) {
        UIBarButtonItem* soundBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[self currentSoundImage] style:UIBarButtonItemStyleBordered target:self action:@selector(_didTapSoundButton:)];
        self.navigationItem.rightBarButtonItem = soundBarButtonItem;
    }
    
}

-(void)_didTapSoundButton:(id)sender{
    
    BOOL isMute = [[SoundEffectManager sharedSoundEffectManager] isMute];
    
    [[SoundEffectManager sharedSoundEffectManager] setIsMute:!isMute];
    
    [self.navigationItem.rightBarButtonItem setImage:[self currentSoundImage]];
    
}

-(UIImage*)currentSoundImage{
    if ([[SoundEffectManager sharedSoundEffectManager] isMute]) {
        return [UIImage imageNamed:@"sound_off_icon"];
    }else{
        return [UIImage imageNamed:@"sound_icon"];
    }

}

@end

