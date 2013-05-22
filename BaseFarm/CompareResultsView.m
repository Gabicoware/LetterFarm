//
//  CompareResultsView.m
//  LetterFarm
//
//  Created by Daniel Mueller on 2/20/13.
//
//

#import "CompareResultsView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIValues.h"
#import "NSString+LF.h"

void CGContextDrawSlopedRect(CGContextRef ctx, CGPoint topLeft, CGPoint topRight, CGPoint bottomRight, CGPoint  bottomLeft);

typedef enum _ResultsViewPosition{
    ResultsViewPositionNone,
    ResultsViewPositionLeft,
    ResultsViewPositionMiddle,
    ResultsViewPositionRight,
} ResultsViewPosition;


@interface InternalResultsView : UIView

@property (nonatomic) ResultsViewPosition position;

@property (nonatomic) NSArray* words;

@property (nonatomic) UIColor* compareColor;

@property (nonatomic) int wordCount;

//An array of NSNumber objects
//the presence of an indice indicates that the word was used comparee, and should not be colored
@property (nonatomic) NSArray* indices;

@end


@interface CompareResultsView ()

@property (nonatomic) NSArray* leftWords;
@property (nonatomic) NSArray* rightWords;
@property (nonatomic) NSString* endWord;

@property (nonatomic) InternalResultsView* leftResultsView;
@property (nonatomic) InternalResultsView* rightResultsView;
@property (nonatomic) CALayer* gutterLayer;

@property (nonatomic) NSDictionary* leftIndiceDict;
@property (nonatomic) NSDictionary* rightIndiceDict;

@end

@implementation CompareResultsView{
    CGPoint _initialPoint;
    CGFloat _initialYOffset;
    CGFloat _currentYOffset;
    CGFloat _maxYOffset;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self internalSetup];
    }
    return self;
}

-(void)awakeFromNib{
    [self internalSetup];
}

-(void)internalSetup{
    self.clipsToBounds = YES;
    // Initialization code
    self.gutterLayer = [CALayer layer];
    [self.layer addSublayer:self.gutterLayer];
    self.leftResultsView = [[InternalResultsView alloc] initWithFrame:CGRectZero];
    self.leftResultsView.position = ResultsViewPositionLeft;
    self.leftResultsView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.leftResultsView];
    self.rightResultsView = [[InternalResultsView alloc] initWithFrame:CGRectZero];
    self.rightResultsView.backgroundColor = [UIColor clearColor];
    self.leftResultsView.position = ResultsViewPositionRight;
    [self addSubview:self.rightResultsView];
}


-(void)reloadWithLeftWords:(NSArray*)leftWords rightWords:(NSArray*)rightWords endWord:(NSString*)endWord{
    
    if (leftWords == nil) {
        leftWords = rightWords;
        rightWords = nil;
    }
    
    
    self.leftWords = leftWords;
    self.rightWords = rightWords;
    self.endWord = endWord;
    
    self.rightResultsView.words = rightWords;
    self.leftResultsView.words = leftWords;
    
    if ( rightWords == nil) {
        
        NSMutableDictionary* leftIndices = [NSMutableDictionary dictionary];
        
        for (NSString* word in leftWords) {
            
            if ([leftIndices objectForKey:word] == nil) {
                int leftIndex = [self.leftWords indexOfObject:word];
                [leftIndices setObject:[NSNumber numberWithInt:leftIndex] forKey:word];
            }
        }
        
        self.leftIndiceDict = [NSDictionary dictionaryWithDictionary:leftIndices];
        self.rightIndiceDict = nil;
        
        self.leftResultsView.indices = [leftIndices allValues];
        self.rightResultsView.indices = nil;
        
        self.leftResultsView.position = ResultsViewPositionMiddle;
        self.rightResultsView.position = ResultsViewPositionNone;
    }else{
        
        NSSet* leftSet = [NSSet setWithArray:leftWords];
        NSSet* rightSet = [NSSet setWithArray:rightWords];
        
        NSMutableSet* intersection = [leftSet mutableCopy];
        [intersection intersectSet:rightSet];
        
        NSMutableDictionary* leftIndices = [NSMutableDictionary dictionary];
        NSMutableDictionary* rightIndices = [NSMutableDictionary dictionary];
        
        
        for (NSString* word in intersection) {
            
            if ([leftIndices objectForKey:word] == nil) {
                int leftIndex = [self.leftWords indexOfObject:word];
                [leftIndices setObject:[NSNumber numberWithInt:leftIndex] forKey:word];
            }
            
            if ([rightIndices objectForKey:word] == nil) {
                int rightIndex = [self.rightWords indexOfObject:word];
                [rightIndices setObject:[NSNumber numberWithInt:rightIndex] forKey:word];
            }
        }
        
        int highestIndex = -1;
        
        for (int index = 0; index < self.leftWords.count; index++){
            NSString* word = [self.leftWords objectAtIndex:index];
            
            NSNumber* rightNumber = [rightIndices objectForKey:word];
            
            if(rightNumber != nil){
                
                int rightIndex = [rightNumber integerValue];
                
                if (highestIndex < rightIndex) {
                    highestIndex = rightIndex;
                }else{
                    [leftIndices removeObjectForKey:word];
                    [rightIndices removeObjectForKey:word];
                    
                }
            }
            
            
        }
        
        self.leftIndiceDict = [NSDictionary dictionaryWithDictionary:leftIndices];
        self.rightIndiceDict = [NSDictionary dictionaryWithDictionary:rightIndices];
        
        self.rightResultsView.indices = [rightIndices allValues];
        self.leftResultsView.indices = [leftIndices allValues];
        
        self.leftResultsView.position = ResultsViewPositionLeft;
        self.rightResultsView.position = ResultsViewPositionRight;
    }
    
    _currentYOffset = 0;
    
    [self setNeedsLayout];
}

