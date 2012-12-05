//
//  SplitViewController.m
//  Programming
//
//  Created by Ishaan Gulrajani on 4/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SplitViewController.h"
#import "RootViewController.h"

@implementation SplitViewController

#pragma mark -
#pragma mark Rotation

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	
	if((toInterfaceOrientation==UIInterfaceOrientationLandscapeLeft) ||(toInterfaceOrientation==UIInterfaceOrientationLandscapeRight)) {
		[self.rootViewController.navigationController.navigationBar setTintColor:[UIColor darkGrayColor]];
	}
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
	
	if((fromInterfaceOrientation==UIInterfaceOrientationLandscapeLeft) || (fromInterfaceOrientation==UIInterfaceOrientationLandscapeRight)) {
		[self.rootViewController.navigationController.navigationBar setTintColor:nil];
	}
}

#pragma mark -
#pragma mark Detail/root view controllers

-(RootViewController *)rootViewController {
	return [[[self.viewControllers objectAtIndex:0] viewControllers] objectAtIndex:0];
}

-(DetailViewController *)detailViewController {
	return [self.viewControllers objectAtIndex:1];	
}



@end
