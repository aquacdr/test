public with sharing class ManagePortalUserProfileController {
   
/****
Shows a list of Accounts
Choosing an Account, will list all Contacts in that Account
Choosing the Contact, Profile & Role will create a Portal User associated to that selected Contact.

Requirement - The Account should have a default Portal user created already , so that the Role will be auto created 

***/    
    public List<Contact> selectedUsers{get;set;}
    public List<User> UpdatedUsers{get;set;}
    public List<UserWrapper> userWrapperList{get;set;}
    public List<UserWrapper> resultUserList{get;set;}
    public String selectedProfile{get;set;}
    public String selectedAccount{get;set;}
    public String selectedRole{get;set;}
    public ApexPages.StandardSetController setcon{get;set;}
    public Contact MainContact{get;set;}
    
    /*  This would refer to the standard set controller which controls the display of the list records displayed 
        as a result of list view selected on the UI
    */
    public ManagePortalUserProfileController(ApexPages.StandardSetController controller){
        setcon=controller;
        MainContact = new Contact();
        UpdatedUsers = new List<User>();
        showUsers();
        selectedUsers=new List<Contact>();
        resultUserList=new List<UserWrapper>();
        
    }
    
    /*This refers to generating select options for all the Profiles present in the org*/
    public List<SelectOption> getOptions(){
    
        List<Profile> profileList=[select id,name from Profile where name like '%Portal%' order by Name];
        List<SelectOption> options = new List<SelectOption>();
        for(Profile profObj:profileList){
            options.add(new SelectOption(profObj.Id,profObj.Name));
        }
        return options;
    }
    
    /*This refers to generating select options for all the Accounts present in the org*/    
    public List<SelectOption> getAccounts(){
    List<Account> AccountList = [Select id,name from Account order by Name];
        List<SelectOption> Accountoptions = new List<SelectOption>();
            Accountoptions.add(new SelectOption('0','None'));
        for(Account Acc:AccountList){
            Accountoptions.add(new SelectOption(Acc.Id,Acc.Name));
        }
        return Accountoptions;
    
    }
    
/*This refers to generating select options for all the Roles present in the org*/    
     public List<SelectOption> getRoleOptions(){
    
        List<UserRole> RoleList=[SELECT Name, Id FROM UserRole where PortalAccountId =: MainContact.accountid 
        order by Name];
        List<SelectOption> Roleoptions = new List<SelectOption>();
        for(UserRole role:RoleList){
            Roleoptions.add(new SelectOption(role.Id,role.Name));
        }
        return Roleoptions;
    }
    
    /*This refers to display of Contact List results from the Account selected in the list view*/
    public void showUsers(){
        
        if(resultUserList!=null && resultUserList.size() > 0)
            resultUserList.clear();
        if(selectedUsers!=null && selectedUsers.size() > 0)
            selectedUsers.clear();
        userWrapperList=new List<UserWrapper>();
        List<Contact> userList=[Select Id,Name,Firstname, 
                                Email,
                                AccountId,CreatedById, 
                                CreatedDate, LastModifiedDate, 
                                LastModifiedById,LastName 
                                from Contact where AccountId=: MainContact.accountid];
        for(Contact u:userList){
            userWrapperList.add(new UserWrapper(u));    
        }
        
    }
    
    /*This would consist of all the selected Contacts who needs portal Access */
    public PageReference getSelected()
    {   
        selectedUsers.clear();
        for(UserWrapper userWrapperObj : userWrapperList)
            if(userWrapperObj.selected)
                selectedUsers.add(userWrapperObj.userObj);
        return null;
    }
    
    /*This method would create Portal User for selected Contact.
     This would be invoked on click of Update Profile button on UI*/
    public void updateUserProfile(){
    
        resultUserList.clear(); 
       
        if(selectedUsers!=null && selectedUsers.size() < 1){
           // ApexPages.Message warnMsg = new ApexPages.Message(ApexPages.severity.Warning,Label.Warning_Message);
           // ApexPages.addMessage(warnMsg);
        }else{
            if(selectedProfile!=null && selectedProfile!='')
            {
            Map<Id,Contact> contact_Map = new Map<Id,Contact>();
                for(Contact c : selectedUsers) {
                    User u = new User();
                    u.IsActive = true;
                    u.Email = c.Email;
                    u.Username = c.Email;                    
                    u.ProfileId = selectedProfile;
                    u.UserRoleId = selectedRole;
                    u.ContactId = c.Id;
                    u.LastName = c.LastName;
                    u.Alias = c.LastName.Substring(1,4);
                    u.TimeZoneSidKey = 'America/Los_Angeles'; 
                    u.LocaleSidKey = 'en_US';
                    u.EmailEncodingKey = 'ISO-8859-1';
                    u.LanguageLocaleKey = 'en_US';
                    UpdatedUsers.add(u);
                    contact_Map.put(c.Id,c);
                    
                }
                System.debug('This is selectedprofile: ' + selectedProfile);
                System.debug('This is the to-be updated: ' + UpdatedUsers);
                
                List<Database.SaveResult> srList=Database.insert(UpdatedUsers,false);
                 if(!test.isRunningTest())//Skip the reset process for test classes 
                    setcon.reset();
                List<Integer> failedRecordsIndexes=new List<Integer>();
                integer i=0;
                for(Database.Saveresult sr:srList){
                    Contact C_Result=contact_Map.get(UpdatedUsers.get(i).ContactId);
                    UserWrapper newUserWrapper=new UserWrapper(C_Result);
                    if(sr.getId()==null){
                        newUserWrapper.errorMsg=sr.getErrors().get(0).message;
                        newUserWrapper.isError=true;
                    }else{
                       // newUserWrapper.errorMsg=Label.Profile_Success;
                        
                    }
                    resultUserList.add(newUserWrapper);
                    i++;
                }
                
            }
        }
    }
    
    /*This refers to the wrapper class for Contact object which also has the capabilities of storing which Contact is selected,
    whats the error/succcess on update operation and whether the update profile operation on a partciular Contact really resulted in Error or Not*/
    public class UserWrapper
    {
        public Contact userObj{get; set;}
        public Boolean selected {get; set;}
        public String errorMsg{get;set;}
        public boolean isError{get;set;}
        public String ContactID {get; set;}
        public String ContactName {get; set;}
        
        public UserWrapper(Contact c)
        {
            ContactName = c.Name;
            ContactID = c.Id;
            userObj=c;
            selected = false;
            errorMsg='';
            isError=false;
        }
    }
    
       
    
}