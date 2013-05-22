//
//  SelectGameViewController.m
//  LetterFarm
//
//  Created by Daniel Mueller on 2/2/13.
//
//

#import "SelectLevelViewController.h"
#import "TileUtilities.h"
#import "BadgeTileControl.h"
#import "PuzzleGame.h"
#import "Puzzle.h"
#import "LevelManager.h"
#import "InAppPurchases.h"
#import "UIBlockAlertView.h"
#import "LevelPackGenerator.h"
#import "UIValues.h"

@interface SelectLevelViewController ()

@property (nonatomic) NSArray* levels;
@property (nonatomic) NSArray* gameButtons;

@property (nonatomic) IBOutlet UIView* levelView;
@property (nonatomic) IBOutlet UIView* editView;

@property (nonatomic) IBOutlet UITextField* titleTextField;
@property (nonatomic) IBOutlet UISegmentedControl* themeSegmentedControl;

@property (nonatomic) BOOL isEditing;

-(IBAction)didTapDeleteButton:(id)sender;

@end

@implementation SelectLevelViewController

@synthesize packName=_packName;

#define TILE_VIEW_TAG_OFFSET 1001
#define TILE_VIEW_WIDTH 44.0
#define TILE_VIEW_HEIGHT 44.0
#define PACK_HORIZONTAL_PADDING_FRACTION 0.05
#define PACK_VERTICAL_PADDING_FRACTION 0.05

-(UINavigationItem*)navigationItem{
    UINavigationItem* navigationItem = [super navigationItem];
    
    if (![[LevelManager sharedLevelManager] isIncludedPackName:self.packName]) {
        
        if (self.isEditing) {
            
            UIBarButtonItem* doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(didTapDoneButton:)];
            
            [navigationItem setRightBarButtonItem:doneItem animated:NO];
        
            UIBarButtonItem* cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(didTapCancelButton:)];
            
            [navigationItem setLeftBarButtonItem:cancelItem animated:NO];
            
            [navigationItem setTitle:@"Editing"];
            
        }else{
            
            [navigationItem setLeftBarButtonItem:nil animated:NO];
            [navigationItem setHidesBackButton:NO animated:YES];
            
            UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(didTapEditButton:)];
            
            [navigationItem setRightBarButtonItem:item animated:NO];
            
            [navigationItem setTitle:self.title];
        }
        
    }
    
    return navigationItem;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return NO;
}


-(IBAction)didTapDeleteButton:(id)sender{
    //confirm delete
    
    UIBlockAlertView* alertView = [[UIBlockAlertView alloc] initWithTitle:@"Confirm" message:@"Are you sure you want to delete this pack?" completion:^(BOOL cancelled, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            
            [[LevelManager sharedLevelManager] deletePackName:self.packName];
            
            [self.navigationController popViewControllerAnimated:YES];
            
            //send a delete message
        }
    } cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
    
    [alertView show];
    
}

-(void)didTapEditButton:(id)sender{
    //some garbage
    self.isEditing = YES;
    
    [self navigationItem];
    
}

-(void)didTapDoneButton:(id)sender{
    
    NSString* theme = WorldThemeSummer;
    
    if ( self.themeSegmentedControl.selectedSegmentIndex == 1 ) {
        theme = WorldThemeAutumn;
    }else if ( self.themeSegmentedControl.selectedSegmentIndex == 2 ) {
        theme = WorldThemeWinter;
    }else if ( self.themeSegmentedControl.selectedSegmentIndex == 3 ) {
        theme = WorldThemeSpring;
    }

    
    [[LevelManager sharedLevelManager] updateTitle:self.titleTextField.text theme:theme packName:self.packName];
    
    [self reload];
    
    [self didTapCancelButton:sender];
}

-(void)didTapCancelButton:(id)sender{
    //some garbage
    self.isEditing = NO;
    
    [self navigationItem];
    
    if(self.titleTextField.isFirstResponder){
        [self.titleTextField resignFirstResponder];
    }

}

-(void)setIsEditing:(BOOL)isEditing{
    _isEditing = isEditing;
    
    self.levelView.hidden = isEditing;
    self.editView.hidden = !isEditing;
    
    
}



-(void)setPackName:(NSString *)packName{
    self.levels = nil;
    _packName = packName;
    
    
    [self reload];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [self reload];
}

