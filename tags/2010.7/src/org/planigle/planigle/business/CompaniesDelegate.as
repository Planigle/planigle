package org.planigle.planigle.business
{
	import mx.rpc.IResponder;

	public class CompaniesDelegate extends Delegate
	{
		public function CompaniesDelegate( responder:IResponder )
		{
			super(responder);
		}

		// Answer the name of the remote object (should be overridden).
		override protected function getRemoteObjectName():String
		{
			return "companyRO";
		}

		// Answer the name of the factory URL.
		override protected function getFactoryUrl(factory:Object):String
		{
			return "companies.xml"
		}

		// Answer the name of the object URL (should be overridden).
		override protected function getObjectUrl(object:Object):String
		{
			return "companies/" + object.id + ".xml"
		}
	}
}