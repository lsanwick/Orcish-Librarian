//
//  NSNull+Wrap.m
//  Orcish Librarian
//
//  Created by Stewart Ulm on 3/30/12.
//  Copyright (c) 2012 Orcish. All rights reserved.
//

#import "NSNull+Wrap.h"

@implementation NSNull (Wrap)

// ----------------------------------------------------------------------------

+ (id) wrapNil:(id)obj {
    return (obj == nil ? [NSNull null] : obj);
}

// ----------------------------------------------------------------------------

@end
