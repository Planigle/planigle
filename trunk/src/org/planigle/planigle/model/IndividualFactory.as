package org.planigle.planigle.model
{
	import mx.collections.ArrayCollection;
	
	import org.planigle.planigle.commands.CreateIndividualCommand;
	import org.planigle.planigle.events.ProjectChangedEvent;
	import org.planigle.planigle.events.IndividualChangedEvent;
	import org.planigle.planigle.events.ReleaseChangedEvent;
	import org.planigle.planigle.events.IterationChangedEvent;
	import org.planigle.planigle.events.StoryChangedEvent;
	
	[Bindable]
	public class IndividualFactory
	{
		public var individuals:ArrayCollection = new ArrayCollection();
		public var individualSelector:ArrayCollection = new ArrayCollection();
		public var currentIndividual:Individual;
		private var currentLogin:String;
		private var individualMapping:Object = new Object();
		private static var instance:IndividualFactory;
		
		public function IndividualFactory(enforcer:SingletonEnforcer)
		{
			if (enforcer == null) 
				throw new Error("You Can Only Have One IndividualFactory");
		}

		// Returns the single instance.
		public static function getInstance():IndividualFactory
		{
			if (instance == null)
				instance = new IndividualFactory(new SingletonEnforcer);
			return instance;
		}

		// Returns the current individual.
		public static function current():Individual
		{
			return instance.currentIndividual;
		}
		
		// Update my individuals to be the specified individuals.
		public function updateIndividuals( newIndivids:ArrayCollection ):void
		{
			var newIndividuals:ArrayCollection = new ArrayCollection();
			var newIndividualSelector:ArrayCollection = new ArrayCollection();
			individualMapping = new Object();

			for each (var individual:Individual in newIndivids)
			{
				if (individual.login == currentLogin)
				{
					if (currentIndividual)
					{
						currentIndividual.populateFromObject( individual ); // Important to keep same instance
						individual = currentIndividual;
					}
					else
						currentIndividual = individual;
				}
				newIndividuals.addItem(individual);
				newIndividualSelector.addItem(individual);
				individualMapping[individual.id] = individual;
			}
			
			var individ:Individual = new Individual();
			individ.populate( <individual><id nil="true" /><first-name>No</first-name><last-name>Owner</last-name></individual> );
			newIndividualSelector.addItem( individ );
			individuals = newIndividuals;
			individualSelector = newIndividualSelector;
		}

		// Populate the individuals.
		public function populate(newIndividuals:Array):void
		{
			updateIndividuals(new ArrayCollection(newIndividuals));
		}
		
		// Create a new individual.  Params should be of the format (record[param]).  Success function
		// will be called if successfully updated.  FailureFunction will be called if failed (will
		// be passed an XMLList with errors).
		public function createIndividual(params:Object, successFunction:Function, failureFunction:Function):void
		{
			new CreateIndividualCommand(this, params, successFunction, failureFunction).execute(null);
		}
		
		// An individual has been successfully created.  Change myself to reflect the changes.
		public function createCompleted(xml:XML):Individual
		{
			var newIndividual:Individual = new Individual();
			newIndividual.populate(xml);
			// Create copy to ensure any views get notified of changes.
			var newIndividuals:ArrayCollection = new ArrayCollection();
			for each (var individual:Individual in individuals)
				newIndividuals.addItem(individual);
			newIndividuals.addItem(newIndividual);
			updateIndividuals(newIndividuals);
			return newIndividual;
		}

		// Find an individual given its ID.  If no individual, return an Individual representing the backlog.
		public function find(id:String):Individual
		{
			var individual:Individual = individualMapping[id];
			return individual ? individual : Individual(individualSelector.getItemAt(individualSelector.length-1));	
		}

		// Update after a new user is logged in.
		public function setCurrent(login:String):void
		{
			currentLogin = login;
		}
	}
}

// Utility class to deny access to contructor.
class SingletonEnforcer {}