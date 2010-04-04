package org.planigle.planigle.control
{
	import com.adobe.cairngorm.control.FrontController;
	import org.planigle.planigle.commands.GetAuditsCommand;
	import org.planigle.planigle.events.AuditChangedEvent;
	
	public class AuditsController extends FrontController
	{
		public function AuditsController()
		{
			this.initialize();	
		}
		
		public function initialize():void
		{
			// Map event to command.
			this.addCommand(AuditChangedEvent.AUDIT_CHANGED, GetAuditsCommand);	
		}
	}
}