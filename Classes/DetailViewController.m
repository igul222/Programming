//
//  DetailViewController.m
//  Programming
//
//  Created by Ishaan Gulrajani on 4/4/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "IGPopoverManager.h"

#import "DetailViewController.h"
#import "ResultViewController.h"

#import "Program.h"

@interface DetailViewController ()
@property (nonatomic, retain) UIPopoverController *popoverController;
-(void)runCode;
-(void)email;
+(NSString *)extensionForLanguage:(NSString *)language;
@end



@implementation DetailViewController

@synthesize popoverController, detailItem, textView;


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
	[self configureView];
	
	[self.navigationController.navigationBar setTintColor:[UIColor darkGrayColor]];
	
	textView.font = [UIFont fontWithName:@"Inconsolata" size:17.0];
	
	keyboardVisible = NO;
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillShow:)
												 name:UIKeyboardWillShowNotification
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillHide:)
												 name:UIKeyboardWillHideNotification
											   object:nil];
}


/*
 - (void)viewWillAppear:(BOOL)animated {
 [super viewWillAppear:animated];
 }
 */
/*
 - (void)viewDidAppear:(BOOL)animated {
 [super viewDidAppear:animated];
 }
 */
/*
 - (void)viewWillDisappear:(BOOL)animated {
 [super viewWillDisappear:animated];
 }
 */
/*
 - (void)viewDidDisappear:(BOOL)animated {
 [super viewDidDisappear:animated];
 }
 */

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.popoverController = nil;
}



#pragma mark -
#pragma mark Rotation

// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[[IGPopoverManager currentPopoverController] dismissPopoverAnimated:YES];
	
	if(keyboardVisible) {
		if((toInterfaceOrientation==UIInterfaceOrientationLandscapeLeft) || (toInterfaceOrientation==UIInterfaceOrientationLandscapeRight)) {
			// going to landscape, make text view smaller by the difference in height of the landscape/portrait keyboards
			textView.frame = CGRectMake(textView.frame.origin.x, textView.frame.origin.y, textView.frame.size.width, textView.frame.size.height - (355-265));			
		} else {
			// going to landscape, make text view larger by that same difference
			textView.frame = CGRectMake(textView.frame.origin.x, textView.frame.origin.y, textView.frame.size.width, textView.frame.size.height + (355-265));
		}
	}
}

#pragma mark -
#pragma mark Text view support

-(void)textViewDidChange:(UITextView *)aTextView {
	[detailItem setValue:aTextView.text forKey:@"code"];
}

-(void)textViewDidChangeSelection:(UITextView *)textView {
	lastChange = @"selection";
}

