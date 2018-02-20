//
//  AkAsyncQueue.swift
//  test1
//
//  Created by AaronZhang on 2018/2/13.
//  Copyright © 2018 Aaron Zhang. All rights reserved.
//

import UIKit

class AssociatedId
{
    var id = 0;
}

class AkAsyncTask {
    var task:((_ taskITem:AkAsyncTask) -> Swift.Void)?;
    
    var taskId = 0;
    var associatedId:AssociatedId?;
    
    // determine how many tasks can be run in one loop
    var taskWeight = 100;
    
    // limit repeat times
    var repeateTime = 1;
    
    init(associatedId:AssociatedId?, taskWeight:Int = 100, repeateTime:Int = 1, task:((_ taskITem:AkAsyncTask) -> Swift.Void)?) {
        self.associatedId = associatedId;
        taskId = associatedId?.id ?? 0
        self.taskWeight = taskWeight;
        self.repeateTime = repeateTime;
        self.task = task;
    }
}

class AkAsyncQueue: NSObject {
    
    var maxTaskWeight = 100;
    var tasks = [AkAsyncTask]()
    
    public func Start()
    {
    }
    
    public func Stop()
    {
        
    }
    
    // Add a task to list
    public func AddTask(associatedId:AssociatedId? = nil, taskWeight:Int = 0, repeateTime:Int = 1, task:@escaping ((_ taskITem:AkAsyncTask) -> Swift.Void))
    {
        tasks.append(AkAsyncTask.init(associatedId: associatedId, taskWeight: taskWeight, repeateTime: repeateTime, task: task))
        Start();
    }
    
    public func RemoveTask(id:Int)
    {
        for var index in 0...tasks.count {
            let task = tasks[index]
            if task.associatedId?.id == id
            {
                tasks.remove(at: index);
                index -= 1;
            }
        }
    }

    public func ProcessTask()
    {
        var curTaskWeightOnLoop = 0;
        var index = 0
        while self.tasks.count > index {
            let taskItem = self.tasks[index]
            if taskItem.repeateTime > 0
            {
                taskItem.repeateTime -= 1;
            }
            if taskItem.repeateTime == 0
            {
                self.tasks.remove(at: index)
            }
            else
            {
                index += 1;
            }
            
            // Determine whether this task is abandon
            if taskItem.associatedId == nil || taskItem.associatedId?.id == taskItem.taskId
            {
                taskItem.task!(taskItem);
                curTaskWeightOnLoop += taskItem.taskWeight;
                if curTaskWeightOnLoop >= self.maxTaskWeight {
                    break;
                }
            }
        }
    }
}