#define RADIUS 10.0

#define ROW_HEIGHT 30.0

#define GUTTER_RATIO 0.20

-(void)layoutSubviews{
    
    if (self.compareColor == nil) {
        self.compareColor = [UIColor lightGrayColor];
    }
    
    self.rightResultsView.compareColor = self.compareColor;
    self.leftResultsView.compareColor = self.compareColor;
    
    int rightCount = self.rightWords.count + ([self.endWord isEqualToString:self.rightWords.lastObject] ? 0 : 1);
    
    self.rightResultsView.wordCount = rightCount;
    
    CGFloat rightHeight = ROW_HEIGHT*(CGFloat)rightCount;
    
    int leftCount = self.leftWords.count + ([self.endWord isEqualToString:self.leftWords.lastObject] ? 0 : 1);
    
    self.leftResultsView.wordCount = leftCount;
    
    CGFloat leftHeight = ROW_HEIGHT*(CGFloat)leftCount;
    
    
    CGFloat rightOffsetY = 0.0; //......
    CGFloat leftOffsetY = 0.0; //......
    
    if (leftHeight < self.bounds.size.height && leftHeight < rightHeight) {
        CGFloat height = MIN(rightHeight,self.bounds.size.height);
        leftOffsetY = (height - leftHeight)/2.0;
    }
    if (rightHeight < self.bounds.size.height && rightHeight < leftHeight) {
        CGFloat height = MIN(leftHeight,self.bounds.size.height);
        rightOffsetY = (height - rightHeight)/2.0;
    }
    
    
    CGFloat selfWidth = self.bounds.size.width;
    
    
    if (self.rightWords == nil) {
        
        CGFloat wordsWidth = floor(selfWidth*(1.0 - GUTTER_RATIO));
        
        CGFloat leftOrigin = ( selfWidth - wordsWidth ) / 2.0;
        
        self.leftResultsView.frame = CGRectMake(leftOrigin, leftOffsetY, wordsWidth, leftHeight);
        
        //CGFloat rightOriginX = selfWidth - wordsWidth;
        //self.rightResultsView.frame = CGRectMake(rightOriginX, rightOffsetY, wordsWidth, rightHeight);
        
        self.rightResultsView.hidden = YES;
    }else{
        CGFloat wordsWidth = floor((selfWidth*(1.0 - GUTTER_RATIO))/2.0);
        
        CGFloat rightOriginX = selfWidth - wordsWidth;
        
        self.rightResultsView.frame = CGRectMake(rightOriginX, rightOffsetY, wordsWidth, rightHeight);
        
        self.leftResultsView.frame = CGRectMake(0, leftOffsetY, wordsWidth, leftHeight);
        
        self.rightResultsView.hidden = NO;
    }
    
    
    _maxYOffset = -1*(MAX(leftHeight, rightHeight) - self.bounds.size.height);
    
}

