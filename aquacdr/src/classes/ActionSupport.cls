public class ActionSupport {
    Integer count = 0;//xyz 
    boolean isVisible;
    
   /*back2robots*/
    
       public ActionSupport() {
        isVisible = true;
       }
    public PageReference incrementCounter() {
            count++;
            
            return null;
    }
                    
    public Integer getCount() {
        return count;
    }
    
    public boolean getRenderPanel() {
        system.debug ('in renderPanel count = ' + count);
        if (count > 5) 
        { 
             system.debug('setting renderpanel = false');
           return false;
          
        } 
        else {
           system.debug('setting renderpanel = true');
           return true;
           
        }
    }
    
}