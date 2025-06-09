public with sharing class NewOpportunityInline {
    public static List<String> apiName= new List<String>{'ID','Department', 'DoNotCall', 'Level__c','CleanStatus','Experience__c'};
    public static List<DetailsWrapper> detailList = new List<DetailsWrapper>();
    public static List<sObject> valueList = new List<sObject>();
    
    @AuraEnabled
    public static List<DetailsWrapper> RetriveWrapper(String recordId) 
    {
        String type='Contact';
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(type);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        
        String fieldNames='';
        for (String field: apiName) 
        {
            fieldNames += field + ',' ;
        }
        fieldNames = fieldNames.removeEnd(',');
        
        Map<String, String> mapOfValues =new Map<String, String>();
        valueList = Database.query('SELECT '+fieldNames+ ' FROM Contact WHERE id =\'' +recordId+ '\' ');
        for(Sobject obj : valueList)
        {
            for(String name : apiName)
            {
                mapOfValues.put(name,String.valueOf(obj.get(name))); 
            }
        }
        
        for (String fieldName: apiName) 
        {
            Boolean isReadOnly = false;
            Boolean isTooltip = false;
            String fieldLabel = fieldMap.get(fieldName).getDescribe().getLabel();
            List<String> picklist= new List<String>();
            Schema.DisplayType fieldType = fieldMap.get(fieldName).getDescribe().getType();
            String tooltip = fieldMap.get(fieldName).getDescribe().getInlinehelptext();
            String fieldDataType = GetType(fieldType);
            
            System.debug('accessible---'+fieldMap.get(fieldName).getDescribe().isAccessible());
            System.debug('updateable---'+fieldMap.get(fieldName).getDescribe().isUpdateable());
            if(fieldMap.get(fieldName).getDescribe().isAccessible()
               && !fieldMap.get(fieldName).getDescribe().isUpdateable())
                isReadOnly = true;
            
            if(tooltip!=null)
            {
                if((tooltip.trim()).length()>0)
                    isTooltip = true;

            }
                        
            if(fieldType == Schema.DisplayType.PickList)
            {
                List<Schema.PicklistEntry> pickListEntry = fieldMap.get(fieldName).getDescribe().getPicklistValues();            
                for( Schema.PicklistEntry plistentry : pickListEntry)
                {
                    picklist.add(plistentry.getValue());
                }    
            }
            
            detailList.add(new DetailsWrapper(fieldLabel,fieldName,mapOfValues.get(fieldName),tooltip,fieldDataType,picklist,isReadOnly,isTooltip)); 
            
        }
        System.debug(detailList);
        return detailList;
    }
    
    public static String GetType(Schema.DisplayType fieldType)
    {
        if(fieldType == Schema.DisplayType.String || 
           fieldType == Schema.DisplayType.TextArea ||
           fieldType == Schema.DisplayType.Id ||
           fieldType == Schema.DisplayType.Reference ||
           fieldType == Schema.DisplayType.Phone ||
           fieldType == Schema.DisplayType.Email ||
           fieldType == Schema.DisplayType.URL)
            return 'String';
        if(fieldType == Schema.DisplayType.Picklist)
            return 'PickList';
        if(fieldType == Schema.DisplayType.Currency ||
           fieldType == Schema.DisplayType.Double)
            return 'Decimal';
        if(fieldType == Schema.DisplayType.Integer)
            return 'Integer';
        if(fieldType == Schema.DisplayType.Boolean)
            return 'Boolean';
        if(fieldType == Schema.DisplayType.DateTime)
            return 'DateTime';    
        if(fieldType == Schema.DisplayType.Date)
            return 'Date';            
        if(fieldType == Schema.DisplayType.Time)
            return 'Time';
        if(fieldType == Schema.DisplayType.Combobox)
            return 'Combobox';    
        if(fieldType == Schema.DisplayType.MultiPicklist)
            return 'MultiPicklist';
        if(fieldType == Schema.DisplayType.EncryptedString)
            return 'EncryptedString';
        if(fieldType == Schema.DisplayType.DataCategoryGroupReference)
            return 'DataCategoryGroupReference';        
        if(fieldType == Schema.DisplayType.base64 )
            return 'base64 ';               
        return 'UNKNOWN';  
    }
    
    
    @AuraEnabled
    public static List<DetailsWrapper> saveContact (String acc) {
        System.debug(acc);
        Contact con = new Contact();
        try
        {
            con = (Contact)JSON.deserialize(acc, Contact.class);
            upsert con;
        }
        catch(Exception ex)
        {
            System.debug(ex.getMessage());
        }
        
         return RetriveWrapper(con.id);
    }
    
    
    public class DetailsWrapper
    {
        @AuraEnabled public String fieldLabel {get; set;}        
        @AuraEnabled public String fieldAPI {get; set;}
        @AuraEnabled public String value {get; set;}
        @AuraEnabled public String tooltip {get; set;}
        @AuraEnabled public Boolean isTooltip {get; set;}
        @AuraEnabled public String dataType {get; set;}
        @AuraEnabled public List<String> pickList {get; set;}
        @AuraEnabled public Boolean isReadOnly{get;set;}
        
        public DetailsWrapper(String fieldLabel, String fieldAPI, String value,String toolTip, String dataType, List<String> pickList, Boolean isReadOnly, Boolean isTooltip)
        {
            this.fieldLabel= fieldLabel;
            this.fieldAPI= fieldAPI;
            this.dataType=dataType;
            this.value = value;
            this.isTooltip=isTooltip;
            this.toolTip=toolTip;
            this.picklist=picklist;
            this.isReadOnly = isReadOnly;
        }
    }
    
    
}