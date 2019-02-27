//
//  NetworkCheck.h
//  Floyd
//
//  Created by Ankit Tyagi on 16/11/16.
//  Copyright © 2016 BrainMobi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SCNetworkReachability.h>

@interface NetworkCheck : NSObject
+(bool)isNetworkAvailable;
@end
