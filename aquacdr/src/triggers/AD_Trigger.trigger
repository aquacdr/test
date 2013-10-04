/****************************************************************************************
      Name    : AD_Trigger
      Author  : Mohit Sahu
      Date    : 04/24/2012 
      Purpose : To enable/disable the login ability for all Portal users associated with an Account
      			To Remove User from Teams when De-activating 
      Objects : Account (Portal Status field)
      Helper  : AD_Helper.cls
      
      ========================
      = MODIFICATION HISTORY =
      ========================
      DATE        AUTHOR               CHANGE
      ----        ------               ------
       
*****************************************************************************************/

//Bulkifying the trigger to support both operation i.e. Activate and De-activate on various Account at one time
trigger AD_Trigger on Account (after update) {
	
	//set for Account Ids whose Portal Status is changed to Inactive
	Set<Id> accountIdsInactivePortal	= new Set<Id>();	
	//set for Account Ids whose Portal Status is changed to Active
	Set<Id> accountIdsActivePortal	= new Set<Id>();
	
	//Loop through all Accounts in the Trigger.new collection
	String newValue = '';
	String oldValue = '';
	for(Account a: Trigger.new){
		
		//to escape from NullPointerException when someone does not select Active or Inactive from Picklist
		if(Trigger.newMap.get(a.Id).Portal_Status__c == null){
			newValue = '';
		}else{
			newValue = Trigger.newMap.get(a.Id).Portal_Status__c;
		}	
		
		//to escape from NullPointerException when old value was None
		if(Trigger.oldMap.get(a.Id).Portal_Status__c == null){
			oldValue = '';
		}else{
			oldValue = Trigger.oldMap.get(a.Id).Portal_Status__c;
		}		
		//Check and compare new and old value of Portal status
		if(	!newValue.equalsIgnoreCase(oldValue)){
			//if new Portal Status is Inactive, add it to set of Inactive account ids
			if(newValue.equalsIgnoreCase('Inactive')){
				accountIdsInactivePortal.add(a.Id);
			}
			//if new Portal Status is Inactive, add it to set of Active account ids
			if(newValue.equalsIgnoreCase('Active')){
				accountIdsActivePortal.add(a.Id);
			}
		}	    
	}
	
	//check size of sets and call helper method to do actual things
	if(accountIdsInactivePortal.size() > 0){
		AD_Helper.help(accountIdsInactivePortal, false);
	}	
	//check size of sets and call helper method to do actual things
	if(accountIdsActivePortal.size() > 0){
		AD_Helper.help(accountIdsActivePortal, true);
	}
	
}