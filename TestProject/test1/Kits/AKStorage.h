//
//  AKStorage.h
//  test1
//
//  Created by MacJenkins on 16/02/2018.
//  Copyright © 2018 Aaron Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AKStorage : NSObject
@property (strong, atomic) NSSet* itemList;
-(instancetype)init;
@end
