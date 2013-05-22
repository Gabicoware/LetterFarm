//
//  ColorGameTilePositionController.m
//  Color Farm
//
//  Created by Daniel Mueller on 5/29/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import "ColorGameTilePositionController.h"
#import "BaseFarm.h"

#import "NSString+LF.h"

#import "TileUtilities.h"
#import "ColorWordUtilities.h"

#import "TileView.h"
#import "BucketTileView.h"
#import "TileContainerView.h"
#import "DropletView.h"

NSString* PuGameTilePositionControllerDidSelectTile = @"PuGameTilePositionControllerDidSelectTile";


#define WALKING_SPEED (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 360 : 180)

@interface ColorGameTilePositionController()

@property (nonatomic) IBOutlet UILabel* feedbackLabel;

@property (nonatomic) IBOutlet UIView* view;

@property (nonatomic) IBOutlet UIView* dropletView;

@property (nonatomic) IBOutlet UIView* wordView;

@property (nonatomic) IBOutlet UIView* targetWordView;

@property (nonatomic) IBOutlet TileContainerView* tileContainerView;

@property (nonatomic, copy) NSArray* dropletImageViews;

@property (nonatomic, copy) NSMutableArray* targetWordTiles;
@property (nonatomic, copy) NSMutableArray* currentWordTiles;

@property (nonatomic) NSTimer* dragTimer;

@property (nonatomic, assign) WordEditState currentWordEditState;

@property (nonatomic, assign) WordEditState pendingWordEditState;

-(WordEditState)wordEditStateWithTile:(TileView*)tile;

@property (nonatomic) UITapGestureRecognizer* tapGestureRecognizer;

// the "tapped" sheep, only used for this purpose
@property (nonatomic) TileView* targetTileView;

// the "tapped" bucket, only used for this purpose
@property (nonatomic) TileView* activeTileView;

//selected tile for the game logic
@property (nonatomic) TileView* selectedTileView;

@end

@implementation ColorGameTilePositionController

@synthesize targetWord=_targetWord;
@synthesize activeWord=_activeWord, currentWordTiles=_currentWordTiles;
@synthesize wordView=_wordView;
@synthesize tileContainerView=_tileContainerView;
@synthesize dropletImageViews=_dropletImageViews;

@synthesize pendingWordEditState=_pendingWordEditState, currentWordEditState=_currentWordEditState;
@synthesize dragTimer=_dragTimer;
@synthesize view=_view;
@synthesize tapGestureRecognizer=_tapGestureRecognizer;
@synthesize activeTileView=_activeTileView;

-(UIView*)keyViewWithLetter:(NSString*)letter{
    UIView* view = nil;
    for(TileView* tileview in self.tileContainerView.tileViews){
        if([[tileview color] isEqualToString:letter]){
            view = tileview;
        }
    }
    return view;
}
-(UIView*)activeViewWithIndex:(int)index{
    return [self.currentWordTiles objectAtIndex:index];
}

-(BOOL)hasSelectedTileView{
    return self.activeTileView != nil || self.selectedTileView != nil;
}

-(NSString*)proposedActiveWord{
    
    NSString* result = self.activeWord;
    if (self.targetTileView != nil) {
        int index = [self.currentWordTiles indexOfObject:self.targetTileView];
        result = [ColorWordUtilities permutateWord:self.activeWord color:self.selectedTileView.color index:index];
    }
    return result;
    
}

-(void)awakeFromNib{
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    self.tapGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:self.tapGestureRecognizer];
    [self setupColors];
    
    self.feedbackLabel.alpha = 0.0;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    
    CGPoint wordViewPoint = [gestureRecognizer locationInView:self.wordView];
    
    BOOL insideWordView = [self.wordView pointInside:wordViewPoint withEvent:nil];
    
    CGPoint colorViewPoint = [gestureRecognizer locationInView:self.tileContainerView];
    
    BOOL insideColorView = [self.tileContainerView pointInside:colorViewPoint withEvent:nil];
    
    return insideColorView || insideWordView;
    
}

-(void)setupColors{
    
    for(TileView* tileview in self.tileContainerView.tileViews){
        [self addEventsToTile:tileview];
    }
    
    [self setTileViewIndices];
    
}

-(void)setTileViewIndices{
    
    NSArray* sortedTileViews = [self.tileContainerView.tileViews sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        TileView* tileView1 = OBJECT_IF_OF_CLASS(obj1, TileView);
        TileView* tileView2 = OBJECT_IF_OF_CLASS(obj2, TileView);
        
        CGPoint center1 = tileView1.defaultCenter;
        CGPoint center2 = tileView2.defaultCenter;
        
        if (center1.y < center2.y) {
            return NSOrderedAscending ;
        }else if (center1.y > center2.y) {
            return NSOrderedDescending ;
        }else{
            return NSOrderedSame;
        }
    }];
    
    for (NSInteger index = 0; index < sortedTileViews.count; index++) {
        TileView* tileView = OBJECT_IF_OF_CLASS([sortedTileViews objectAtIndex:index], TileView);
        
        [self.tileContainerView insertSubview:tileView atIndex:index];
        
    }
}