-(BOOL)textView:(UITextView *)aTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
	// don't even try to process selections and cut/copy/paste, etc.
	if(range.length > 1) {
		lastChange = [text copy];
		return YES;
	}
	
	// prevent double-space turning into period-then-space
	if([text isEqualToString:@". "]) {
		lastChange = [text copy];
	}
	
	
	NSArray *brackets = [[[NSArray alloc] initWithObjects:@"{}",@"()",@"[]",@"\"\"",@"''",nil] autorelease];
	for(NSString *bracket in brackets) {
		// auto-complete brackets
		if([text isEqualToString:[bracket substringToIndex:1]]) {
			NSMutableString *body = [textView.text mutableCopy];
			[body insertString:bracket atIndex:range.location];
			textView.text = body;
			
			int newRange = range.location + 1;
			textView.selectedRange = NSRangeFromString([NSString stringWithFormat:@"%i",newRange]);
			
			lastChange = [text copy];
            [body release];
			return NO;
		}
		
		// if bracket is deleted, remove auto-completed closing bracket
		if([text isEqualToString:@""] && [lastChange isEqualToString:[bracket substringToIndex:1]]) {
			NSMutableString *body = [textView.text mutableCopy];
			[body deleteCharactersInRange:NSRangeFromString([NSString stringWithFormat:@"%i 2",range.location])];
			textView.text = body;
			
			textView.selectedRange = NSRangeFromString([NSString stringWithFormat:@"%i",range.location]);
			
			lastChange = [text copy];
            [body release];
			return NO;
		}
	}
	
	// if we're inserting a newline, try to also add some indentation
	if([text isEqualToString:@"\n"]) {
		// don't add indentation when adding a newline adjacent to another newline
		if([textView.text characterAtIndex:range.location-1] == '\n') {
			lastChange = [text copy];
			return YES;
		}
		
		int numSpaces = 0;
		
		// working backwards from the point of insertion...
		for(int i=range.location-1;i>=0;i--) {
			// if we find a newline...
			if([textView.text characterAtIndex:i] == '\n') {
				// test the next character. if it's a space, increment numSpaces. repeat until false.
				// the first part is to prevent us running off the edge of a cliff. the second actually checks that the char is a space.
				while ([textView.text length] > i+numSpaces+1 && [textView.text characterAtIndex:i+numSpaces+1] == ' ') {
					numSpaces++;
				}
				break;
			}
		}
		
		// now, add the newline and indentation manually, set the cursor position, and return no.
		NSMutableString *insertion = [@"\n" mutableCopy];
		for(int i=0;i<numSpaces;i++)
			[insertion appendString:@" "];
        
		NSMutableString *body = [textView.text mutableCopy];
		[body insertString:insertion atIndex:range.location];
		textView.text = body;
		[body release];
        
		// NSRangeFromString seems really bizarre- why make a range from a string rather than ints?
		int newRange = range.location + [insertion length];
		textView.selectedRange = NSRangeFromString([NSString stringWithFormat:@"%i",newRange]);
		
        [insertion release];
        
		lastChange = [text copy];
        return NO;
	}
	
	// nothing special happening here.
	lastChange = [text copy];
	return YES;
}

#pragma mark -
#pragma mark Text view resizing (on keyboard show/hide)

-(void)keyboardWillShow:(NSNotification *)note {
	keyboardVisible = YES;
	
	NSInteger offset;
	if(LANDSCAPE)
		offset = 355;
	else
		offset = 265;
	textView.frame = CGRectMake(textView.frame.origin.x, textView.frame.origin.y, textView.frame.size.width, textView.frame.size.height - offset);
}

-(void)keyboardWillHide:(NSNotification *)note {
	keyboardVisible = NO;
	
	NSInteger offset;
	if(LANDSCAPE)
		offset = 355;
	else
		offset = 265;
	textView.frame = CGRectMake(textView.frame.origin.x, textView.frame.origin.y, textView.frame.size.width, textView.frame.size.height + offset);
}

#pragma mark -
#pragma mark Running code

-(void)runCode {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if(![defaults boolForKey:@"acceptedCodepad"]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Run Code" 
														message:@"Your code will be uploaded to the internet and executed through codepad.org. Code that attempts to access the filesystem or network, or that runs for longer than a few seconds may fail." 
													   delegate:self
											  cancelButtonTitle:@"Never mind." 
											  otherButtonTitles:@"Continue!",nil];
		[alert show];
		[alert release];
		return;
	}
	
	Program *program = (Program *)(self.detailItem);
	program.executionDelegate = self;
	[program beginExecution];
	
	UIToolbar *toolbar = (UIToolbar *)[self.navigationItem.rightBarButtonItem customView];
	
	NSMutableArray *toolbarItems = [toolbar.items mutableCopy];
	UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	[spinner startAnimating];
	spinner.frame = CGRectMake(0, 0, 15, 15);
	UIBarButtonItem *spinnerItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
	[toolbarItems replaceObjectAtIndex:[toolbarItems count]-1 withObject:spinnerItem];
	[spinner release];
	[spinnerItem release];
	
	[toolbar setItems:toolbarItems animated:YES];
    
    [toolbarItems release];
}

-(void)executionDidFinishWithResult:(NSString *)result {
	ResultViewController *resultVC = [[ResultViewController alloc] initWithNibName:@"ResultViewController" bundle:nil];
	
	resultVC.modalPresentationStyle = UIModalPresentationPageSheet;
	resultVC.result = result;
	
	[self presentModalViewController:resultVC animated:YES];
	[resultVC release];
	
	[self configureView]; // reset the toolbar
}

