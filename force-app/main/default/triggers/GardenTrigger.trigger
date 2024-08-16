trigger GardenTrigger on CAMPX__Garden__c (before insert, before update, after insert, after update) {

    if(Trigger.isBefore){
        if(Trigger.isInsert){
            GardenTriggerHandler.gardenBeforeInsert(Trigger.new);
        }

        if(Trigger.isUpdate){
            GardenTriggerHandler.gardensBeforeUpdate(Trigger.new, Trigger.oldMap);
        }
        
    }

    if(Trigger.isAfter){
        if(Trigger.isInsert){
            GardenTriggerHandler.gardenAfterInsert(Trigger.new);
        }

        if(Trigger.isUpdate){
            GardenTriggerHandler.gardenAfterUpdate(Trigger.new, Trigger.oldMap);
        }
        
    }
}