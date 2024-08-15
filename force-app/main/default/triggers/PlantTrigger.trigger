trigger PlantTrigger on CAMPX__Plant__c (before insert) {

    if(Trigger.isBefore){
        PlantTriggerHandler.plantsToUpdate(Trigger.new, Trigger.isInsert);
        
    }

}