//
//  WordTableController.m
//  Letter Farm
//
//  Created by Daniel Mueller on 6/29/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import "WordTableController.h"

#import "TableViewCellFactory.h"

#import <QuartzCore/QuartzCore.h>

#define ANIMATION_DURATION 1.0

@interface WordTableController()

@property (nonatomic) IBOutlet UIView* topGradientView;

@property (nonatomic) IBOutlet UIView* bottomGradientView;

@property (nonatomic) NSArray* words;

@end

@implementation WordTableController

@synthesize bottomGradientView=_bottomGradientView, topGradientView=_topGradientView;

@synthesize words=_words;

@synthesize tableView=_tableView;


-(void)reloadDataWithWords:(NSArray*)words{
    self.words = words;
    
    [[self tableView] setContentOffset:CGPointZero];
    
    [[self tableView] reloadData];
    
    UIColor* gColor = [[self tableView] backgroundColor];
    
    if ([gColor isEqual:[UIColor clearColor]]) {
        gColor = [[[self tableView] superview] backgroundColor];
    }
    
    if (self.topGradientView != nil && gColor != nil) {
        CAGradientLayer *topGradient = [CAGradientLayer layer];
        topGradient.frame = self.topGradientView.bounds;
        topGradient.colors = [NSArray arrayWithObjects:(id)[gColor CGColor], (id)[[UIColor clearColor] CGColor], nil];
        [self.topGradientView.layer insertSublayer:topGradient atIndex:0];
    }
    
    
    if (self.bottomGradientView != nil && gColor != nil) {
        CAGradientLayer *bottomGradient = [CAGradientLayer layer];
        bottomGradient.frame = self.bottomGradientView.bounds;
        bottomGradient.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor], (id)[gColor CGColor], nil];
        [self.bottomGradientView.layer insertSublayer:bottomGradient atIndex:0];
    }
    
    [self scrollViewDidScroll:[self tableView]];
}

#pragma mark UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    BOOL shouldHideTopGradientView = YES;
    BOOL shouldHideBottomGradientView = YES;
    
    CGFloat offsetMaxY = scrollView.contentSize.height - scrollView.bounds.size.height;
    
    if( 0 < offsetMaxY ){
        
        CGPoint offset = scrollView.contentOffset;
        
        if ( 0 < offset.y ) {
            
            CGFloat topGradientAlpha = 1.0;
            
            if (offset.y < self.topGradientView.frame.size.height) {
                topGradientAlpha = offset.y / self.topGradientView.frame.size.height;
            }
            
            self.topGradientView.alpha = topGradientAlpha;
            
            shouldHideTopGradientView = NO;
        }
        
        if( offset.y < offsetMaxY){
            
            CGFloat bottomGradientAlpha = 1.0;
            
            CGFloat inverseOffsetY = offsetMaxY - offset.y;
            
            if (inverseOffsetY < self.bottomGradientView.frame.size.height) {
                bottomGradientAlpha = inverseOffsetY / self.bottomGradientView.frame.size.height;
            }
            
            self.bottomGradientView.alpha = bottomGradientAlpha;
            
            shouldHideBottomGradientView = NO;
        }
    }
    
    self.topGradientView.hidden = shouldHideTopGradientView;
    self.bottomGradientView.hidden = shouldHideBottomGradientView;
    
}

#pragma mark UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [self.words count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString* CellIdentifier = @"WordHistoryTableViewCell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [TableViewCellFactory newWordTableViewCellWithReuseIdentifier:CellIdentifier];
    }
    
    NSInteger index = [indexPath row];
    
    NSString* word = [[self.words objectAtIndex:index] uppercaseString];
    
    [[cell wordLabel] setText:word];
    
    return cell;
}


@end