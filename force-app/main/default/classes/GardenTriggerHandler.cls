public with sharing class GardenTriggerHandler {

    public static void gardenBeforeInsert(List<CAMPX__Garden__c> gardenList, Map<Id, CAMPX__Garden__c> oldGardenMap){
        for(CAMPX__Garden__c garden : gardenList){
                handleInsertLogic(garden);
            }
        }
    
    public static void gardensBeforeUpdate (List<CAMPX__Garden__c> gardenList, Map<Id, CAMPX__Garden__c> oldGardenMap){
        List<Task> managerTaskList = new List<Task>();
        for(CAMPX__Garden__c garden : gardenList){
            if(garden.CAMPX__Manager__c != null && oldGardenMap.get(garden.Id).CAMPX__Manager__c != garden.CAMPX__Manager__c){
                managerTaskList.add(generateManagerTask(garden, managerTaskList));
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
        insert managerTaskList;   
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
}