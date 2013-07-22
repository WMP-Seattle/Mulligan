Public with sharing class mulliganController {

	/*
	 *	class properties
	 *	val 									- value of picklist of un-deletedable objects.
	 *	valTitle							- Label of selected value
	 *	constraint						- end constraint for date-boxing on undeletion of records 
	 *	mulliganBlock					- Title of the pageBlockSection for actually undeleteing things
	 *	mulliganShouldRender	- Should the mulligan block render?
	 *	displayBatchJobs			- Should the batch jobs display?
	 *	q 										- Query string
	 */
	
	public String val {get;set;} // Selected picklist value
	public String valTitle{  // Title case of the Label of the Picklist value
		get {
			if(val != null) {
				return gd.get(val).getDescribe().getLabel().capitalize();	
			}
			return '';			
		}
	}
	String q;
	Public String error {get;set;}
	public String mulliganBlock { // Title of the pageblocksection of the actual mulligan box
		get{
			if(val != null) {
				return 'There are '+ getDeletedCount() +' '+ valTitle +' deleted records in your recycle bin';
			} 
			return 'Please select an Object to Undelete above';
		}
	}
	public boolean mulliganShouldRender {
		get{
			if(val != null) {
				return true;
			}
			return false;
		}
	}
	public Map<String, Schema.sObjectType> gd; // global describe of objects
	public Mulligan_Controls__c constraintObject = new Mulligan_Controls__c();
	public Mulligan_Controls__c constraint {
		get{
			return this.constraintObject;
		}
		set;
	}

	/*
	 * getName()
	 * 	Inputs: None
	 * 	Returns: List of Select options for Picklist
	 *  Return Format: <object_api_name, Object Label>
	 *  Filter: Return only objects that are unDeleteable
	 */
	public List<SelectOption> getName(){
		gd = Schema.getGlobalDescribe();
		List<SelectOption> options = new List<SelectOption>();
		
		for(Schema.SObjectType f : gd.Values()){
			if(f.getDescribe().isUndeletable()){
				options.add(new SelectOption(f.getDescribe().getLocalName().toLowerCase() , f.getDescribe().getLabel()));
			}
		}
		return options;
	}

	/*
	 *	nothing()
	 *	Method exists for action-function ajax call, and is intentionally null/blank
	 */
	Public Void nothing(){}

	/*
	 *	getDeletedCount()
	 *	Inputs: (direct) none. (indirect) val, before, after
	 *	Output: Int, count of objects that are undeleteable 
	 */
	public Integer getDeletedCount(){
		if(val == null) { return 0; }
		q = 'SELECT Id FROM ' + val + ' WHERE isDeleted = true';
		if(constraint.after__c != null) {
			q += ' AND LastModifiedDate >= ' + constraint.after__c.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
		}
		if(constraint.before__c != null) { 
			q += ' AND LastModifiedDate <= ' + constraint.before__c.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
		}
		q += ' ALL ROWS';
		list<sObject> records = Database.query(q);
		return records.size();
	}

	/*
	 *	callAMulligan()
	 *	Inputs: (direct) none. (inderect) val, before, after
	 * 	Output: void (started batch job)
	 */
	public void callAMulligan(){
		MulliganBatchRestore batchJob = new MulliganBatchRestore(q);
		List<AsyncApexJob> openJobs = [select Id from AsyncApexJob where Status = 'Processing' OR Status = 'Queued']; 
 
		if(openJobs.size() < 5){
			ID batchprocessid = Database.executeBatch(batchJob);
		} else {
			error = 'Mulligan has found 5 batch jobs already enqueued or being processed. Please wait for one or more to finish and try again.';
		}
	}
}