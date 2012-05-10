package org.planigle.planigle.view.requests
{
	public class Request
	{
		protected var item:Object;
		protected var notifySuccess:Function;
		protected var notifyFailure:Function;

		public function Request(item:Object, notifySuccess:Function, notifyFailure: Function)
		{
			this.item = item;
			this.notifySuccess = notifySuccess;
			this.notifyFailure = notifyFailure;
		}

		public function perform():void {
		}
	}
}