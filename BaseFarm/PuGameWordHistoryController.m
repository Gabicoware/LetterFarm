//
//  PuGameWordHistoryController.m
//  Letter Farm
//
//  Created by Daniel Mueller on 6/4/12.
//  Copyright (c) 2012 Gabicoware LLC. All rights reserved.
//

#import "PuGameWordHistoryController.h"
#import "PuzzleGame.h"
#import "TableViewCellFactory.h"

@interface PuGameWordHistoryController ()

@property (nonatomic) NSMutableArray* guessedWords;

@property (nonatomic, copy) NSString* finalWord;

@property (nonatomic, assign) NSInteger lastNumberOfRows;

@property (nonatomic) IBOutlet UITableView* tableView;

@end

@implementation PuGameWordHistoryController

@synthesize guessedWords=_guessedWords, finalWord=_finalWord;
@synthesize tableView=_tableView;
@synthesize lastNumberOfRows=_lastNumberOfRows;


-(void)resetWithGame:(PuzzleGame*)puzzleGame{
    
    NSArray* reversedArray = [[puzzleGame.guessedWords reverseObjectEnumerator] allObjects];
    
    self.guessedWords = [NSMutableArray arrayWithArray:reversedArray];
    
    self.finalWord = puzzleGame.endWord;
    
    self.tableView.transform = CGAffineTransformMakeRotation(M_PI);
    
    [self.tableView reloadData];
}

-(void)popWord{
    
    [self.guessedWords removeObjectAtIndex:0];
    
    if([self currentNumberOfRows] == self.lastNumberOfRows - 1){
        
        [self.tableView beginUpdates];
        
        NSArray* indexPaths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:2 inSection:0]];
        
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        
        [self.tableView endUpdates];
    }else{
        
        [self.tableView reloadData];
        
    }

}

-(void)pushWord:(NSString*)word{
    [self.guessedWords insertObject:word atIndex:0];
    
    if ([word isEqualToString:self.finalWord]) {
        
        NSArray* pathsToRemove = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:0]];
        
        [self.tableView beginUpdates];
        [[self tableView] deleteRowsAtIndexPaths:pathsToRemove withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
        
    }else if([self currentNumberOfRows] == self.lastNumberOfRows + 1){
        NSArray* indexPaths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:2 inSection:0]];
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }else{
        [self.tableView reloadData];
    }
    
}

-(NSString*)wordAtIndex:(NSInteger)index{
    NSString* word = nil;
    
    NSInteger offsetIndex = index - 2;
    
    if (offsetIndex < self.guessedWords.count) {
        word = [self.guessedWords objectAtIndex:offsetIndex];
    }else if (index == 0) {
        word = self.finalWord;
    }
    return word;

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    self.lastNumberOfRows = [self currentNumberOfRows];
    
    return self.lastNumberOfRows;
}

-(NSInteger)currentNumberOfRows{
    
    NSInteger result = 0;
    
    NSString* lastGuessedWord = 0 < self.guessedWords.count ? [self.guessedWords objectAtIndex:0] : nil;
    if (self.guessedWords == nil) {
        result = 0;
    }else if ([lastGuessedWord isEqualToString:self.finalWord]) {
        result = self.guessedWords.count;
    }else{
        result = self.guessedWords.count+2;
    }
    
    return result;
    
}

#define IMAGE_VIEW_TAG 1001

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString* WordCellIdentifier = @"WordHistoryTableViewCellWord";
    static NSString* ArrowCellIdentifier = @"WordHistoryTableViewCellArrow";
    
    NSInteger index = [indexPath row];
    
    NSString* word = [self wordAtIndex:index];
        
    NSString* identifier = nil;
    
    if (word == nil) {
        identifier = ArrowCellIdentifier;
    }else{
        identifier = WordCellIdentifier;
    }

    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        if ([identifier isEqualToString:WordCellIdentifier]) {
            cell = [TableViewCellFactory newWordTableViewCellWithReuseIdentifier:WordCellIdentifier];
        }else{
            cell = [TableViewCellFactory newArrowTableViewCellWithReuseIdentifier:ArrowCellIdentifier];
        }
    }
    
    if ([identifier isEqualToString:WordCellIdentifier]) {
        [[cell wordLabel] setText:word];
    }
    
    cell.transform = CGAffineTransformMakeRotation(-1.0*M_PI);

    return cell;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGRect tableViewFrame = self.tableView.frame;
    for (UITableViewCell* cell in [self.tableView visibleCells]) {
        CGRect cellRect = [[self.tableView superview] convertRect:[cell bounds] fromView:cell];
        
        CGFloat bottomY = tableViewFrame.size.height + tableViewFrame.origin.y - cellRect.size.height;
        CGFloat topY = tableViewFrame.size.height + tableViewFrame.origin.y - 2*cellRect.size.height;
        
        if (cellRect.origin.y <= topY) {
            cell.alpha = 1.0;
        }else if(topY < cellRect.origin.y && cellRect.origin.y <= bottomY) {
            cell.alpha = (bottomY - cellRect.origin.y)/(bottomY - topY);
        }else{
            cell.alpha = 0.0;
        }
        
    }
}

@end
