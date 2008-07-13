package org.planigle.planigle.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import mx.controls.Alert;
	import mx.rpc.IResponder;
	import mx.utils.ObjectUtil;
	
	import org.planigle.planigle.business.ReleasesDelegate;
	import org.planigle.planigle.model.Release;
	
	public class UpdateReleaseCommand implements ICommand, IResponder
	{
		private var oldRelease:Release;
		private var newRelease:Release;
		private var notifySuccess:Function;
		private var notifyFailure:Function;
		
		public function UpdateReleaseCommand(oldRelease:Release, newRelease:Release, aSuccessFunction:Function, aFailureFunction:Function)
		{
			this.oldRelease = oldRelease;
			this.newRelease = newRelease;
			notifySuccess = aSuccessFunction;
			notifyFailure = aFailureFunction;
		}
		
		// Required for the ICommand interface.  Event must be of type Cairngorm event.
		public function execute(event:CairngormEvent):void
		{
			new ReleasesDelegate( this ).updateRelease(newRelease);
		}
		
		// Handle successful server request.
		public function result( event:Object ):void
		{
			var result:Object = event.result;
			if (ObjectUtil.getClassInfo(result)["name"] == "org.planigle.planigle.model::Release")
			{
				oldRelease.updateCompleted(Release(result));
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