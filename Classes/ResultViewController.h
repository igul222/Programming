//
//  ResultViewController.h
//  Programming
//
//  Created by Ishaan Gulrajani on 4/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ResultViewController : UIViewController {
	UITextView *textView;
	UINavigationBar *navBar;
	UINavigationItem *navItem;
	
	NSString *result;
}
@property(nonatomic,retain) NSString *result;

@property(nonatomic,retain) IBOutlet UITextView *textView;
@property(nonatomic,retain) IBOutlet UINavigationBar *navBar;
@property(nonatomic,retain) IBOutlet UINavigationItem *navItem;

-(void)doneButtonPressed;

@end
