//
//  DetailViewController.h
//  Programming
//
//  Created by Ishaan Gulrajani on 4/4/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <MessageUI/MessageUI.h>
@class RootViewController;

@interface DetailViewController : UIViewController <UIPopoverControllerDelegate, UISplitViewControllerDelegate, UITextViewDelegate, UIAlertViewDelegate, MFMailComposeViewControllerDelegate> {
    UIPopoverController *popoverController;
    NSManagedObject *detailItem;
	
	UITextView *textView;
	
	BOOL keyboardVisible;
	
	NSString *lastChange;
}
@property(nonatomic,retain) NSManagedObject *detailItem;
@property(nonatomic,retain) IBOutlet UITextView *textView;

-(void)configureView;
-(void)keyboardWillShow:(NSNotification *)note;
-(void)keyboardWillHide:(NSNotification *)note;


@end
