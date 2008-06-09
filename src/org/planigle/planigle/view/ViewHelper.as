package org.planigle.planigle.view
{
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.utils.ObjectUtil;
	import org.planigle.planigle.model.ViewModelLocator;
	import org.planigle.planigle.model.IterationFactory;
	import org.planigle.planigle.model.Iteration;
	
	// Provide static helper methods for formatting and sorting common fields.
	public class ViewHelper
	{
		// Display the iteration's name in the table (rather than ID).
		public static function formatIteration(item:Object, column:DataGridColumn):String
		{
			if (item.iterationId != -1)
				return IterationFactory.getInstance().find(item.iterationId).name;
			else
				return "";
		}

		// Answer the index of the iteration in the list of iterations (or -1 if backlog).
		private static function indexIteration(item:Object):int
		{
			return IterationFactory.getInstance().iterationSelector.getItemIndex(IterationFactory.getInstance().find(item.iterationId));
		}
		
		// Answer the sort order for the specified items (based on where they are in the list of iterations).
		public static function sortIteration(item1:Object, item2:Object):int
		{
			return ObjectUtil.numericCompare( indexIteration(item1), indexIteration(item2) );
		}

		// Display the owner's name in the table (rather than ID).
		public static function formatIndividual(item:Object, column:DataGridColumn):String
		{
			var it:int = item.ownerId;
			if (it == 0)
				return ViewModelLocator.getInstance().individualSelector[0].child("full-name");
			else
				return ViewModelLocator.getInstance().individualSelector.(id == it).child("full-name");
		}

		// Answer the index of the owner in the list of oweners (or -1 if no owner).
		private static function indexIndividual(item:Object):int
		{
			var it:int = item.ownerId;
			if (it == 0)
				return -1;
			else
				return ViewModelLocator.getInstance().individualSelector.(id == it).childIndex();
		}
		
		// Answer the sort order for the specified items (based on where they are in the list of owners).
		public static function sortIndividual(item1:Object, item2:Object):int
		{
			return ObjectUtil.numericCompare( indexIndividual(item1), indexIndividual(item2) );
		}

		// Display the project's name in the table (rather than ID).
		public static function formatProject(item:Object, column:DataGridColumn):String
		{
			var it:int = item.child("project-id");
			if (it == 0)
				return ViewModelLocator.getInstance().projectSelector[0].name;
			else
				return ViewModelLocator.getInstance().projectSelector.(id == it).name;
		}

		// Answer the index of the project in the list of projects (or -1 if no project).
		private static function indexProject(item:Object):int
		{
			var it:int = item.child("project-id");
			if (it == 0)
				return -1;
			else
				return ViewModelLocator.getInstance().projectSelector.(id == it).childIndex();
		}
		
		// Answer the sort order for the specified items (based on where they are in the list of projects).
		public static function sortProject(item1:Object, item2:Object):int
		{
			return ObjectUtil.numericCompare( indexProject(item1), indexProject(item2) );
		}

		// 	Display the user facing status in the table (rather than a code).	
		public static function formatStatus(item:Object, column:DataGridColumn):String
		{
			switch(item.statusCode)
			{
				case 1: return "In Progress";
				case 2: return "Accepted";
				default: return "Created";
			}
		}
		
		// Sort status based on its code.
		public static function sortStatus(item1:Object, item2:Object):int
		{
			return ObjectUtil.numericCompare(item1.statusCode, item2.statusCode);
		}

		// 	Display the user facing survey mode in the table (rather than a code).	
		public static function formatSurveyMode(item:Object, column:DataGridColumn):String
		{
			switch(int(item.child("survey-mode")))
			{
				case 1: return "Private by Default";
				case 2: return "Public by Default";
				default: return "Private";
			}
		}
		
		// Sort status based on its code.
		public static function sortSurveyMode(item1:Object, item2:Object):int
		{
			return ObjectUtil.numericCompare(item1.child("survey-mode"), item2.child("survey-mode"));
		}
	}
}