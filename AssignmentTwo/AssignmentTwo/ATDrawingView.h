//
//  ATDrawingView.h
//  AssignmentTwo
//
//  Created by Chad Marmon on 1/26/13.
//  Copyright (c) 2013 Chad Marmon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ATDrawingView : UIView
{
    UIBezierPath *path;
    UIBezierPath *secondPath;
    UIColor *viewcolor;
}

- (void) awakeFromNib;
- (void) firstDrawing;
- (void) secondDrawing;
- (void) thirdDrawing;
- (void) setColor:(UIColor*) color;

@end
