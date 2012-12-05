//
//  Program.h
//  Programming
//
//  Created by Ishaan Gulrajani on 4/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Program : NSManagedObject {
	NSObject *executionDelegate;
}
@property(nonatomic,assign) NSObject *executionDelegate;

-(void)beginExecution;

+(NSString *)defaultCodeForLanguage:(NSString *)lang;

@end


@interface Program (CoreDataGeneratedAccessors)

@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSString * language;

@end
