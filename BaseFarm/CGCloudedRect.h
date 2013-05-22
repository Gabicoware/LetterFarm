//
//  CGCloudedRect.h
//  LetterFarm
//
//  Created by Daniel Mueller on 9/25/12.
//
//

#import <QuartzCore/QuartzCore.h>

#ifndef LetterFarm_CGCloudedRect_h
#define LetterFarm_CGCloudedRect_h

//adds the path, does not stroke or fill
//works best when the coordinates of the rect are all on 0.5 (1.5,2.5, etc) and the radius is a whole number
void CGContextAddRoundedRect(CGContextRef c, CGRect rect, CGFloat radius);

void CGContextAddCloudedRect(CGContextRef c, CGRect rect, CGFloat radius);

#endif
