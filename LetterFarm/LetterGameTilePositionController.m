//
//  LetterGameTilePositionController.m
//  Letter Farm
//
//  Created by Daniel Mueller on 5/29/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import "LetterGameTilePositionController.h"
#import "BaseFarm.h"
#import "NSString+LF.h"
#import "TileView.h"
#import "TileUtilities.h"
#import "TileContainerView.h"

NSString* PuGameTilePositionControllerDidSelectTile = @"PuGameTilePositionControllerDidSelectTile";


#define WALKING_SPEED (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 360 : 180)

@interface LetterGameTilePositionController()

@property (nonatomic) IBOutlet UILabel* feedbackLabel;

@property (nonatomic) IBOutlet UIView* view;

@property (nonatomic) IBOutlet UIView* wordView;

@property (nonatomic) IBOutlet TileContainerView* letterView;

@property (nonatomic, copy) NSMutableArray* currentWordTiles;
@property (nonatomic, copy) NSMutableArray* temporaryWordTiles;

@property (nonatomic) NSTimer* dragTimer;

@property (nonatomic, assign) WordEditState currentWordEditState;

@property (nonatomic, assign) WordEditState pendingWordEditState;

-(WordEditState)wordEditStateWithTile:(TileView*)tile;

@property (nonatomic) UITapGestureRecognizer* tapGestureRecognizer;
@property (nonatomic) TileView* activeTileView;

@property (nonatomic) TileView* selectedTileView;


//only used for animations
@property (nonatomic) TileView* animationTileView;

@end

@implementation LetterGameTilePositionController

@synthesize targetWord=_targetWord;
@synthesize activeWord=_activeWord, currentWordTiles=_currentWordTiles, temporaryWordTiles=_temporaryWordTiles;
@synthesize wordView=_wordView;
@synthesize letterView=_letterView;

@synthesize pendingWordEditState=_pendingWordEditState, currentWordEditState=_currentWordEditState;
@synthesize dragTimer=_dragTimer;
@synthesize view=_view;
@synthesize tapGestureRecognizer=_tapGestureRecognizer;
@synthesize activeTileView=_activeTileView;

