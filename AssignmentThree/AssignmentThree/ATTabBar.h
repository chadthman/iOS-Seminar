//
//  ATTabBar.h
//  AssignmentThree
//
//  Created by Chad Marmon on 2/4/13.
//  Copyright (c) 2013 Chad Marmon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ATTabBar : UITabBarController

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
- (void)configureView;
//- (void) addWindow;

@end
