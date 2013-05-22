//
//  CreatePackViewController.m
//  LetterFarm
//
//  Created by Daniel Mueller on 2/11/13.
//
//

#import "CreatePackViewController.h"
#import "LevelPackGenerator.h"
#import "LevelManager.h"
#import "LetterFarmSinglePlayer.h"

#define Difficult_Value_Key @"CreatePackViewController.DefaultMultipleyDifficultyValue"

@interface CreatePackViewController ()

-(IBAction)didTapCreateButton:(id)sender;

@property (nonatomic) IBOutlet UITextField* textField;

@property (nonatomic) IBOutlet UISegmentedControl* segmentedControl;

@property (nonatomic) IBOutlet UISlider* difficultySlider;

@property (nonatomic) IBOutlet UILabel* difficultyLabel;

@property (nonatomic) LevelPackGenerator* levelPackGenerator;

@property (nonatomic) IBOutlet UIView* creatingView;

@property (nonatomic) IBOutlet UILabel* creatingLabel;

@property (nonatomic) IBOutlet UIActivityIndicatorView* activityIndicatorView;

@property (nonatomic) BOOL isCreating;

@property (nonatomic) NSTimer* creatingTimer;

@end

@implementation CreatePackViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    
    self.textField.text = [NSString stringWithFormat:@"Pack #%d", ([[LevelManager sharedLevelManager] packCount] + 1)];
    
    [self.difficultySlider setMinimumValue:DifficultyEasy];
    [self.difficultySlider setMaximumValue:DifficultyBrutal];
    
    self.difficultySlider.value = [self averageDifficulty];
    
    [self.difficultyLabel setText:[self textWithSliderValue:[self.difficultySlider value]]];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return NO;
}

-(IBAction)didTouchUpInsideSlider:(id)sender{
    
    
    float f_value = roundf([self.difficultySlider value]);
    
    [[NSUserDefaults standardUserDefaults] setFloat:f_value forKey:Difficult_Value_Key];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.difficultySlider setValue:f_value];
    
    [self.difficultyLabel setText:[self textWithSliderValue:[self.difficultySlider value]]];
}

-(int)averageDifficulty{
    float value = [[NSUserDefaults standardUserDefaults] floatForKey:Difficult_Value_Key];
    
    if (value < DifficultyEasy) {
        value = DifficultyEasy;
        [[NSUserDefaults standardUserDefaults] setFloat:value forKey:Difficult_Value_Key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return value;
}

-(NSString*)textWithSliderValue:(float)value{
    
    int i_value = MIN(MAX(((int)value),DifficultyEasy),DifficultyBrutal);
    
    NSString* difficultyName = @"";
    
    switch (i_value) {
        case 3:
            difficultyName = @"Easy";
            break;
        case 4:
            difficultyName = @"Medium";
            break;
        case 5:
            difficultyName = @"Hard";
            break;
        case 6:
            difficultyName = @"Very Hard";
            break;
        case 7:
            difficultyName = @"Brutal";
            break;
    }
    
    return [NSString stringWithFormat: @"Difficulty - %@ (%d)", difficultyName, i_value];
}



-(IBAction)didTapCreateButton:(id)sender{
    Difficulty value = (Difficulty)self.difficultySlider.value;
    
    self.levelPackGenerator = [[LevelPackGenerator alloc] init];
    self.levelPackGenerator.target = self;
    self.levelPackGenerator.action = @selector(didCompletePackGeneration:);
    [self.levelPackGenerator generateInBackground];
    self.levelPackGenerator.difficulty = value;
    
    self.creatingLabel.text= [self creatingLabelText];
    
    self.isCreating = YES;
    
    self.creatingTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(didFireTimer:) userInfo:nil repeats:YES];
    
}

-(void)didFireTimer:(NSTimer*)timer{
    
    self.creatingLabel.text= [self creatingLabelText];
    
}

-(NSString*)creatingLabelText{
    return [NSString stringWithFormat:@"Created %d/30",self.levelPackGenerator.generatedCount];
}

-(void)didCompletePackGeneration:(id)sender{
    
    [self.creatingTimer invalidate];
    self.creatingTimer = nil;
    
    NSArray* levels =  self.levelPackGenerator.result;
    
    NSString* title = self.textField.text;// 
    
    NSString* theme = WorldThemeSummer;
    
    if ( self.segmentedControl.selectedSegmentIndex == 1 ) {
        theme = WorldThemeAutumn;
    }else if ( self.segmentedControl.selectedSegmentIndex == 2 ) {
        theme = WorldThemeWinter;
    }else if ( self.segmentedControl.selectedSegmentIndex == 3 ) {
        theme = WorldThemeSpring;
    }
    
     NSString* packName = [[LevelManager sharedLevelManager] saveLevelPack:levels title:title theme:theme];
    
    self.levelPackGenerator = nil;
    
    self.isCreating = NO;
        
    NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:packName,SelectPackNameKey, nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SelectPackNotification
                                                        object:self
                                                      userInfo:userInfo];

    
}

-(void)setIsCreating:(BOOL)isCreating{
    BOOL didChange = _isCreating != isCreating;
    
    _isCreating=isCreating;
    if (didChange) {
        self.creatingView.hidden = NO;
        if (isCreating) {
            
            [self.navigationItem setHidesBackButton:YES animated:YES];
            
            self.creatingView.alpha = 0.0;
            [UIView animateWithDuration:0.25 animations:^{
                self.creatingView.alpha = 1.0;
            }];
            [self.activityIndicatorView startAnimating];
        }else{
            [self.navigationItem setHidesBackButton:NO animated:YES];
            [UIView animateWithDuration:0.25 animations:^{
                self.creatingView.alpha = 0.0;
            } completion:^(BOOL finished) {
                self.creatingView.hidden = YES;
            }];
            [self.activityIndicatorView stopAnimating];
        }
    }
}



@end
