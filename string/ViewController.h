//
//  ViewController.h
//  string
//
//  Created by Ryou Inoue on 2013/09/13.
//  Copyright (c) 2013年 Ryou Inoue. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
- (IBAction)resetPosition:(id)sender;
- (IBAction)changedValue:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *string;
@property (weak, nonatomic) IBOutlet UISlider *colorSlider;

@end
