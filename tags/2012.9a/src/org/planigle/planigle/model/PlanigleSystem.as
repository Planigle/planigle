package org.planigle.planigle.model
{
	import org.planigle.planigle.commands.UpdateSystemCommand;

	[RemoteClass(alias='System')]
	[Bindable]
	public class PlanigleSystem
	{
		private static var instance:PlanigleSystem = new PlanigleSystem();
		public var id:int;
		public var licenseAgreement:String;

		public function getCurrentVersion():Object
		{
			return this;
		}
		
		// Returns the single instance.
		public static function getInstance():PlanigleSystem
		{
			return instance;
		}
	
		// Populate myself from XML.
		public function populate(xml:XML):void
		{
			id = xml.id;
			licenseAgreement = xml.child("license-agreement");
		}
	
		// Populate myself from an object.
		public function populateFromObject(system:PlanigleSystem):void
		{
			licenseAgreement = system.licenseAgreement;
		}
		
		// Update me.  Params should be of the format (record[param]).  Success function
		// will be called if successfully updated.  FailureFunction will be called if failed (will
		// be passed an XMLList with errors).
		public function update(params:Object, successFunction:Function, failureFunction:Function):void
		{
			new UpdateSystemCommand(this, params, successFunction, failureFunction).execute(null);
		}
		
		// I have been successfully updated.  Change myself to reflect the changes.
		public function updateCompleted(xml:XML):void
		{
			populate(xml);
		}
	}
}