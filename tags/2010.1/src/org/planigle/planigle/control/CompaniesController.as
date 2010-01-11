package org.planigle.planigle.control
{
	import com.adobe.cairngorm.control.FrontController;
	import org.planigle.planigle.commands.GetCompaniesCommand;
	import org.planigle.planigle.events.CompanyChangedEvent;
	
	public class CompaniesController extends FrontController
	{
		public function CompaniesController()
		{
			this.initialize();	
		}
		
		public function initialize():void
		{
			// Map event to command.
			this.addCommand(CompanyChangedEvent.COMPANY_CHANGED, GetCompaniesCommand);	
		}
	}
}