-(void)addEventsToTile:(TileView*)tileView{
    [tileView addTarget:self 
                 action:@selector(didTouchDownTile:) 
       forControlEvents:UIControlEventTouchDown];
    [tileView addTarget:self 
                 action:@selector(didTouchDragInsideTile:) 
       forControlEvents:UIControlEventTouchDragInside];
    [tileView addTarget:self 
                 action:@selector(didTouchUpInsideTile:) 
       forControlEvents:UIControlEventTouchUpInside];
}

-(void)reload{
    
    if (self.dropletImageViews == nil) {
        //we add three empty image views
        self.dropletImageViews = @[[[DropletView alloc] initWithFrame:CGRectZero],
                                   [[DropletView alloc] initWithFrame:CGRectZero],
                                   [[DropletView alloc] initWithFrame:CGRectZero]];
    }
    
    
    self.currentWordEditState = WordEditStateNone;
    
    self.currentWordTiles = [self refreshWordTray:self.wordView withWord:self.activeWord];
    
    self.targetWordTiles = [self refreshWordTray:self.targetWordView withWord:self.targetWord];
    
    for (UIView* subview in self.dropletView.subviews) {
        [subview removeFromSuperview];
    }

}

-(NSMutableArray*)refreshWordTray:(UIView*)wordTray withWord:(NSString*)word{
    
    for (UIView* subview in wordTray.subviews) {
        if ([subview isKindOfClass:[TileView class]]) {
            [subview removeFromSuperview];
        }
    }
    
    NSArray* wordColors = [word letters];
    
    NSMutableArray* tiles = [TileUtilities tilesForColors:wordColors
                                               guideView:wordTray
                                               superview:wordTray];
    
    for (TileView* tile in tiles) {
        [tile setEnabled:NO];
    }
    
    return tiles;
}

-(void)reset{
    
    TileView* keyTileView = self.selectedTileView;
    
    [keyTileView resetAnimated];
    
    self.targetTileView = nil;
    
    self.currentWordEditState = WordEditStateZero;
    
    [self animateToState:WordEditStateNone];
    
}

-(void)didCompleteWithWord:(NSString*)word finished:(void(^)(void))finish{
    [self animateToWord:word finished:finish];
}

-(void)canNotMoveToWord:(NSString*)word{
    [self reset];
    
    if ([word isEqualToString:[self activeWord]]) {
        [UIView animateWithDuration:0.2 animations:^{
            self.feedbackLabel.alpha = 0.0;
        }];
    }else{
        self.feedbackLabel.text = [self canNotMoveFeedbackStringWithWord:word];
        
        [UIView animateWithDuration:0.2 delay:0.5 options:0 animations:^{
            self.feedbackLabel.alpha = 0.0;
        } completion:NULL];
    }
    
}

-(void)didMoveToWord:(NSString*)word{
    [self animateToWord:word finished:NULL];
    
}

-(void)animateToWord:(NSString*)word finished:(void(^)(void))finish{
    
    
    [UIView animateWithDuration:0.2 animations:^{
        self.feedbackLabel.alpha = 0.0;
    }];
    

    //animate the pending color into place in the word
    //update the word
    //set the pending color to have a position offscreen
    //animate the pending color BACK to its original position
    
    TileView* keyTileView = self.selectedTileView;
    TileView* wordTileView = self.targetTileView;
    
    //this is incorrect, the other tiles need to be updated as well
    
    
    for(int index = 0; index < self.currentWordTiles.count; index++){
        TileView* tile = [self.currentWordTiles objectAtIndex:index];
        NSString* color = [word letterAtIndex:index];
        tile.color = color;
    }
    
    [keyTileView resetAnimated];
    [wordTileView resetAnimated];
    
    if (finish != NULL) {
        finish();
    }
    
    self.activeWord = word;
    [self reload];
    if (finish != NULL) {
        finish();
    }
    
}

-(void)didTouchDownTile:(id)sender{
    
    self.selectedTileView = OBJECT_IF_OF_CLASS(sender, TileView);
    
    [UIView animateWithDuration:0.2 animations:^{
        self.feedbackLabel.alpha = 1.0;
    }];
    
    self.feedbackLabel.text = [self selectedFeedbackString];

    self.activeTileView.selected = NO;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PuGameTilePositionControllerDidSelectTile object:self];
    
}

