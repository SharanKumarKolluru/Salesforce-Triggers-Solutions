public class ContactTriggerHandler extends TriggerHandler { 
 //Method: afterInsert 
 //Usage: this method is invoked in the context of "Trigger.isAfter && Trigger.isInsert" , so all the logic w.r.t after insert trigger context will be implemented here.
 public override void afterInsert() {
  list<Contact> triggerNew = Trigger.New;
  set<ID> accountIdSet = new set<ID>();
  for (Contact newContact: triggerNew) {
   //check if contct is related to Account or not 
   if (newContact.AccountId != null) {
    //Yes, Contact is realted to Account. Then add accountId to accountIdSet. 
    accountIdSet.add(newContact.AccountId);
   }
  }
  if (!accountIdSet.isEmpty()) {
   calculateCountOnAccount(accountIdSet);
  }
 }
 //Method: afterUpdate 
 //Usage: this method is invoked in the context of "Trigger.isAfter && Trigger.isUpdate" , so all the logic w.r.t after update trigger context will be implemented here. 
 public override void afterUpdate() {
  list<Contact> triggerNew = Trigger.New;
  Map<Id, Contact> triggerOldMap = (Map<Id, Contact>) Trigger.oldMap;
  set<ID> accountIdSet = new set<ID>();
  for (Contact newContact: triggerNew) {
   Contact oldContact = triggerOldMap.get(newContact.Id);
   //check contact account is changed or not and Contact is realted to Account. 
   if (newContact.AccountId != null) {
    if (newContact.AccountId != oldContact.AccountId) {
     //Yes, Contact is realted to Account. Then add accountId to accountIdSet. 
     accountIdSet.add(newContact.AccountId);
    }
   } else if (newContact.AccountId == null && oldContact.AccountId != null) {
    accountIdSet.add(oldContact.AccountId);
   }
  }
  if (!accountIdSet.isEmpty()) {
   calculateCountOnAccount(accountIdSet);
  }
 }
 //Method: afterDelete 
 //Usage: this method is invoked in the context of "Trigger.isAfter && Trigger.isdelete" , so all the logic w.r.t after delete trigger context will be implemented here. 
 public override void afterDelete() {
  list<Contact> triggerOld = Trigger.Old;
  set<ID> accountIdSet = new set<ID>();
  for (Contact oldContact: triggerOld) {
   if (oldContact.AccountId != null) {
    //Yes, Contact is realted to Account. Then add accountId to accountIdSet.
    accountIdSet.add(oldContact.AccountId);
   }
  }
  if (!accountIdSet.isEmpty()) {
   calculateCountOnAccount(accountIdSet);
  }
 }
 //Method: afterUnDelete 
 //Usage: this method is invoked in the context of "Trigger.isAfter && Trigger.isUndelete" , so all the logic w.r.t after undelete trigger context will be implemented here. 
 public override void afterUnDelete() {
  list<Contact> triggerNew = Trigger.New;
  Map<Id, Contact> triggerOldMap = (Map<Id, Contact>) Trigger.oldMap;
  set<ID> accountIdSet = new set<ID>();
  for (Contact newContact: triggerNew) {
   if (newContact.AccountId != null) {
    //Yes, Contact is realted to Account. Then add accountId to accountIdSet. 
    accountIdSet.add(newContact.AccountId);
   }
  }
  if (!accountIdSet.isEmpty()) {
   calculateCountOnAccount(accountIdSet);
  }
 }
 //method will calculate count of all child contacts w.r.t each Account 
 private void calculateCountOnAccount(set<ID> accountIdSet) {
  list<Account> updateAccountList = new list<Account>();
  //Parent to child query : Getting Accounts and their related Contacts 
  for (Account account: [Select Id, Number_of_contacts__c, (SELECT Id from Contacts) FROM Account WHERE ID in: accountIdSet]) {
   Integer contactCount = 0;
   for (Contact contact: account.Contacts) {
    contactCount++;
   }
   account.Number_of_Contacts__c = contactCount;
   updateAccountList.add(account);
  }
  if (!updateAccountList.isEmpty()) {
   update updateAccountList;
  }
 }
}