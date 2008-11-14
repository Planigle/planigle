package org.planigle.planigle.view
{
	import mx.collections.ArrayCollection;
	
	public class UtilizationNode extends Node
	{
		public function UtilizationNode(parent:Object, model:Object, levels:int, subset:ArrayCollection)
		{
			super(parent, model, levels, subset);
		}

		// Add a sub-node.
		protected override function addNode(object:Object, levels:int):void
		{
			children.addItem(new UtilizationNode(this, object, levels, subset));
		}
		
		// Answer how utilized I am.
		protected override function utilized():Number
		{
			return model.utilization;
		}
		
		// Answer how utilized I am.
		protected override function utilizedIn():Number
		{
			return model.utilizationIn(subset);
		}
	}
}