-(void)didTouchDragInsideTile:(id)sender{
        
    TileView* tile = OBJECT_IF_OF_CLASS(sender, TileView);
    
    WordEditState state = [self wordEditStateWithTile:tile];
    
    if (!WordEditStateEquals(state, [self pendingWordEditState])) {
        //if they aren't equal reset the timer
        [self setPendingWordEditState:state];
        [self resetDragTimerWithTile:tile];
    }

}

-(void)didTouchUpInsideTile:(id)sender{
        
    TileView* tile = OBJECT_IF_OF_CLASS(sender, TileView);
    
    [self cancelDragTimer];
    
    [self setPendingWordEditState:WordEditStateNone];
    
    WordEditState state = [self wordEditStateWithTile:tile];
    
    if (state.dragState == DragStateDragActiveReplace) {
        self.targetTileView = [self.currentWordTiles objectAtIndex:state.index];
    }else{
        self.targetTileView = nil;
        [tile resetAnimated];
    }
    
    [self setTileViewIndices];
        
    [[NSNotificationCenter defaultCenter] postNotificationName:ProposedWordNotification object:self];

    self.selectedTileView = nil;
}

-(NSMutableArray*)currentWordTilesWithTile:(TileView*)tile wordEditState:(WordEditState)state{
    
    NSMutableArray* tiles = [NSMutableArray arrayWithArray:self.currentWordTiles];
    
    if (state.dragState == DragStateDragActiveReplace) {
        [tiles replaceObjectAtIndex:state.index withObject:tile];
    }
    
    
    return tiles;
}

-(void)handleTapGesture:(id)recognizer{
    UITapGestureRecognizer* tapGestureRecognizer = OBJECT_IF_OF_CLASS(recognizer, UITapGestureRecognizer);
    
    if (self.activeTileView == nil) {
        CGPoint viewPoint = [tapGestureRecognizer locationInView:[self view]];
        UIView* hitView = [[self view] hitTest:viewPoint withEvent:nil];
        TileView* hitTileView = OBJECT_IF_OF_CLASS(hitView, TileView);
        if(hitTileView != nil && ![self.currentWordTiles containsObject:hitTileView]){
            self.activeTileView = hitTileView;
            self.selectedTileView = hitTileView;
            self.activeTileView.selected = YES;
            self.feedbackLabel.text = [self selectedFeedbackString];
        }
    }else{
        TileView* tappedTileView = [self tappedTileWithRecognizer:tapGestureRecognizer tiles:[self currentWordTiles]];
        if (tappedTileView != nil) {
            self.targetTileView = tappedTileView;
            [[NSNotificationCenter defaultCenter] postNotificationName:ProposedWordNotification object:self];
        }
        self.activeTileView.selected = NO;
        self.activeTileView = nil;
        self.selectedTileView = nil;
        [UIView animateWithDuration:0.2 animations:^{
            self.feedbackLabel.alpha = 0.0;
        }];
    }
    
    if([self hasSelectedTileView]){
        [[NSNotificationCenter defaultCenter] postNotificationName:PuGameTilePositionControllerDidSelectTile object:self];
    }
}

-(TileView*)tappedTileWithRecognizer:(UITapGestureRecognizer*)recognizer tiles:(NSArray*)tiles{
    
    CGPoint viewPoint = [recognizer locationInView:[self view]];
    
    TileView* tappedTileView = nil;
    
    for (TileView* tileView in tiles) {
        CGPoint tilePoint = [tileView convertPoint:viewPoint fromView:[self view]];
        if ( CGRectContainsPoint( [tileView bounds], tilePoint ) ) {
            tappedTileView = tileView;
        }
    }
    
    return tappedTileView;
    
}


-(WordEditState)wordEditStateWithTile:(TileView*)tile{
    
    WordEditState state = WordEditStateNone;
    
    CGPoint dragCenter = [[self wordView] convertPoint:[tile center] fromView:[tile superview]];
    
    NSInteger currentWordIndex = [TileUtilities indexOfClosestTileTo:dragCenter fromTiles:self.currentWordTiles];
    
    TilePointPosition position = TilePointPositionOff;
    
    if (currentWordIndex != NSNotFound) {
        TileView* currentTile = [self.currentWordTiles objectAtIndex:currentWordIndex];
        
        CGPoint centerPoint = [currentTile defaultCenter];
        
        CGRect bounds = [currentTile bounds];
        
        BOOL isOn = [TileUtilities isOnPoint:dragCenter relativeToTileCenter:centerPoint size:bounds.size];
        if (isOn) {
            position = TilePointPositionOn;
        }
    }
    
    switch (position) {
        case TilePointPositionOn:
            state.index = currentWordIndex;
            state.dragState = DragStateDragActiveReplace;
            break;
        default:
            state.index = NSNotFound;
            state.dragState = DragStateDragInactive;
            break;
    }
        
    
    return state;
}