-(void)drawRect:(CGRect)rect{
    
    if (self.rightWords == nil) {
        return;
    }
    
    //always draw in relation to the frames
    
    CGRect rightFrame = self.rightResultsView.frame;
    CGRect leftFrame = self.leftResultsView.frame;
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(ctx, [[UIColor whiteColor] CGColor]);
    
    CGFloat leftX = leftFrame.origin.x + leftFrame.size.width;
    CGFloat rightX = rightFrame.origin.x;
    
    
    CGPoint topLeft = CGPointMake(leftX, leftFrame.origin.y);
    CGPoint topRight = CGPointMake(rightX, rightFrame.origin.y);
    CGPoint bottomRight = CGPointMake(rightX, rightFrame.origin.y+rightFrame.size.height);
    CGPoint bottomLeft = CGPointMake(leftX, leftFrame.origin.y+leftFrame.size.height);
    
    CGContextDrawSlopedRect(ctx, topLeft, topRight, bottomRight, bottomLeft);
    
    CGContextSetFillColorWithColor(ctx, [self.compareColor CGColor]);
    
    int rightIndex = 0;
    int leftIndex = 0;
    while (rightIndex < self.rightResultsView.wordCount && leftIndex < self.leftResultsView.wordCount) {
        
        
        int leftErrorIndexCount = 0;
        while (![[self.leftIndiceDict allValues] containsObject:[NSNumber numberWithInt:leftIndex + leftErrorIndexCount]] && leftIndex + leftErrorIndexCount < self.leftResultsView.wordCount){
            leftErrorIndexCount++;
        }

        int rightErrorIndexCount = 0;
        while (![[self.rightIndiceDict allValues] containsObject:[NSNumber numberWithInt:rightIndex + rightErrorIndexCount]] && rightIndex + rightErrorIndexCount < self.rightResultsView.wordCount){
            rightErrorIndexCount++;
        }
        
        if (0 < rightErrorIndexCount || 0 < leftErrorIndexCount) {
            
            CGPoint eTopLeft = CGPointMake(leftX, topLeft.y + ROW_HEIGHT*((CGFloat)leftIndex));
            CGPoint eTopRight = CGPointMake(rightX, topRight.y + ROW_HEIGHT*((CGFloat)rightIndex));
            CGPoint eBottomRight = CGPointMake(rightX, topRight.y + ROW_HEIGHT*((CGFloat)(rightIndex + rightErrorIndexCount)));
            CGPoint eBottomLeft = CGPointMake(leftX, topLeft.y + ROW_HEIGHT*((CGFloat)(leftIndex + leftErrorIndexCount)));
            
            CGContextDrawSlopedRect(ctx, eTopLeft, eTopRight, eBottomRight, eBottomLeft);
            
            
        }
        
        
        
        rightIndex += rightErrorIndexCount;
        leftIndex += leftErrorIndexCount;
        
        rightIndex++;
        leftIndex++;
    }
    
}

//ignore the superclass implementation of the tracking methods

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    UITouch* touch = [touches anyObject];
    
    _initialYOffset = _currentYOffset;
    
    //send value changed event
    _initialPoint = [touch locationInView:self];
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    UITouch* touch = [touches anyObject];
    
    CGPoint location = [touch locationInView:self];
    
    CGFloat updatedOffset = _initialYOffset + (location.y - _initialPoint.y)/2.0;
    
    [self updateWithOffset:updatedOffset];
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    UITouch* touch = [touches anyObject];
    
    CGPoint location = [touch locationInView:self];
    
    CGFloat updatedOffset = _initialYOffset + (location.y - _initialPoint.y)/2.0;
    
    [self updateWithOffset:updatedOffset];
    
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    
}

-(void)updateWithOffset:(CGFloat)offset{
    
    offset = MIN(MAX(offset, _maxYOffset), 0);
    
    if(offset != _currentYOffset){
        
        _currentYOffset = offset;
        
        CGFloat leftHeight = self.leftResultsView.frame.size.height - self.bounds.size.height;
        CGFloat rightHeight = self.rightResultsView.frame.size.height - self.bounds.size.height;
        
        CGFloat maxHeight = MAX(rightHeight, leftHeight);
        
        CGFloat leftScale = leftHeight/maxHeight;
        CGFloat rightScale = rightHeight/maxHeight;
        
        if (leftScale > 0) {
            CGRect leftFrame = self.leftResultsView.frame;
            leftFrame.origin.y = leftScale*_currentYOffset;
            self.leftResultsView.frame = leftFrame;
        }
        
        if (rightScale > 0) {
            CGRect rightFrame = self.rightResultsView.frame;
            rightFrame.origin.y = rightScale*_currentYOffset;
            self.rightResultsView.frame = rightFrame;
        }
        
        
        CGFloat selfWidth = self.bounds.size.width;
        
        CGFloat wordsWidth = floor((selfWidth*(1.0 - GUTTER_RATIO))/2.0);
        
        CGRect gutterRect = CGRectMake(wordsWidth, 0, GUTTER_RATIO*selfWidth, self.bounds.size.height);
        
        [self setNeedsDisplayInRect:gutterRect];
        
        
        
    }
    
}

