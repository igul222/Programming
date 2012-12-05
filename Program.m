//
//  Program.m
//  Programming
//
//  Created by Ishaan Gulrajani on 4/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ASIFormDataRequest.h"
#import "TFHpple.h"
#import "Reachability.h"
#import "NSString+IGExtensions.h"

#import "Program.h"

@implementation Program
@synthesize executionDelegate;

-(void)beginExecution {
	[self performSelectorInBackground:@selector(execute) withObject:nil];
}

-(void)execute {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	// first, check that the connection is up!
	if([[Reachability reachabilityWithHostName:@"codepad.org"] currentReachabilityStatus] == NotReachable) {
		if([self.executionDelegate respondsToSelector:@selector(executionDidFinishWithError:)]) {
			[self.executionDelegate performSelectorOnMainThread:@selector(executionDidFinishWithError:) 
													 withObject:@"An internet connection is required to run code. Please check your connection and try again." 
												  waitUntilDone:NO];
		}
		
		return;
	}
	
	
	NSURL *url = [NSURL URLWithString:@"http://codepad.org/"];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	[request setPostValue:self.code forKey:@"code"];
	[request setPostValue:self.language forKey:@"lang"];
	[request setPostValue:@"True" forKey:@"private"];
	[request setPostValue:@"True" forKey:@"run"];
	
	[request setTimeOutSeconds:30.0f];
	[request startSynchronous];
	
	NSError *error = [request error];
	if (!error) {
		NSString *response = [request responseString];
		
		TFHpple *doc = [[TFHpple alloc] initWithHTMLData:[response dataUsingEncoding:NSUTF8StringEncoding]];
		
		NSString *xpath = @"//div[contains(concat(\" \", @class, \" \"),concat(\" \", \"code\", \" \"))]//div[contains(concat(\" \", @class, \" \"),concat(\" \", \"highlight\", \" \"))]//pre";
		
		NSArray *elements = [doc search:xpath];
		//NSString *result = [elements description];
		NSString *result = [[elements lastObject] content];
		
		if([result isBlank])
			result = @"(empty result)";
		
		if(self.executionDelegate && [self.executionDelegate respondsToSelector:@selector(executionDidFinishWithResult:)]) {
			[self.executionDelegate performSelectorOnMainThread:@selector(executionDidFinishWithResult:) withObject:result waitUntilDone:NO];
		}
	
        [doc release];
    } else {
		if(self.executionDelegate && [self.executionDelegate respondsToSelector:@selector(executionDidFinishWithError:)]) {
			[self.executionDelegate performSelectorOnMainThread:@selector(executionDidFinishWithError:) withObject:[error description] waitUntilDone:NO];
		}
	}
	
	[pool release];
}


+(NSString *)defaultCodeForLanguage:(NSString *)lang {
	if([lang isEqualToString:@"C"])
		return @"int main() \n{\n  printf(\"Hello, world!\");\n  return 0;\n}";
	else if([lang isEqualToString:@"PHP"])
        return @"<?php\n\necho \"Hello, world!\"";
    else if([lang isEqualToString:@"Python"])
        return @"print \"Hello, world!\"";
    else if([lang isEqualToString:@"Ruby"])
        return @"puts \"Hello, world!\"";
    else
		return nil;
}

@end
