//
//  NewProgramViewController.h
//  Programming
//
//  Created by Ishaan Gulrajani on 4/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "IGFormViewController.h"

@interface NewProgramViewController : IGFormViewController {
	NSManagedObjectContext *managedObjectContext;
}
@property(nonatomic,retain) NSManagedObjectContext *managedObjectContext;

@end
