package org.planigle.planigle.model
{
	import mx.collections.ArrayCollection;
	
	import org.planigle.planigle.commands.CreateCompanyCommand;
	
	[Bindable]
	public class CompanyFactory
	{
		public var companies:ArrayCollection = new ArrayCollection();
		public var companySelector:ArrayCollection = new ArrayCollection();
		private var companyMapping:Object = new Object();
		private static var instance:CompanyFactory;
		
		public function CompanyFactory(enforcer:SingletonEnforcer)
		{
			if (enforcer == null) 
				throw new Error("You Can Only Have One CompanyFactory");
		}

		// Returns the single instance.
		public static function getInstance():CompanyFactory
		{
			if (instance == null)
				instance = new CompanyFactory(new SingletonEnforcer);
			return instance;
		}

		// Update my companies to be the specified companies.
		public function updateCompanies( newCompanies:ArrayCollection ):void
		{
			var newCompanySelector:ArrayCollection = new ArrayCollection();
			companyMapping = new Object();

			for each (var company:Company in newCompanies)
			{
				newCompanySelector.addItem(company);
				companyMapping[company.id] = company;
			}
			
			var proj:Company = new Company();
			proj.populate( <company><id nil="true" /><name>None</name></company> );
			newCompanySelector.addItem( proj );
			companies = newCompanies;
			companySelector = newCompanySelector;
		}

		// Populate the companies.
		public function populate(newCompanies:Array):void
		{
			updateCompanies(new ArrayCollection(newCompanies));
		}
		
		// Create a new company.  Params should be of the format (record[param]).  Success function
		// will be called if successfully updated.  FailureFunction will be called if failed (will
		// be passed an XMLList with errors).
		public function createCompany(params:Object, successFunction:Function, failureFunction:Function):void
		{
			new CreateCompanyCommand(this, params, successFunction, failureFunction).execute(null);
		}
		
		// An company has been successfully created.  Change myself to reflect the changes.
		public function createCompleted(xml:XML):Company
		{
			var newCompany:Company = new Company();
			newCompany.populate(xml);
			// Create copy to ensure any views get notified of changes.
			var newCompanies:ArrayCollection = new ArrayCollection();
			for each (var company:Company in companies)
				newCompanies.addItem(company);
			newCompanies.addItem(newCompany);
			updateCompanies(newCompanies);
			return newCompany;
		}

		// Find an company given its ID.  If no company, return an Company representing the backlog.
		public function find(id:String):Company
		{
			var company:Company = companyMapping[id];
			return company ? company : Company(companySelector.getItemAt(companySelector.length-1));	
		}
	}
}

// Utility class to deny access to contructor.
class SingletonEnforcer {}