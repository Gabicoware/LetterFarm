//
//  CompareResultsView.h
//  LetterFarm
//
//  Created by Daniel Mueller on 2/20/13.
//
//

#import <UIKit/UIKit.h>

/*
 * Known issues: If a word appears more that once in the list, it will categorize it as an error
 *
 *
 **/



@interface CompareResultsView : UIView

-(void)reloadWithLeftWords:(NSArray*)leftWords rightWords:(NSArray*)rightWords endWord:(NSString*)endWord;

@property (nonatomic) UIColor* compareColor;

@end
