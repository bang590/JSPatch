//
//  internal.h
//  ETSummnor
//
//  Created by chaoran on 16/5/25.
//  Copyright © 2016年 chaoran. All rights reserved.
//

#ifndef internal_h
#define internal_h


#ifdef __arm64__

#include "internal_arm64.h"


#endif
#ifdef __i386__

#include <internal_i386.h>


#endif
#ifdef __arm__

#include "internal_arm.h"


#endif
#ifdef __x86_64__

#include "internal_x86_64.h"


#endif



#endif /* internal_h */
