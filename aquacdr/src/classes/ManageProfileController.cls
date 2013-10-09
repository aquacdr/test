public with sharing class ManageProfileController {
    /*robots*/
    public List<User> selectedUsers{get;set;}
    public List<UserWrapper> userWrapperList{get;set;}
    public List<UserWrapper> resultUserList{get;set;}
    public String selectedProfile{get;set;}
    public ApexPages.StandardSetController setcon{get;set;}
    
    /*  This would refer to the standard set controller which controls the display of the list records displayed 
        as a result of list view selected on the UI
    */
    public ManageProfileController(ApexPages.StandardSetController controller){
        setcon=controller;
        showUsers();
        selectedUsers=new List<User>();
        resultUserList=new List<UserWrapper>();
    }
    
    /*This refers to generating select options for all the Profiles present in the org*/
    public List<SelectOption> getOptions(){
    
        List<Profile> profileList=[select id,name from Profile order by Name];
        List<SelectOption> options = new List<SelectOption>();
        for(Profile profObj:profileList){
            options.add(new SelectOption(profObj.Id,profObj.Name));
        }
        return options;
    }
    
    /*This refers to display of user result as part of search selected in the list view*/
    public void showUsers(){
        
        if(resultUserList!=null && resultUserList.size() > 0)
            resultUserList.clear();
        if(selectedUsers!=null && selectedUsers.size() > 0)
            selectedUsers.clear();
        userWrapperList=new List<UserWrapper>();
        List<User> userList=setcon.getRecords();
        for(User u:userList){
            userWrapperList.add(new UserWrapper(u));    
        }
        
    }
    
    /*This would consist of all the selected users whose profile needs to be updated*/
    public PageReference getSelected()
    {   
        selectedUsers.clear();
        for(UserWrapper userWrapperObj : userWrapperList)
            if(userWrapperObj.selected)
                selectedUsers.add(userWrapperObj.userObj);
        return null;
    }
    
    /*This method would update the user profile for selected user. This would be invoked on click of Update Profile button on UI*/
    public void updateUserProfile(){
    
        resultUserList.clear(); 
        if(selectedUsers!=null && selectedUsers.size() < 1){
           // ApexPages.Message warnMsg = new ApexPages.Message(ApexPages.severity.Warning,Label.Warning_Message);
           // ApexPages.addMessage(warnMsg);
        }else{
            if(selectedProfile!=null && selectedProfile!='')
            {
                for(User u : selectedUsers) {
                    u.ProfileId = selectedProfile;
                }
                List<Database.SaveResult> srList=Database.update(selectedUsers,false);
                 if(!test.isRunningTest())//Skip the reset process for test classes 
                    setcon.reset();
                List<Integer> failedRecordsIndexes=new List<Integer>();
                integer i=0;
                for(Database.Saveresult sr:srList){
                    User userObj=selectedUsers.get(i);
                    UserWrapper newUserWrapper=new UserWrapper(userObj);
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
    
    /*This refers to the wrapper class for user object which also has the capabilities of storing which user is selected,
    whats the error/succcess on update operation and whether the update profile operation on a partciular user really resulted in Error or Not*/
    public class UserWrapper
    {
        public User userObj{get; set;}
        public Boolean selected {get; set;}
        public String errorMsg{get;set;}
        public boolean isError{get;set;}
        
        public UserWrapper(User u)
        {
            userObj=u;
            selected = false;
            errorMsg='';
            isError=false;
        }
    }
    
       
    
}