-(UIView*)keyViewWithLetter:(NSString*)letter{
    UIView* view = nil;
    for(TileView* tileview in self.letterView.tileViews){
        if([[tileview letter] isEqualToString:letter]){
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
    NSMutableString* pString = [NSMutableString stringWithCapacity:self.temporaryWordTiles.count];
    for (TileView* tile in self.temporaryWordTiles) {
        [pString appendString:[tile letter]];
    }
    return [NSString stringWithString:pString];
}

-(void)awakeFromNib{
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    self.tapGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:self.tapGestureRecognizer];
    [self setupLetters];
    
    self.feedbackLabel.alpha = 0.0;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    
    CGPoint wordViewPoint = [gestureRecognizer locationInView:self.wordView];
    
    BOOL insideWordView = [self.wordView pointInside:wordViewPoint withEvent:nil];
    
    CGPoint letterViewPoint = [gestureRecognizer locationInView:self.letterView];
    
    BOOL insideLetterView = [self.letterView pointInside:letterViewPoint withEvent:nil];
    
    return insideLetterView || insideWordView;
    
}

-(void)setupLetters{
    
    for(TileView* tileview in self.letterView.tileViews){
        [self addEventsToTile:tileview];
    }
    
    [self setTileViewIndices];
    
    if (self.animationTileView == nil) {
        self.animationTileView = [TileUtilities newTileView];
    }

}

-(void)setTileViewIndices{
    
    NSArray* sortedTileViews = [self.letterView.tileViews sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
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
        
        [self.letterView insertSubview:tileView atIndex:index];
        
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
    
    self.currentWordEditState = WordEditStateNone;
    
    for (UIView* subview in self.wordView.subviews) {
        if ([subview isKindOfClass:[TileView class]]) {
            [subview removeFromSuperview];
        }
    }
    
    NSArray* wordLetters = [[self activeWord] letters];
    
    self.currentWordTiles = [TileUtilities tilesForLetters:wordLetters 
                                            guideView:self.wordView 
                                            superview:self.wordView];
    
    self.temporaryWordTiles = self.currentWordTiles;
    
    for (TileView* tile in self.currentWordTiles) {
        [tile setEnabled:NO];
    }
    
    
    
}

-(void)reset{
    
    
    for (int index = 0; index < self.temporaryWordTiles.count; index++) {
        TileView* tempTileView = [self.temporaryWordTiles objectAtIndex:index];
        TileView* currTileView = [self.currentWordTiles objectAtIndex:index];
        
        if (![currTileView isEqual:tempTileView]) {
            
            [tempTileView animateToCenter:tempTileView.defaultCenter withState:TileStateNormal];
            [currTileView animateToCenter:currTileView.defaultCenter withState:TileStateNormal];
        }
        
    }
    
    self.temporaryWordTiles = self.currentWordTiles;
    
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
    

    //animate the pending letter into place in the word
    //update the word
    //set the pending letter to have a position offscreen
    //animate the pending letter BACK to its original position
    
    TileView* keyTileView = nil;
    TileView* wordTileView = nil;
    
    for (int index = 0; index < self.temporaryWordTiles.count; index++) {
        TileView* tempTileView = [self.temporaryWordTiles objectAtIndex:index];
        TileView* currTileView = [self.currentWordTiles objectAtIndex:index];
        
        if (![currTileView isEqual:tempTileView]) {
            keyTileView = tempTileView;
            wordTileView =  currTileView;
        }
        
    }

    CGPoint currentTilePoint = [[wordTileView superview] convertPoint:[keyTileView center] fromView:[keyTileView superview]];
    
    
    //always incoming from the right
    
    CGPoint incomingOffscreenPoint = [self.view convertPoint:CGPointMake(self.view.bounds.size.width, 0) toView:keyTileView.superview];
    
    
    CGPoint outgoingOffscreenPoint = [self.view convertPoint:CGPointMake(0 - wordTileView.frame.size.width/2.0, 0) toView:wordTileView.superview];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        incomingOffscreenPoint.y = [keyTileView defaultCenter].y + 80.0;
        outgoingOffscreenPoint.y = wordTileView.defaultCenter.y + 80.0;
    }else{
        incomingOffscreenPoint.y = [keyTileView defaultCenter].y + 12.0;
        outgoingOffscreenPoint.y = wordTileView.defaultCenter.y + 12.0;
    }
    
    
    CGFloat outgoingDist = CGPointDist(outgoingOffscreenPoint, wordTileView.defaultCenter);
    
    CGFloat incomingDist = CGPointDist(keyTileView.defaultCenter, incomingOffscreenPoint);
    CGFloat activeSetDist = CGPointDist(wordTileView.defaultCenter, currentTilePoint);
    
    CGFloat outgoingAnimationDuration = outgoingDist/WALKING_SPEED;
    CGFloat incomingAnimationDuration = incomingDist/WALKING_SPEED;
    CGFloat activeSetAnimationDuration = activeSetDist/(WALKING_SPEED/4);
    
    activeSetAnimationDuration = MIN(outgoingAnimationDuration, activeSetAnimationDuration);
    
    
    
    [wordTileView.superview addSubview:self.animationTileView];
    
    [self.animationTileView setDefaultCenter:wordTileView.center animated:NO];
    //self.animationTileView.center = currentTilePoint;
    self.animationTileView.isWalking = YES;
    keyTileView.isWalking = YES;
    [keyTileView setCenter:incomingOffscreenPoint state:TileStateNormal animated:NO];
    
    self.animationTileView.letter = wordTileView.letter;
    wordTileView.letter = keyTileView.letter;
    
    [self setTileViewIndices];
    
    NSInteger ktvIndex = [keyTileView.superview.subviews indexOfObject:keyTileView];
    
    NSInteger animationIndex = 0;
    
    [wordTileView setCenter:currentTilePoint state:TileStateNormal animated:NO];
    
    //for positioning on the keyboard
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        
        if (ktvIndex < 7) {
            animationIndex = 6;
        }else if (ktvIndex < 14) {
            animationIndex = 13;
        }else if (ktvIndex < 21) {
            animationIndex = 20;
        }else {
            animationIndex = 25;
        }
        
    }else{
        if (ktvIndex < 10) {
            animationIndex = 9;
        }else if (ktvIndex < 19) {
            animationIndex = 18;
        }else {
            animationIndex = 25;
        }
    }
    
    [keyTileView.superview insertSubview:keyTileView atIndex:animationIndex];
    
    
    //we check if we are finished, as multiple moves can overlap animations.
    
    [UIView animateWithDuration:activeSetAnimationDuration
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         [wordTileView setCenter:[wordTileView defaultCenter] state:TileStateNormal animated:NO];
                     }
                    completion:^(BOOL finished) {
                        if (finished) {
                            [wordTileView setTileState:TileStateNormal];
                            wordTileView.isWalking = NO;
                        }
                    }];
    
    [UIView animateWithDuration:outgoingAnimationDuration
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         [self.animationTileView setCenter:outgoingOffscreenPoint state:TileStateNormal animated:NO];
                     }
                     completion:^(BOOL finished) {
                         if(finished){
                             self.activeWord = word;
                             self.animationTileView.isWalking = NO;
                             [self.animationTileView removeFromSuperview];
                             [self reload];
                             if (finish != NULL) {
                                 finish();
                             }
                         }
                     }];
    
    [UIView animateWithDuration:incomingAnimationDuration
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         [keyTileView setCenter:keyTileView.defaultCenter state:TileStateNormal animated:NO];
                     } completion:^(BOOL finished) {
                         if(finished){
                             keyTileView.isWalking = NO;
                         }
                     }];
}

