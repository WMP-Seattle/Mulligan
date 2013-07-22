@isTest
private class MulliganUnitTests {
	
	@isTest static void batchStatusBarTest() {
		mulliganBatchJobs controller = new mulliganBatchJobs();
		controller.getBatchJobs();
		system.assertEquals(0, controller.batchJobs.size());
	}

	@isTest static void batchStatusBarWithJobTest() {
		mulliganBatchJobs controller = new mulliganBatchJobs();
		Integer startingCount = Database.countquery('select count() From Account');
		List <Account> accns = new List<Account>();
		for(integer i = 0; i<200; i++){
			Account a = new Account(Name='testAccount'+'i'); 
			accns.add(a);
		}
	 
		insert accns;
		delete accns;
	 
		Test.StartTest();
			String q = 'SELECT Id FROM Account WHERE isDeleted = true ALL ROWS';
			mulliganBatchRestore mbr = new mulliganBatchRestore(q);
			ID batchprocessid = Database.executeBatch(mbr);
			List<mulliganBatchJobs.BatchJob> jobs = controller.getBatchJobs();
		Test.StopTest();

		System.AssertEquals(database.countquery('SELECT COUNT() FROM Account'),(200+startingCount)); 

		system.assertEquals(1, jobs.size());
	}	
	
	@isTest static void batchRestoreTest() {
		Integer startingCount = Database.countquery('select count() From Account');
		List <Account> accns = new List<Account>();
		for(integer i = 0; i<200; i++){
			Account a = new Account(Name='testAccount'+'i'); 
			accns.add(a);
		}
	 
		insert accns;
		delete accns;
	 
		Test.StartTest();
			String q = 'SELECT Id FROM Account WHERE isDeleted = true ALL ROWS';
			mulliganBatchRestore mbr = new mulliganBatchRestore(q);
			ID batchprocessid = Database.executeBatch(mbr);
		Test.StopTest();

		System.AssertEquals(database.countquery('SELECT COUNT() FROM Account'),(200+startingCount));  
	}

	@isTest static void getDeletedCountTest() {
		Integer startingCount = Database.countquery('select count() From Account');
		List <Account> accns = new List<Account>();
		for(integer i = 0; i<200; i++){
			Account a = new Account(Name='testAccount'+'i'); 
			accns.add(a);
		}
	 
		insert accns;
		delete accns;

		mulliganController ctrl = new mulliganController();
		ctrl.val = 'Account';
		System.assertEquals(200, ctrl.getDeletedCount(), 'should be 200');
	}

	@isTest static void getDeletedCountWithConstraintsTest() {
		Integer startingCount = Database.countquery('select count() From Account');
		List <Account> accns = new List<Account>();
		for(integer i = 0; i<200; i++){
			Account a = new Account(Name='testAccount'+'i'); 
			accns.add(a);
		}
	 
		insert accns;
		delete accns;

		mulliganController ctrl = new mulliganController();
		ctrl.val = 'Account';
		ctrl.constraint.before__c = DateTime.now().addDays(2);
		ctrl.constraint.after__c = DateTime.now().addDays(-2);
		System.assertEquals(200, ctrl.getDeletedCount(), 'should be 200');
	}	

	@isTest static void getNameTest() {
		mulliganController ctrl = new mulliganController();
		SelectOption so = new SelectOption('mo_test__c', 'mo_test');
		Boolean pass = false;
		for(SelectOption s : ctrl.getName()) {
			if(s.getLabel() == 'mo_test') {
				pass = true;
				break;
			}
		}
		System.assert(pass);
	}

	@isTest static void instantiateBatchJobWrapperClass() {
		mulliganBatchJobs.BatchJob bj = new mulliganBatchJobs.BatchJob();
		bj.percentComplete = 3;
		System.AssertNotEquals(null, bj.percentComplete);
	}

	@isTest static void mulliganTitleBlockTest() {
		List <Account> accns = new List<Account>();
		for(integer i = 0; i<200; i++){
			Account a = new Account(Name='testAccount'+'i'); 
			accns.add(a);
		}
	 
		insert accns;
		delete accns;

		mulliganController ctrl = new mulliganController();
		ctrl.val = 'account';
		ctrl.getName();
		System.assertEquals('There are 200 Account deleted records in your recycle bin', ctrl.MulliganBlock);
		System.assertNotEquals('', ctrl.valTitle);
		System.assertNotEquals(false, ctrl.mulliganShouldRender);
	}
	
	@isTest static void mulliganTitleBlockTestWithNullVal() {
		mulliganController ctrl = new mulliganController();
		System.assertEquals('Please select an Object to Undelete above', ctrl.MulliganBlock);
		System.assertEquals('', ctrl.valTitle);
		System.assertEquals(false, ctrl.mulliganShouldRender);
	}

}