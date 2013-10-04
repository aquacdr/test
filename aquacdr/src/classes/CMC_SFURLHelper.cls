public with sharing class CMC_SFURLHelper {

   public static String getCurrentId() {
        String idValue = System.currentPageReference().getParameters().get('Id');
    	return idValue;
    }
    
    public static String getSFParamValue(String parameter) {
        String idValue = System.currentPageReference().getParameters().get(parameter);
    	return idValue;
    }
    
}