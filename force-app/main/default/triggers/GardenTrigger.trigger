trigger GardenTrigger on CAMPX__Garden__c (before insert, before update, after insert, after update) {

    if(Trigger.isBefore){
        if(Trigger.isInsert){
            GardenTriggerHandler.gardenBeforeInsert(Trigger.new, Trigger.oldMap);
        }

        If(Trigger.isUpdate){
            GardenTriggerHandler.gardensBeforeUpdate(Trigger.new, Trigger.oldMap);
        }
        
    }

    if(Trigger.isAfter){
        GardenTriggerHandler.gardenAfterInsert(Trigger.new);
    }
}