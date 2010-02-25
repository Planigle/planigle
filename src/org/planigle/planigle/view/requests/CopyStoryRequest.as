package org.planigle.planigle.view.requests
{
	import org.planigle.planigle.model.Story;	

	public class CopyStoryRequest extends Request
	{
		protected var priority:String;
		
		public function CopyStoryRequest(item:Story, priority:String, notifySuccess:Function, notifyFailure: Function)
		{
			super(item, notifySuccess, notifyFailure);
			this.priority = priority;
		}

		override public function perform():void {
			item.copy(priority, notifySuccess, notifyFailure);
		}
	}
}