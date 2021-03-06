//
//  MTTUsersStatAPI.m
//  TeamTalk
//
//  Created by scorpio on 15/7/20.
//  Copyright (c) 2015年 MoguIM. All rights reserved.
//

#import "MTTUsersStatAPI.h"
#import "ImBuddy.pbobjc.h"
#import "ImBaseDefine.pbobjc.h"

@implementation MTTUsersStatAPI
/**
 *  请求超时时间
 *
 *  @return 超时时间
 */
- (int)requestTimeOutTimeInterval
{
    return TimeOutTimeInterval;
}

/**
 *  请求的serviceID
 *
 *  @return 对应的serviceID
 */
- (int)requestServiceID
{
    return SID_BUDDY_LIST;
}

/**
 *  请求返回的serviceID
 *
 *  @return 对应的serviceID
 */
- (int)responseServiceID
{
    return SID_BUDDY_LIST;
}

/**
 *  请求的commendID
 *
 *  @return 对应的commendID
 */
- (int)requestCommendID
{
    return IM_USERS_STAT_REQ;
}

/**
 *  请求返回的commendID
 *
 *  @return 对应的commendID
 */
- (int)responseCommendID
{
    return IM_USERS_STAT_RSP;
}

/**
 *  解析数据的block
 *
 *  @return 解析数据的block
 */
- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSData* data)
    {
        IMUsersStatRsp *allUsersStatRsp = [IMUsersStatRsp parseFromData:data error:nil];
        NSMutableArray *array = [NSMutableArray new];
        NSMutableArray *userList = [NSMutableArray new];
        
        NSMutableArray *userStats = [allUsersStatRsp userStatListArray];
        for (UserStat *stat in userStats) {
            [userList addObject:@([stat userId])];
            [userList addObject:@([stat status])];
        }
        [array addObject:userList];
        return array;
    };
    return analysis;
}

/**
 *  打包数据的block
 *
 *  @return 打包数据的block
 */
- (Package)packageRequestObject
{
    Package package = (id)^(id object,uint16_t seqNo)
    {
        IMUsersStatReq *queryPush = [IMUsersStatReq new];
        NSArray* array = (NSArray*)object;
        //queryPush.userId = 0;
        [queryPush setUserId:0];
        GPBUInt32Array *gpbarray = [GPBUInt32Array new];
        for(NSNumber *number in array) {
            [gpbarray addValue:[number unsignedIntValue]];
        }
        [queryPush setUserIdListArray:gpbarray];
        DDDataOutputStream *dataout = [[DDDataOutputStream alloc] init];
        [dataout writeInt:0];
        [dataout writeTcpProtocolHeader:SID_BUDDY_LIST
                                    cId:IM_USERS_STAT_REQ
                                  seqNo:seqNo];
        [dataout directWriteBytes:[queryPush data]];
        [dataout writeDataCount];
        return [dataout toByteArray];
    };
    return package;
}

@end
