//
//  Utility.m
//  Orcish Librarian
//
//  Created by Stewart Ulm on 10/22/11.
//  Copyright (c) 2011 Orcish. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utility.h"

// ----------------------------------------------------------------------------
/*
UIColor *colorWithHexString(NSString *hexString) {  	
    if ([hexString hasPrefix:@"#"]) { 
        hexString = [hexString substringFromIndex:1]; 
    }    
    NSRange range; 
	range.location = 0; 
	range.length = 2;
    NSString *rString = [hexString substringWithRange:range];  
	range.location = 2;
    NSString *gString = [hexString substringWithRange:range];  
    range.location = 4;  
    NSString *bString = [hexString substringWithRange:range];
    NSUInteger r, g, b;  
    [[NSScanner scannerWithString:rString] scanHexInt:&r];  
    [[NSScanner scannerWithString:gString] scanHexInt:&g];  
    [[NSScanner scannerWithString:bString] scanHexInt:&b];      
    return [UIColor colorWithRed:((float) r / 255.0f)  
        green:((float) g / 255.0f)  
        blue:((float) b / 255.0f)  
        alpha:1.0f];  
}  
*/
// ----------------------------------------------------------------------------