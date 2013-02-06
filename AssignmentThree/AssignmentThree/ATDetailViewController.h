//
//  ATDetailViewController.h
//  AssignmentThree
//
//  Created by Chad Marmon on 2/2/13.
//  Copyright (c) 2013 Chad Marmon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ATDetailViewController : UIViewController <UISplitViewControllerDelegate>
{
    int count;
}
@property (strong, nonatomic) id detailItem;
@property UIStoryboard *story;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

-(IBAction)onAdvance;
//-(void) incrementByOne;
@end
