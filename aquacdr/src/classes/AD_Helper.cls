/****************************************************************************************
      Name          :   AD_Helper
      Author        :   Mohit Sahu
      Date          :   04/24/2012 
      Purpose       :   To enable/disable the login ability for all Portal users associated with an Account
                        To Remove User from Teams when De-activating 
      Objects       :   User, AccountTeamMember, OpportunityTeamMember, CaseTeamTemplateMember, CaseTeamMember
      Trigger       :   AD_Trigger
      Custom Setting:   AD_Setting
      
      ========================
      = MODIFICATION HISTORY =
      ========================
      DATE        AUTHOR               CHANGE
      ----        ------               ------
       
*****************************************************************************************/

public with sharing class AD_Helper {
    
    /*
        Method to help trigger on Account object to do actual things 
        while changing the Account's Portal Status picklist
        @param  Set of Account Ids
        @param  Portal Status
    */
    public static void help(Set<Id> accountIds, Boolean portalStatus){      
        //savepoint to revert back to initial condition
        System.Savepoint start = Database.setSavepoint();
        //retreive Portal User Ids of Account Ids
        Set<Id> portalUserIds = retrievePortalUsers(accountIds);
        //if there are portal users associated with this account
        if(portalUserIds != null && portalUserIds.size() > 0){
            //Portal Status is Inactive than remove from teams
            if(!portalStatus){
             //   removeFormOpportunityTeamMember(portalUserIds, start);
             //   removeFormAccountTeamMember(portalUserIds, start);
             //   removeFormAdHocCaseTeamMember(portalUserIds, start);
            }
            //Remove from Predefined Case Team
            //Change Portal User IsActive flag based on portal status
            doFutureThings(portalUserIds, portalStatus);
        }        
    }
    
    
    /*
        Method to retrieve Portal User Ids of Account Ids
        @param  Set of Account Ids
        @return Set of Portal User Ids
    */
    public static Set<Id> retrievePortalUsers(Set<Id> accountIds){
        //collection to be returned of found Portal User Ids
        Set<Id> portalUserIds = new Set<Id>();
        try{
            //get the map of Portal Users for Account Ids
            Map<Id,User> portalUsers = 
                new Map<Id,User>(
                    [   select  IsActive 
                        from    User 
                        where   IsPortalEnabled = true 
                            and AccountId IN :accountIds]);
            //add map keys to collection
            portalUserIds.addAll(portalUsers.keySet());         
        }catch(Exception e){
            //in case of exception re-allocate collection to save NullPointerException
            portalUserIds = new Set<Id>();
        }
        //return found Portal User Ids
        return portalUserIds;
    }
    
    
    /*
        Method to remove Portal Users from Open and Closed Opportunity Team based on Custom Setting
        @param Set of Portal User Ids
        @param Savepoint to Rollback
    
    public static void removeFormOpportunityTeamMember(Set<Id> userIds, System.Savepoint start){
        //get the setting of "Remove user from sales teams of open opportunities"
        Boolean openOpportunityTeamSetting = Test.isRunningTest() ? true: AD_Setting__c.getValues('OpenOpportunityTeamSetting').Value__c;
        //get the setting of "Remove user from sales teams of closed opportunities"
        Boolean closedOpportunityTeamSetting    = Test.isRunningTest() ? true: AD_Setting__c.getValues('ClosedOpportunityTeamSetting').Value__c;
        
        try{
            //if "Remove user from sales teams of open opportunities" setting is true then 
            //delete records of Portal Users from OpportunityTeamMember where Opp. is Open
            if(openOpportunityTeamSetting){
                //remove
                Database.delete( 
                    [   select  Id 
                        from    OpportunityTeamMember
                        where   UserId IN:userIds
                            and Opportunity.IsClosed = false], true);  
            }
            //if "Remove user from sales teams of closed opportunities" setting is true then 
            //delete records of Portal Users from OpportunityTeamMember where Opp. is Closed
            if(closedOpportunityTeamSetting){
                Database.delete( 
                    [   select  Id 
                        from    OpportunityTeamMember
                        where   UserId IN:userIds
                            and Opportunity.IsClosed = true], true);
            }
        }catch(Exception e){
            //in case of exception Rollback to initial condition
            Database.rollback(start);
        }
    }
    */
    
    /*
        Method to remove Portal Users from Account Team based on Custom Setting
        @param Set of Portal User Ids
        @param Savepoint to Rollback
   
    public static void removeFormAccountTeamMember(Set<Id> userIds, System.Savepoint start){
        //get the setting of "Remove user from account teams"
        Boolean accountTeamSetting  = Test.isRunningTest() ? true: AD_Setting__c.getValues('AccountTeamSetting').Value__c;
        try{
            //if "Remove user from account teams" setting is true then 
            //delete records of Portal Users from AccountTeamMember
            if(accountTeamSetting){
                Database.delete( 
                    [   select  Id 
                        from    AccountTeamMember  
                        where   UserId IN:userIds], true); 
            }
        }catch(Exception e){
            //in case of exception Rollback to initial condition
            Database.rollback(start);
        }
    }
     */
    
    /*
        Method to remove Portal Users from Predefined and Ad Hoc Case Teams based on Custom Setting
        @param Set of Portal User Ids
        @param Savepoint to Rollback
  
    public static void removeFormAdHocCaseTeamMember(Set<Id> userIds, System.Savepoint start){
        //get the setting of "Remove user from ad hoc case teams"
        Boolean adHocCaseTeamSetting        = Test.isRunningTest() ? true: AD_Setting__c.getValues('AdHocCaseTeamSetting').Value__c;
        try{
            //if "Remove user from ad hoc case teams" setting is true then 
            //delete records of Portal Users from CaseTeamMember
            if(adHocCaseTeamSetting){
                Database.delete( 
                    [   select  Id 
                        from    CaseTeamMember 
                        where   MemberId IN:userIds], true);
            }
            
        }catch(Exception e){
            //in case of exception Rollback to initial condition
            Database.rollback(start);
        }
    }    
      */
    
    /*
        Future method to do future things
        @param  Set of Portal User Ids
        @param  Portal Status
    */ 
    @future
    public static void doFutureThings(Set<Id> portalUserIds, Boolean portalStatus){
    	//removeFormPredefinedCaseTeamMember(portalUserIds, portalStatus);
    	changePortalUserStatus(portalUserIds, portalStatus);
    }
    
    /*
        Future method to remove Portal Users from Predefined Case Teams
        Since, Predefined Case Team i.e. CaseTeamTemplateMember is a SetUp Object
        This uses @future since Mixed DML operations for standard objects (Account) and Setup objects(User) are not allowed
        @param  Set of Portal User Ids
        @param  Portal Status
    
    public static void removeFormPredefinedCaseTeamMember(Set<Id> portalUserIds, Boolean portalStatus){
    	//if Portal Status is inactive then remove from Predefined Case team
    	if(!portalStatus){
	    	//get the setting of "Remove user from predefined case teams"
	        Boolean predefinedCaseTeamSetting   = Test.isRunningTest() ? true: AD_Setting__c.getValues('PredefinedCaseTeamSetting').Value__c;
	        //if "Remove user from predefined case teams" setting is true then 
	        //delete records of Portal Users from CaseTeamTemplateMember
	        if(predefinedCaseTeamSetting){
	        	Database.delete( 
	                [   select  Id 
	                    from    CaseTeamTemplateMember 
	                    where   MemberId IN:portalUserIds], true);
	        } 
    	}       
    }
    */ 
    /*
        Future method to Activate or De-activate User Ids and supplied
        Since, User is a SetUp Object
        This uses @future since Mixed DML operations for standard objects (Account) and Setup objects(User) are not allowed
        @param  Set of Portal User Ids
        @param  Portal Status
    */ 
    public static void changePortalUserStatus(Set<Id> portalUserIds, Boolean portalStatus){         
        //list to store user records to de-activate 
        List<User> portalUsersToUpdate = new List<User>();
        //loop over users and change the IsActive checkbox and add to list
        for(User u : [select IsActive from User where Id IN:portalUserIds]){
            u.IsActive = portalStatus;
            portalUsersToUpdate.add(u);
        }
        //update users
        Database.update(portalUsersToUpdate, true);        
    }
}