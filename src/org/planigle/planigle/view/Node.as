package org.planigle.planigle.view
{
	import mx.collections.ArrayCollection;
	
	public class Node
	{
		protected var model:Object;
		public var parent: Object;
		public var children: ArrayCollection;
		protected var subset: ArrayCollection;

		public function Node(parent:Object, model:Object, levels:int, subset:ArrayCollection)
		{
			this.parent = parent;
			this.model = model;
			this.children = new ArrayCollection();
			this.subset = subset;
			
			if (levels > 1)
			{
				for each (var child:Object in model.children)
					addNode(child, levels - 1);
			}
			
			if (children.length == 0)
				children = null;
		}
		
		// Add a sub-node.
		protected function addNode(object:Object, levels:int):void
		{
		}
		
		// Answer how much I am utilized.
		protected function utilized():Number
		{
			return 0;
		}
		
		// Answer how much I am utilized in the subset.
		protected function utilizedIn():Number
		{
			return 0;
		}
		
		// Answer the color to use.
		public function get color():uint
		{
			var used:Number = utilizedIn();
			var total:Number = utilized();
			if (total > 0)
			{
				var percent:int = 100 * used / total;
				return percent > 100 ? 0xFF0000 : 0x000000;
			}
			return used > 0 ? 0xFF0000 : 0x000000;
		}


		// Answer the utilization.
		public function get utilization():String
		{
			var used:Number = utilizedIn();
			var total:Number = utilized();
			if (total > 0)
			{
				var percent:int = 100 * used / total;
				return formatNumber(used) + " of " + formatNumber(total) + " (" + percent + "%) - " + model.name;
			}
			else
				return formatNumber(used) + " of 0 - " + model.name;
		}

		// Format a number for display.
		private function formatNumber(num:Number):String
		{
			var base:String = num.toFixed(2);
			if (base.charAt(base.length-1) == "0" && base.charAt(base.length-2) == "0")
				return base.substring(0,base.length-3);
			else if (base.charAt(base.length-1) == "0")
				return base.substring(0,base.length-1);
			else
				return base;
		}
	}
}