-(void)executionDidFinishWithError:(NSString *)result {
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:result delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alertView show];
	[alertView release];
	
	[self configureView]; // reset the toolbar
}

#pragma mark -
#pragma mark Sending code

-(void)email {
    MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
    [controller setSubject:[detailItem valueForKey:@"title"]];
    
    NSData *data = [[detailItem valueForKey:@"code"] dataUsingEncoding:NSUTF8StringEncoding];
    [controller addAttachmentData:data 
                         mimeType:@"text/plain" 
                         fileName:[NSString stringWithFormat:@"%@.%@",[detailItem valueForKey:@"title"],[[self class] extensionForLanguage:[detailItem valueForKey:@"language"]]]];
    
    [self presentModalViewController:controller animated:YES];
    controller.mailComposeDelegate = self;
    [controller release];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self dismissModalViewControllerAnimated:YES];
}

+(NSString *)extensionForLanguage:(NSString *)language {
    if([language isEqualToString:@"C"])
        return @"c";
    if([language isEqualToString:@"C++"])
        return @"cpp";
    if([language isEqualToString:@"D"])
        return @"d";
    if([language isEqualToString:@"Haskell"])
        return @"hs";
    if([language isEqualToString:@"Lua"])
        return @"lua";
    if([language isEqualToString:@"OCaml"])
        return @"ml";
    if([language isEqualToString:@"PHP"])
        return @"php";
    if([language isEqualToString:@"Perl"])
        return @"pl";
    if([language isEqualToString:@"Python"])
        return @"py";
    if([language isEqualToString:@"Ruby"])
        return @"rb";
    if([language isEqualToString:@"Scheme"])
        return @"ss";
    if([language isEqualToString:@"Tcl"])
        return @"tcl";
    
    return @"txt";
}

#pragma mark -
#pragma mark Alert view delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(buttonIndex == 1) { // "Continue" button
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setBool:YES forKey:@"acceptedCodepad"];
		[self runCode];
	}
}

#pragma mark -
#pragma mark Managing the detail item

/*
 When setting the detail item, update the view and dismiss the popover controller if it's showing.
 */
- (void)setDetailItem:(NSManagedObject *)managedObject {
    
	if (detailItem != managedObject) {
		[detailItem release];
		detailItem = [managedObject retain];
		
        [self configureView];
	}
    
	// if it's nil, of course, this does nothing
	[popoverController dismissPopoverAnimated:YES];
}


- (void)configureView {
	if(detailItem) {
		self.textView.text = [detailItem valueForKey:@"code"];
		self.textView.editable = YES;
		
		self.navigationItem.title = [detailItem valueForKey:@"title"];
		
		UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 70, 44)];
		[toolbar setTintColor:[UIColor darkGrayColor]];
		
        UIBarButtonItem *space = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
		UIBarButtonItem *play = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(runCode)] autorelease];
        UIBarButtonItem *space2 = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil] autorelease];
		UIBarButtonItem *email = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(email)] autorelease];
        space2.width = 7.0f;
        
		toolbar.items = [NSArray arrayWithObjects:space,email,space2,play,nil];
        
		UIBarButtonItem *toolbarItem = [[UIBarButtonItem alloc] initWithCustomView:toolbar];
		self.navigationItem.rightBarButtonItem = toolbarItem;
		[toolbar release];
		[toolbarItem release];
		
	} else {
		self.textView.text = @"";
		self.textView.editable = NO;
		
		self.navigationItem.title = @"";
		self.navigationItem.rightBarButtonItem = nil;
	}
}


#pragma mark -
#pragma mark Split view support

- (void)splitViewController: (UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController: (UIPopoverController*)pc {
    
	
	barButtonItem.title = @"Programs";
    self.navigationItem.leftBarButtonItem = barButtonItem;
    self.popoverController = pc;
}


// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController: (UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    
    self.navigationItem.leftBarButtonItem = nil;
    self.popoverController = nil;
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
	self.popoverController = nil;
	self.textView = nil;
	self.detailItem = nil;
	
	[super dealloc];
}	


@end