@end

@implementation InternalResultsView

-(void)drawRect:(CGRect)rect{
    
    if (self.compareColor == nil) {
        self.compareColor = [UIColor redColor];
    }
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGRect selfBounds = self.bounds;
    
    
    //sharp corner only on right side
    if (self.position == ResultsViewPositionRight) {
        CGContextMoveToPoint(ctx, 0.0, 0.0);
    //else make the endpoint of an arc
    }else{
        CGContextMoveToPoint(ctx, RADIUS, 0.0);
    }
    
    //sharp corner only on left side
    if (self.position == ResultsViewPositionLeft) {
        CGContextAddLineToPoint(ctx, selfBounds.size.width, 0.0);
        CGContextAddLineToPoint(ctx, selfBounds.size.width, selfBounds.size.height);
    //else make the endpoint of an arc
    }else{
        CGContextAddLineToPoint(ctx, selfBounds.size.width - RADIUS, 0.0);
        CGContextAddArcToPoint(ctx, selfBounds.size.width, 0, selfBounds.size.width, RADIUS, RADIUS);
        CGContextAddLineToPoint(ctx, selfBounds.size.width, selfBounds.size.height - RADIUS);
        CGContextAddArcToPoint(ctx, selfBounds.size.width, selfBounds.size.height, selfBounds.size.width-RADIUS, selfBounds.size.height, RADIUS);
    }
    
    //sharp corner only on right side
    if (self.position == ResultsViewPositionRight) {
        CGContextAddLineToPoint(ctx, 0.0, selfBounds.size.height);
        CGContextAddLineToPoint(ctx, 0.0, 0.0);
    //else make the endpoint of an arc
    }else{
        CGContextAddLineToPoint(ctx, RADIUS, selfBounds.size.height);
        CGContextAddArcToPoint(ctx, 0, selfBounds.size.height, 0, selfBounds.size.height-RADIUS, RADIUS);
        CGContextAddLineToPoint(ctx, 0, RADIUS);
        CGContextAddArcToPoint(ctx, 0, 0, RADIUS, 0, RADIUS);
    }
    
    CGContextSetFillColorWithColor(ctx, [[UIColor whiteColor] CGColor]);
    CGContextClosePath(ctx);
    
    CGContextFillPath(ctx);
    
    CGContextSetFillColorWithColor(ctx, [self.compareColor CGColor]);
    
    
    CGFloat f_rowCount = selfBounds.size.height/ROW_HEIGHT;
    
    int roundCount = (int)round(f_rowCount);
    
    for (int index = 0; index < roundCount; index++) {
        
        BOOL hasIndex = [self.indices containsObject:[NSNumber numberWithInt:index]];
        
        if(!hasIndex){
            //color it
            CGFloat f_index = (CGFloat)index;
            
            if (index == 0) {
                
                CGContextMoveToPoint(ctx, 0.0, ROW_HEIGHT);
                
                if (self.position == ResultsViewPositionRight) {
                    CGContextAddLineToPoint(ctx, 0.0, 0.0);
                }else{
                    CGContextAddLineToPoint(ctx, 0.0, RADIUS);
                    CGContextAddArcToPoint(ctx, 0.0, 0.0, RADIUS, 0.0, RADIUS);
                }
                
                if (self.position == ResultsViewPositionLeft) {
                    CGContextAddLineToPoint(ctx, selfBounds.size.width, 0.0);
                }else{
                    CGContextAddLineToPoint(ctx, selfBounds.size.width - RADIUS, 0.0);
                    CGContextAddArcToPoint(ctx, selfBounds.size.width, 0.0, selfBounds.size.width, RADIUS, RADIUS);
                }
                
                CGContextAddLineToPoint(ctx, selfBounds.size.width, ROW_HEIGHT);
                CGContextAddLineToPoint(ctx, 0.0, ROW_HEIGHT);
                
                CGContextClosePath(ctx);
                CGContextFillPath(ctx);
            }else if(index == roundCount-1){
                
                CGContextMoveToPoint(ctx, 0.0, f_index*ROW_HEIGHT);
                CGContextAddLineToPoint(ctx, selfBounds.size.width, f_index*ROW_HEIGHT);
                
                if (self.position == ResultsViewPositionLeft) {
                    CGContextAddLineToPoint(ctx, selfBounds.size.width, selfBounds.size.height);
                }else{
                    CGContextAddLineToPoint(ctx, selfBounds.size.width, selfBounds.size.height - RADIUS);
                    CGContextAddArcToPoint(ctx, selfBounds.size.width, selfBounds.size.height, selfBounds.size.width - RADIUS, selfBounds.size.height, RADIUS);
                }
                
                if (self.position == ResultsViewPositionRight) {
                    CGContextAddLineToPoint(ctx, 0, selfBounds.size.height);
                }else{
                    CGContextAddLineToPoint(ctx, RADIUS, selfBounds.size.height);
                    CGContextAddArcToPoint(ctx, 0.0, selfBounds.size.height, 0.0, selfBounds.size.height - RADIUS, RADIUS);
                }
                
                CGContextAddLineToPoint(ctx, 0.0, f_index*ROW_HEIGHT);
                
                CGContextClosePath(ctx);
                CGContextFillPath(ctx);
                
            }else{
                CGRect fillRect = CGRectMake(0, f_index*ROW_HEIGHT, selfBounds.size.width, ROW_HEIGHT);
                CGContextFillRect(ctx, fillRect);
            }
            
        }
        
    }
        
#ifdef LETTER_WORD
    UIFont* font = [UIValues letterFontOfSize:18.0];

    CGContextSetFillColorWithColor(ctx, [[UIColor blackColor] CGColor]);
#endif
    
    CGFloat padding = 4;
    
    for (int index = 0; index < self.words.count; index++) {
        NSString* word = [[self.words objectAtIndex:index] uppercaseString];
        
        CGFloat f_index = (CGFloat)index;
        
        CGRect wordRect = CGRectMake(padding, f_index*ROW_HEIGHT+padding, selfBounds.size.width-2.0*padding, ROW_HEIGHT-2.0*padding);
        
#ifdef LETTER_WORD
        
        [word drawInRect:wordRect
                withFont:font
           lineBreakMode:UILineBreakModeClip
               alignment:UITextAlignmentCenter];
#endif
        
#ifdef COLOR_WORD
        
        NSArray* letters = word.letters;
        
        CGRect segmentRect = wordRect;
        segmentRect.size.width = wordRect.size.width/((CGFloat)letters.count);
        
        for (int letterIndex = 0; letterIndex < letters.count; letterIndex++) {
            NSString* letter = [letters objectAtIndex:letterIndex];
            
            segmentRect.origin.x = wordRect.origin.x + segmentRect.size.width*((CGFloat)letterIndex);
            
            CGRect strokeRect = CGRectInset(segmentRect, 1.0, 1.0);
            
            CGContextSetGrayFillColor(ctx, 0.3, 1.0);
            
            CGContextFillRect(ctx, strokeRect);
            
            CGRect paintRect = CGRectInset(segmentRect, 2.0, 2.0);
            
            UIColor* color = [UIValues colorWithLetter:letter];
            
            CGContextSetFillColorWithColor(ctx, color.CGColor);
            
            CGContextFillRect(ctx, paintRect);
            
        }
        
#endif
        
    }
    


}

@end

void CGContextDrawSlopedRect(CGContextRef ctx, CGPoint topLeft, CGPoint topRight, CGPoint bottomRight, CGPoint  bottomLeft){
    
    CGFloat topMid = (topLeft.x + topRight.x)/2.0;
    CGFloat bottomMid = (bottomRight.x + bottomLeft.x)/2.0;
    
    CGContextMoveToPoint(ctx, topLeft.x, topLeft.y);
    CGContextAddCurveToPoint(ctx, topMid, topLeft.y, topMid, topRight.y, topRight.x, topRight.y);
    
    CGContextAddLineToPoint(ctx, bottomRight.x, bottomRight.y);
    
    CGContextAddCurveToPoint(ctx, bottomMid, bottomRight.y, bottomMid, bottomLeft.y, bottomLeft.x, bottomLeft.y);
    CGContextAddLineToPoint(ctx, topLeft.x, topLeft.y);
    
    CGContextClosePath(ctx);
    
    CGContextFillPath(ctx);

}