-(void)cancelDragTimer{
    
    [self.dragTimer invalidate];
    self.dragTimer = nil;
}

-(void)resetDragTimerWithTile:(TileView*)tile{
    
    [self.dragTimer invalidate];
    
    NSTimer* dragTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(didFireDragTimer:) userInfo:tile repeats:NO];
    
    self.dragTimer = dragTimer;
    
}

-(void)didFireDragTimer:(id)sender{
    NSTimer* timer = OBJECT_IF_OF_CLASS(sender, NSTimer);
    TileView* tile = OBJECT_IF_OF_CLASS([timer userInfo], TileView);
    
    WordEditState state = [self wordEditStateWithTile:tile];
    
    if ( WordEditStateEquals(state, [self pendingWordEditState] )) {
        [self animateToState:state];
    }else{
        [self setPendingWordEditState:state];
        //reset the timer???
        [self resetDragTimerWithTile:tile];
    }
}


-(void)animateToState:(WordEditState)state{
    
    if ( WordEditStateEquals( self.currentWordEditState, state ) ) {
        //don't make any changes
        return;
    }
    
    self.currentWordEditState = state;
    
    //set up the defaults
    CGPoint tileCenterPoints[8];
    TileState tileStates[] = {TileStateNormal,TileStateNormal,TileStateNormal,TileStateNormal,TileStateNormal,TileStateNormal,TileStateNormal,TileStateNormal};
    
    int count = self.currentWordTiles.count;
    
    for (int index = 0; index < count; index++) {
        TileView* tileView = [self.currentWordTiles objectAtIndex:index];
        CGPoint tileCenter = [tileView defaultCenter];
        tileCenterPoints[index] = tileCenter;
    }
        
    switch (state.dragState) {
        case DragStateDragActiveReplace:
            tileStates[state.index] = TileStateWillReplace;
            break;
        default:
            break;
    }
    
    for (int index = 0; index < count; index++) {
        
        TileView* tile = [self.currentWordTiles objectAtIndex:index];
        CGPoint tileCenter = tileCenterPoints[index];
        TileState tileState = tileStates[index];
        
        [tile animateToCenter:tileCenter withState:tileState];
        
    }
    
    NSArray* tiles = [self currentWordTilesWithTile:self.selectedTileView wordEditState:state];
    
    NSMutableString* pString = [NSMutableString stringWithCapacity:tiles.count];
    for (TileView* tile in tiles) {
        [pString appendString:[tile color]];
    }

    if ([pString isEqualToString:self.activeWord]) {
        self.feedbackLabel.text = [self selectedFeedbackString];
    }else{
        self.feedbackLabel.text = [self spellingFeedbackStringWithWord:pString];
    }
    
    for (UIView* subview in self.dropletView.subviews) {
        [subview removeFromSuperview];
    }
    
    if (state.dragState == DragStateDragActiveReplace) {
        
        int initialIndex = MAX(state.index - 1,0);
        int max = MIN(state.index +1, self.activeWord.length - 1);
        
        NSString* result = self.activeWord;
        if (self.selectedTileView != nil) {
            result = [ColorWordUtilities permutateWord:self.activeWord color:self.selectedTileView.color index:state.index];
        }
        
        for (int index = initialIndex; index <= max; index++) {
            
            NSString* color = [result letterAtIndex:index];
            
            
            int dropIndex = index - initialIndex;
            
            DropletView* dropletView = OBJECT_AT_INDEX_IF_OF_CLASS(self.dropletImageViews, dropIndex, DropletView);
            dropletView.color = color;
            
            [dropletView sizeToFit];
            
            CGRect dropletFrame = dropletView.frame;
            
            TileView* tileView = OBJECT_AT_INDEX_IF_OF_CLASS(self.currentWordTiles, index, TileView);
            
            CGPoint tileViewCenter = [[self dropletView] convertPoint:tileView.center fromView:tileView.superview];
            
            CGRect tileViewBounds = tileView.bounds;
            
            dropletFrame.origin.x = round(tileViewCenter.x - dropletFrame.size.width/2.0);
            dropletFrame.origin.y = round(tileViewCenter.y - tileViewBounds.size.height/2.0 - dropletFrame.size.height);
            
            dropletView.frame = dropletFrame;
            
            [self.dropletView addSubview:dropletView];
            
        }
    }
    
}

-(NSString*)canNotMoveFeedbackStringWithWord:(NSString*)word{
    return @"";
}

-(NSString*)selectedFeedbackString{
    return [NSString stringWithFormat:@"Selected \"%@\"",[self.selectedTileView.color uppercaseString]];
}

-(NSString*)spellingFeedbackStringWithWord:(NSString*)word{
    return @"";
}

@end
