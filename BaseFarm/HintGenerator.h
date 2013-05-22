//
//  HintGenerator.h
//  LetterFarm
//
//  Created by Daniel Mueller on 9/16/12.
//
//

#import "BaseGenerator.h"
#import "BaseFarm.h"

@interface HintGenerator : BaseGenerator

@property (nonatomic, copy) NSString* startWord;
@property (nonatomic, copy) NSString* finalWord;

@end
