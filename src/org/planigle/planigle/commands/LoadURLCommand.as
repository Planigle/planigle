package org.planigle.planigle.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import org.planigle.planigle.events.URLEvent;

	public class LoadURLCommand implements ICommand
	{
		public function LoadURLCommand()
		{
		}
			
		public function execute(event:CairngormEvent):void
		{
			var urlEvent:URLEvent = event as URLEvent;
			var request:URLRequest = new URLRequest(urlEvent.url);
			try
			{
				navigateToURL(request, "_blank");
			}
			catch (e:Error) {}
		}
	}
}