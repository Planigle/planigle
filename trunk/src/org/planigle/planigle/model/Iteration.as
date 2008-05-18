package org.planigle.planigle.model
{
	[Bindable]
	public class Iteration
	{
		public var id:int;
		public var name:String;
		public var start:String;
		public var length:int;
	
		// Construct an iteration based on XML.
		public function Iteration(xml:XML)
		{
			id = xml.id;
			name = xml.name;
			start = xml.start;
			length = xml.length;
		}
	}
}