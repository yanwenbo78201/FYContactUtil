//
//  FYViewController.m
//  FYContactUtil
//
//  Created by Computer on 01/07/2026.
//  Copyright (c) 2026 Computer. All rights reserved.
//

#import "FYViewController.h"
#import "FYContactUtil.h"

@interface FYViewController ()

@end

@implementation FYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    FYContactUtil *contactUtil = [[FYContactUtil alloc] init];
    [contactUtil requestContactsAuthorization:NO completion:^(BOOL result, FYContactsAuthStatus status, BOOL alertShow) {
        
        NSLog(@"结果--%ld---状态%ld---展示提示框%ld",result,status,alertShow);
                
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
