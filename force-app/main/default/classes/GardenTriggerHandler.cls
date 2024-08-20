public with sharing class GardenTriggerHandler {

    public static void gardenBeforeInsert(List<CAMPX__Garden__c> gardenList){
        for(CAMPX__Garden__c garden : gardenList){
                handleInsertLogic(garden);
                if(garden.CAMPX__Manager__c != null){
                    garden.CAMPX__Manager_Start_Date__c = ManagerStartDate(garden);
                }
                
            }
        }
    
    public static void gardensBeforeUpdate (List<CAMPX__Garden__c> gardenList, Map<Id, CAMPX__Garden__c> oldGardenMap){
        List<Task> managerTaskList = new List<Task>();

        for(CAMPX__Garden__c garden : gardenList){
            String prevManagerId = oldGardenMap.get(garden.Id).CAMPX__Manager__c;
            if(garden.CAMPX__Manager__c != null && garden.CAMPX__Manager__c != prevManagerId){
                managerTaskList.add(generateManagerTask(garden, managerTaskList));
            }

            if(garden.CAMPX__Manager__c != prevManagerId){
                garden.CAMPX__Manager_Start_Date__c = ManagerStartDate(garden);
            }
        }     
    }

    public static void gardenAfterInsert (List<CAMPX__Garden__c> gardenList){
        List<Task> managerTaskList = new List<Task>();
        for(CAMPX__Garden__c garden : gardenList){
            if(garden.CAMPX__Manager__c != null){
                managerTaskList.add(generateManagerTask(garden, managerTaskList));
            } 
        }

        if(!managerTaskList.isEmpty()){
            if (Schema.sObjectType.Task.isCreateable()){
                insert managerTaskList;
            }  
        }
    }

    public static void gardenAfterUpdate (List<CAMPX__Garden__c> gardenList, Map<Id, CAMPX__Garden__c> oldGardenMap){
        List<Task> taskToReassignList = new List <Task>();
        List<Task> taskToDelete = new List<Task>();
        
        for(CAMPX__Garden__c garden : gardenList){
            String prevManagerId = oldGardenMap.get(garden.Id).CAMPX__Manager__c;
            if(garden.CAMPX__Manager__c != null && prevManagerId != null){
                if(garden.CAMPX__Manager__c != prevManagerId){
                    taskToReassignList.addAll(reassignManagerTasks(garden, prevManagerId));
                }
            }

            if(garden.CAMPX__Manager__c == null && prevManagerId != null){
                taskToDelete.addAll(getTaskToDelete(garden, prevManagerId));
                garden.CAMPX__Manager_Start_Date__c = ManagerStartDate(garden);
            }
        }

        if (Schema.sObjectType.Task.isUpdateable()){
            if(!taskToReassignList.isEmpty()){
                update taskToReassignList;     
            }
        } 

        if (Schema.sObjectType.Task.isDeletable()){
            if(!taskToDelete.isEmpty()){
                    delete taskToDelete;
            }
        } 
    }

    private static void handleInsertLogic(CAMPX__Garden__c garden){
        garden.CAMPX__Status__c = (garden.CAMPX__Status__c == null) ? 'Awaiting Resources': garden.CAMPX__Status__c;
        garden.CAMPX__Max_Plant_Count__c = (garden.CAMPX__Max_Plant_Count__c == null) ? 100 : garden.CAMPX__Max_Plant_Count__c;
        garden.CAMPX__Minimum_Plant_Count__c = (garden.CAMPX__Minimum_Plant_Count__c == null) ? 1 : garden.CAMPX__Minimum_Plant_Count__c;
        garden.CAMPX__Total_Plant_Count__c = (garden.CAMPX__Total_Plant_Count__c == null) ? 0 : garden.CAMPX__Total_Plant_Count__c;
        garden.CAMPX__Total_Unhealthy_Plant_Count__c = (garden.CAMPX__Total_Unhealthy_Plant_Count__c == null) ? 0 : garden.CAMPX__Total_Unhealthy_Plant_Count__c;
    }   

    private static Task generateManagerTask(CAMPX__Garden__c garden, List<Task> taskList){
            Task task = new Task();
            task.OwnerId = garden.CAMPX__Manager__c;
            task.Subject = 'Acquire Plants';
            task.WhatId = garden.Id;

            return task;
    }

    private static List<task> reassignManagerTasks (CAMPX__Garden__c garden, String prevManagerId){ 
        List<Task> reassignedTaskList = new List<Task>();
        list<Task> taskToReassign = [SELECT Id, OwnerId, subject, whatId 
                                    FROM Task 
                                    WHERE Subject = 'Acquire Plants' 
                                        AND WhatId = :garden.Id 
                                        AND OwnerId = :prevManagerId 
                                        AND status != 'Completed' WITH SECURITY_ENFORCED];

        for(Task task : taskToReassign){
            task.OwnerId = garden.CAMPX__Manager__c;
            reassignedTaskList.add(task);
        }

        return reassignedTaskList;
    }

    private static list<task> getTaskToDelete (CAMPX__Garden__c garden, String prevManagerId){
        List<Task> taskToDelete = [SELECT id, status, whatId, OwnerId
                                    FROM TASK
                                    WHERE Subject = 'Acquire Plants'
                                        AND WhatId = :garden.Id
                                        AND OwnerId = :prevManagerId
                                        AND status != 'Completed' WITH SECURITY_ENFORCED];

        return taskToDelete;
    }

    private static Date ManagerStartDate(CAMPX__Garden__c garden){
        if(CAMPX__Garden__c.CAMPX__Manager__c != null){
            garden.CAMPX__Manager_Start_Date__c = System.today();
        } else{
            garden.CAMPX__Manager_Start_Date__c = null;
        }

        return garden.CAMPX__Manager_Start_Date__c;
    }
}