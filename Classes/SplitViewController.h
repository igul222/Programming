//
//  SplitViewController.h
//  Programming
//
//  Created by Ishaan Gulrajani on 4/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RootViewController;
@class DetailViewController;

@interface SplitViewController : UISplitViewController {

}
@property(nonatomic,readonly) RootViewController *rootViewController;
@property(nonatomic,readonly) DetailViewController *detailViewController;

@end
