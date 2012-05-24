package org.planigle.planigle.model
{
	import mx.controls.List;
	
	[Bindable]
	public class ErrorHandler
	{
		import mx.collections.ArrayCollection;

		private static var instance:ErrorHandler;
		public var hasErrors:Boolean = false;
		public var errors:ArrayCollection = new ArrayCollection();
		
		public function ErrorHandler(enforcer:SingletonEnforcer)
		{
			if (enforcer == null) 
				throw new Error("You Can Only Have One ErrorHandler");
		}

		// Returns the single instance.
		public static function getInstance():ErrorHandler
		{
			if (instance == null)
				instance = new ErrorHandler(new SingletonEnforcer);
			return instance;
		}
		
		public function handleError(error:*):void {
			var planigleError:PlanigleError = new PlanigleError(error);
			trace(planigleError.message);
			trace(planigleError.stackTrace);
			errors.addItemAt(planigleError,0);
			hasErrors = true;
		}
	}
}

// Utility class to deny access to contructor.
class SingletonEnforcer {}