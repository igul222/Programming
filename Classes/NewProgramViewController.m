//
//  NewProgramViewController.m
//  Programming
//
//  Created by Ishaan Gulrajani on 4/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSString+IGExtensions.h"

#import "NewProgramViewController.h"

#import "Program.h"

@implementation NewProgramViewController
@synthesize managedObjectContext;

-(void)configure {
	[self setTitle:@"New Program"];
	
	
	[self addSectionWithTitle:@"Title"];
		[self addTextField:@"Title"];
	
	[self addSectionWithTitle:@"Language"];
		[self addRadioOption:@"Language" title:@"C"];
		[self addRadioOption:@"Language" title:@"C++"];
		[self addRadioOption:@"Language" title:@"D"];
		[self addRadioOption:@"Language" title:@"Haskell"];
		[self addRadioOption:@"Language" title:@"Lua"];
		[self addRadioOption:@"Language" title:@"OCaml"];
		[self addRadioOption:@"Language" title:@"PHP"];
		[self addRadioOption:@"Language" title:@"Perl"];
		[self addRadioOption:@"Language" title:@"Python"];
		[self addRadioOption:@"Language" title:@"Ruby"];
		[self addRadioOption:@"Language" title:@"Scheme"];
		[self addRadioOption:@"Language" title:@"Tcl"];

}

-(NSString *)validateData:(NSDictionary *)formData {
	if([[formData objectForKey:@"Title"] isBlank])
		return @"Title can't be blank.";
	else if(![formData objectForKey:@"Language"])
		return @"You must select a language.";
	else
		return nil; // valid
}

-(void)saveData:(NSDictionary *)formData {
	NSManagedObject *program = [NSEntityDescription insertNewObjectForEntityForName:@"Program" inManagedObjectContext:managedObjectContext];
	[program setValue:[formData objectForKey:@"Title"] forKey:@"title"];
	[program setValue:[formData objectForKey:@"Language"] forKey:@"language"];
	
	NSString *defaultCode = [Program defaultCodeForLanguage:[formData objectForKey:@"Language"]];
	[program setValue:defaultCode forKey:@"code"];
}

-(void)dealloc {
	self.managedObjectContext = nil;
	[super dealloc];
}

@end

