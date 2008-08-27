package org.planigle.planigle.view.controls
{
	import mx.controls.listClasses.IListItemRenderer;
	import mx.collections.ArrayCollection;
	import mx.controls.Tree;
	import mx.controls.treeClasses.TreeItemRenderer;

    // This class extends Tree and overrides the drawItem function to use the new property: rowColorFunction.
	public class ColoredTree extends Tree
	{
		public function ColoredTree()
		{
			super();
		}
		
		// The rowColorFunction can be assigned any function which returns a color. The signature of the
		// function is:
		// 
		// 	function rowColorFunction( item:Object ) : uint
		// 
		// The item is the data record for the row. If item is null, it means the row has
		// no data and is just a filler row.
		public var rowColorFunction:Function;
		
		// This function is responsible for drawing the item. In this class, if the
		// rowColorFunction has been defined, it is called to pick the color. Otherwise the given
		// color is used.
		override protected function drawItem(item:IListItemRenderer, selected:Boolean = false, highlighted:Boolean = false, caret:Boolean = false, transition:Boolean = false):void
		{
			if( rowColorFunction != null )
				TreeItemRenderer(item).setStyle("color", rowColorFunction(item.data));
			super.drawItem(item, selected, highlighted, caret, transition);
		}
	}
}