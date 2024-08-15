public with sharing class PlantTriggerHandler {
    
    public static void plantsToUpdate(List<CAMPX__Plant__c> plantList, Boolean isInsert){
        for(CAMPX__Plant__c plant : plantList){
            if(isInsert){
                handleInsertLogic(plant);
            }
        }     
    }

    public static void handleInsertLogic(CAMPX__Plant__c plant){
        plant.CAMPX__Soil_Type__c = (plant.CAMPX__Soil_Type__c == null) ? 'All Purpose Potting Soil' : plant.CAMPX__Soil_Type__c;
        plant.CAMPX__Water__c = (plant.CAMPX__Water__c == null) ? 'Once Weekly' : plant.CAMPX__Water__c;

        if(plant.CAMPX__Garden__c != null){
            List <CAMPX__Garden__c> gardenList = [SELECT id, CAMPX__Sun_Exposure__c FROM CAMPX__Garden__c WHERE Id = :plant.CAMPX__Garden__c LIMIT 1];
            CAMPX__Garden__c relatedGarden = gardenList[0];
            
            if(relatedGarden != null){
                plant.CAMPX__Sunlight__c = (relatedGarden.CAMPX__Sun_Exposure__c != null ? relatedGarden.CAMPX__Sun_Exposure__c : 'Partial Sun'); 
            }
        } else{
            plant.CAMPX__Sunlight__c = 'Partial Sun';
        } 
    }
}