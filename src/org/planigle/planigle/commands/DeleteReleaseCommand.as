package org.planigle.planigle.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import mx.controls.Alert;
	import mx.rpc.IResponder;
	import mx.utils.ObjectUtil;
	
	import org.planigle.planigle.business.ReleasesDelegate;
	import org.planigle.planigle.model.Release;
	
	public class DeleteReleaseCommand implements ICommand, IResponder
	{
		private var release:Release;
		private var notifySuccess:Function;
		private var notifyFailure:Function;
		
		public function DeleteReleaseCommand(aRelease:Release, aSuccessFunction:Function, aFailureFunction:Function)
		{
			release = aRelease;
			notifySuccess = aSuccessFunction;
			notifyFailure = aFailureFunction;
		}
		
		// Required for the ICommand interface.  Event must be of type Cairngorm event.
		public function execute(event:CairngormEvent):void
		{
			new ReleasesDelegate( this ).deleteRelease(release);
		}
		
		// Handle successful server request.
		public function result( event:Object ):void
		{
			var result:Object = event.result;
			if (ObjectUtil.getClassInfo(result)["name"] == "org.planigle.planigle.model::Release")
			{
				release.destroyCompleted();
				if (notifySuccess != null)
					notifySuccess();
			}
			else
			{
				if (notifyFailure != null)
					notifyFailure(result as Array);
			}
		}
		
		// Handle case where error occurs.
		public function fault( event:Object ):void
		{
			Alert.show(event.fault.faultString);
		}
	}
}