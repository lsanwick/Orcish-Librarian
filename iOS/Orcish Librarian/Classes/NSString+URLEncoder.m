//
//  NSString+URLEncoder.m
//  Orcish Librarian
//
//  Created by Stewart Ulm on 5/19/12.
//  Copyright (c) 2012 Orcish. All rights reserved.
//

#import "NSString+URLEncoder.h"

@implementation NSString (URLEncoder)

// ----------------------------------------------------------------------------

- (NSString *) stringByEncodingForURL {
    return [[self stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
            
}

// ----------------------------------------------------------------------------

@end