-(void)didTapTileControl:(id)sender{
    int tag = [OBJECT_IF_OF_CLASS(sender, TileControl) tag];
    
    int index = tag - TILE_VIEW_TAG_OFFSET;
    
    PuzzleGame* puzzleGame = [[LevelManager sharedLevelManager] puzzleGameForPack:self.packName index:index];
    
    NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:puzzleGame, SelectGamePuzzleGameKey, self.packName, SelectGamePackNameKey, [NSNumber numberWithInt:index], SelectGameLevelIndexKey, nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SelectGameNotification object:self userInfo:userInfo];
    
}

-(BadgeTileControl*)buttonWithIndex:(int)index{
    BadgeTileControl* gameButton = [[BadgeTileControl alloc] initWithFrame:CGRectMake(0, 0, TILE_VIEW_WIDTH, TILE_VIEW_HEIGHT)];
    gameButton.isSmallFormat = YES;
    gameButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin;
    
    gameButton.font = [UIValues letterFontOfSize:15.0];
    
    [gameButton addTarget:self
                   action:@selector(didTapTileControl:)
         forControlEvents:UIControlEventTouchUpInside];
    
    gameButton.letter = [NSString stringWithFormat:@"%d", index + 1];
    
    [gameButton setTag:index + TILE_VIEW_TAG_OFFSET];
    
    return gameButton;
}

-(void)reload{
    
    NSString* theme = [[LevelManager sharedLevelManager] packThemeWithName:self.packName];
    
    NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:theme, UpdateWorldThemeNameKey, nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UpdateWorldThemeNotification object:self userInfo:userInfo];
    
    self.titleTextField.text = [[LevelManager sharedLevelManager] packTitleWithName:self.packName];
    
    if ([theme isEqualToString:WorldThemeSummer]) {
        self.themeSegmentedControl.selectedSegmentIndex = 0;
    }else if ([theme isEqualToString:WorldThemeAutumn]) {
        self.themeSegmentedControl.selectedSegmentIndex = 1;
    }else if ([theme isEqualToString:WorldThemeWinter]) {
        self.themeSegmentedControl.selectedSegmentIndex = 2;
    }else if ([theme isEqualToString:WorldThemeSpring]) {
        self.themeSegmentedControl.selectedSegmentIndex = 3;
    }
    
    if (self.levels == nil) {
        
        self.levels = [[LevelManager sharedLevelManager] levelsWithPackName:self.packName];
        
        for (UIView* view in self.gameButtons) {
            [view removeFromSuperview];
        }
        
        NSMutableArray* views = [NSMutableArray arrayWithCapacity:self.levels.count];
        
        for (int index = 0; index < self.levels.count; index++) {
            BadgeTileControl* gameButton = OBJECT_AT_INDEX_IF_OF_CLASS(self.gameButtons, index, BadgeTileControl);
            
            if(gameButton == nil){
                gameButton = [self buttonWithIndex:index];
            }
            
            [views addObject:gameButton];
        }
        
        self.gameButtons = [NSArray arrayWithArray:views];
        
    }
    
    CGRect selfViewBounds = self.view.bounds;
    
    CGFloat horizontalPadding = PACK_HORIZONTAL_PADDING_FRACTION*selfViewBounds.size.width;
    CGFloat verticalPadding = PACK_VERTICAL_PADDING_FRACTION*selfViewBounds.size.height;
    
    CGFloat centerXOffset = floorf((selfViewBounds.size.width - 2.0*horizontalPadding )/5.0);
    CGFloat centerYOffset = floorf((selfViewBounds.size.height - 2.0*verticalPadding )/6.0);
    
    CGFloat leftMargin = floorf(centerXOffset/2.0 - TILE_VIEW_WIDTH/2.0 + horizontalPadding);
    CGFloat topMargin = floorf(centerYOffset/2.0 - TILE_VIEW_HEIGHT/2.0 + verticalPadding);
    
    for (int index = 0; index < self.levels.count; index++) {
        BadgeTileControl* tileControl = OBJECT_IF_OF_CLASS([self.gameButtons objectAtIndex:index],TileControl);
        
        if(tileControl.superview != self.view){
            [self.levelView addSubview:tileControl];
        }
        BOOL isComplete = [[LevelManager sharedLevelManager] hasCompletedLevel:index pack:self.packName];
        
        tileControl.badgeType = isComplete ? BadgeTypeComplete : BadgeTypeNone;
        
        CGRect tileFrame = tileControl.frame;
        tileFrame.origin.x = leftMargin + centerXOffset*((CGFloat)(index%5));
        tileFrame.origin.y = topMargin + centerYOffset*((CGFloat)(index/5));
        tileControl.frame = tileFrame;
        
    }
    
}

@end
