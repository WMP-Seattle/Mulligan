global class mulliganBatchRestore implements Database.Batchable<sObject> {
	
	String query;
	
	global mulliganBatchRestore(String q) {
		query = q;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		// Use Database.undelete with the section optional parameter to allow for 
		// the transaction to continue if a record fails to restore.
		Database.undelete(scope, false);
	}
	
	global void finish(Database.BatchableContext BC) {
		System.debug('All Done!');
	}
	
}