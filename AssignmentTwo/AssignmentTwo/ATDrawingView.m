//
//  ATDrawingView.m
//  AssignmentTwo
//
//  Created by Chad Marmon on 1/26/13.
//  Copyright (c) 2013 Chad Marmon. All rights reserved.
//

#import "ATDrawingView.h"   

@implementation ATDrawingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        path = [UIBezierPath new];
        secondPath = [UIBezierPath new];
        viewcolor = [UIColor grayColor];
    }
    return self;
}

    //Draws a rectangle with a filled oval and an arc cutting though it making it invert its colors at that spot
- (void) firstDrawing
{
    dispatch_async( dispatch_get_main_queue(), ^{ //so it will draw on the first time through

    secondPath = [UIBezierPath new]; //resets the drawing so it doesnt display here
    path = [UIBezierPath bezierPathWithOvalInRect:self.bounds];
    CGPoint center = CGPointMake(self.bounds.size.width, self.bounds.size.height);
    CGPoint firstpoint = CGPointMake(150, 100);
    CGPoint secondpoint = CGPointMake(100, 50);
    [path addCurveToPoint:center controlPoint1:firstpoint controlPoint2:secondpoint];
    [path  addArcWithCenter:center radius:123.34 startAngle:0 endAngle:1 clockwise:YES];
    
    [self setNeedsDisplay];
    });
}

    //draws a bunch of random shapes and one round rectangle on the top only for some reason
- (void) secondDrawing
{
    path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(self.center.x, self.center.y, 100, 50) cornerRadius:30.]; //only displays on top pannel only not sure why yet.. same code for all three
    secondPath = [UIBezierPath new];
    for (int i = 0; i < 10; i++)
    {
        CGPoint point = CGPointMake((CGFloat)(arc4random() % (int)self.bounds.size.width), (CGFloat)(arc4random() % (int)self.bounds.size.height));
        CGPoint newpoint = CGPointMake((CGFloat)(arc4random() % (int)self.bounds.size.width), (CGFloat)(arc4random() % (int)self.bounds.size.height));
        [path addQuadCurveToPoint:point controlPoint:newpoint];
    }

    [self setNeedsDisplay];
}

    //draws a bunch of lines.. they apear to all start at  0, 0 for some reason might look into why later
- (void) thirdDrawing
{
    path = [UIBezierPath new]; //resets the drawing here so it doesnt display
    secondPath = [UIBezierPath bezierPathWithRect:self.bounds];
    for (int i = 0; i < 10 ;i++)
    {
        [secondPath addLineToPoint:CGPointMake((CGFloat)(arc4random() % (int)self.bounds.size.width), (CGFloat)(arc4random() % (int)self.bounds.size.height))];
    }
    [self setNeedsDisplay];
}

-(void) awakeFromNib //what i believe gets called from IB
{
    path = [UIBezierPath new];
    secondPath = [UIBezierPath new];
    viewcolor = [UIColor grayColor];
}

//so i can change the color of what will get painted
- (void) setColor:(UIColor*) color
{
    viewcolor = color;
}

//draws the rectangle at the end of everything
- (void)drawRect:(CGRect)rect
{
    NSLog( @"drawing %@", path );
    secondPath.lineWidth = 5.0;
    [viewcolor set];
    [path fill];
    [secondPath stroke];
}

@end
