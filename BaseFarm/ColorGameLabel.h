//
//  ColorGameLabel.h
//  LetterFarm
//
//  Created by Daniel Mueller on 4/29/13.
//
//

#import <UIKit/UIKit.h>

@interface ColorGameLabel : UILabel

@property (nonatomic, assign) int round;

@property (nonatomic) NSString* startWord;
@property (nonatomic) NSString* endWord;

@end
