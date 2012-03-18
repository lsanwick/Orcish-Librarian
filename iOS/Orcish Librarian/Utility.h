//
//  Utility.h
//  Orcish Librarian
//
//  Created by Stewart Ulm on 10/22/11.
//  Copyright (c) 2011 Orcish. All rights reserved.
//

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