-(void)didTouchDownTile:(id)sender{
    
    self.selectedTileView = OBJECT_IF_OF_CLASS(sender, TileView);
    
    [UIView animateWithDuration:0.2 animations:^{
        self.feedbackLabel.alpha = 1.0;
    }];
    
    self.feedbackLabel.text = [self selectedFeedbackString];

    self.activeTileView.selected = NO;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PuGameTilePositionControllerDidSelectTile object:self];
    
    /*
    TileView* tile = OBJECT_IF_OF_CLASS(sender, TileView);
    
#warning lift and animate the tile, do not make a copy
    if (![[tile superview] isEqual:[self view]]) {
        
        TileView* replacementTile = [TileUtilities tileWithTile:tile];
        
        [self addEventsToTile:replacementTile];
        
        [tile.superview addSubview:replacementTile];
        
        CGPoint center = [tile.superview convertPoint:tile.center toView:self.view];
        
        [tile setDefaultCenter:center animated:NO];
        
        [self.view addSubview:tile];
        
    }*/
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
        
    self.temporaryWordTiles = [self currentWordTilesWithTile:tile wordEditState:state];
    
    if (![self.temporaryWordTiles containsObject:tile]) {
        [tile resetAnimated];
    }
    
    [self setTileViewIndices];
    
    //[self animateToState:WordEditStateNone];
    
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
            NSInteger index = [self.currentWordTiles indexOfObject:tappedTileView];
            if (index != NSNotFound) {
                NSMutableArray* tiles = [self.currentWordTiles mutableCopy];
                [tiles replaceObjectAtIndex:index withObject:self.activeTileView];
                self.temporaryWordTiles = tiles;
                [[NSNotificationCenter defaultCenter] postNotificationName:ProposedWordNotification object:self];
            }
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
    
    int count = self.temporaryWordTiles.count;
    
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
        [pString appendString:[tile letter]];
    }

    if ([pString isEqualToString:self.activeWord]) {
        self.feedbackLabel.text = [self selectedFeedbackString];
    }else{
        self.feedbackLabel.text = [self spellingFeedbackStringWithWord:pString];
    }
    
}

-(NSString*)canNotMoveFeedbackStringWithWord:(NSString*)word{
    return [NSString stringWithFormat:@"\"%@\" not recognized",[word uppercaseString]];
}

-(NSString*)selectedFeedbackString{
    return [NSString stringWithFormat:@"Selected \"%@\"",[self.selectedTileView.letter uppercaseString]];
}

-(NSString*)spellingFeedbackStringWithWord:(NSString*)word{
    return [NSString stringWithFormat:@"Spelling \"%@\"",[word uppercaseString]];
}

@end
