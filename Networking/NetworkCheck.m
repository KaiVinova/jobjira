//
//  NetworkCheck.m
//  Floyd
//
//  Created by Ankit Tyagi on 16/11/16.
//  Copyright © 2016 BrainMobi. All rights reserved.
//

#import "NetworkCheck.h"

@implementation NetworkCheck
+(bool)isNetworkAvailable
    {
        SCNetworkReachabilityFlags flags;
        SCNetworkReachabilityRef address;
        address = SCNetworkReachabilityCreateWithName(NULL, "www.apple.com" );
        Boolean success = SCNetworkReachabilityGetFlags(address, &flags);
        CFRelease(address);
        
        bool canReach = success
        && !(flags & kSCNetworkReachabilityFlagsConnectionRequired)
        && (flags & kSCNetworkReachabilityFlagsReachable);
        
        return canReach;
    }
@end
