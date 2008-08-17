package org.planigle.planigle.view
{
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.utils.ObjectUtil;
	import org.planigle.planigle.model.ProjectFactory;
	import org.planigle.planigle.model.Project;
	import org.planigle.planigle.model.IndividualFactory;
	import org.planigle.planigle.model.IterationFactory;
	
	// Provide static helper methods for formatting and sorting common fields.
	public class ViewHelper
	{
		// Display the iteration's name in the table (rather than ID).
		public static function formatIteration(item:Object, column:DataGridColumn):String
		{
			if (item.iterationId != "-1")
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
			return IndividualFactory.getInstance().find(item.individualId).fullName;
		}

		// Answer the index of the owner in the list of oweners (or -1 if no owner).
		private static function indexIndividual(item:Object):int
		{
			return IndividualFactory.getInstance().individualSelector.getItemIndex(IndividualFactory.getInstance().find(item.individualId));
		}
		
		// Answer the sort order for the specified items (based on where they are in the list of owners).
		public static function sortIndividual(item1:Object, item2:Object):int
		{
			return ObjectUtil.numericCompare( indexIndividual(item1), indexIndividual(item2) );
		}

		// Display the project's name in the table (rather than ID).
		public static function formatProject(item:Object, column:DataGridColumn):String
		{
			return ProjectFactory.getInstance().find(item.projectId).name;
		}

		// Answer the index of the project in the list of projects (or -1 if no project).
		private static function indexProject(item:Object):int
		{
			return ProjectFactory.getInstance().projectSelector.getItemIndex(ProjectFactory.getInstance().find(item.projectId));
		}
		
		// Answer the sort order for the specified items (based on where they are in the list of projects).
		public static function sortProject(item1:Object, item2:Object):int
		{
			return ObjectUtil.numericCompare( indexProject(item1), indexProject(item2) );
		}

		// Display the team's name in the table (rather than ID).
		public static function formatTeam(item:Object, column:DataGridColumn):String
		{
			return item.hasOwnProperty("teamId") ? ProjectFactory.getInstance().find(item.projectId).find(item.teamId).name : "";
		}

		// Answer the index of the team in the list of teams (or -1 if no team).
		private static function indexTeam(item:Object):int
		{
			var project:Project = ProjectFactory.getInstance().find(item.projectId);
			return indexProject(item)*100 + project.teamSelector.getItemIndex(project.find(item.teamId));
		}
		
		// Answer the sort order for the specified items (based on where they are in the list of projects).
		public static function sortTeam(item1:Object, item2:Object):int
		{
			return ObjectUtil.numericCompare( indexTeam(item1), indexTeam(item2) );
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
			if (item.isProject())
			{
				switch(item.surveyMode)
				{
					case 1: return "Private by Default";
					case 2: return "Public by Default";
					default: return "Private";
				}
			}
			else return "";
		}
		
		// Sort status based on its code.
		public static function sortSurveyMode(item1:Object, item2:Object):int
		{
			return ObjectUtil.numericCompare(item1.child("survey-mode"), item2.child("survey-mode"));
		}

		// Sort effort numerically.
		public static function sortEffort(item1:Object, item2:Object):int
		{
			return ObjectUtil.numericCompare(Number(item1.calculatedEffort),Number(item2.calculatedEffort));
		}

		// Sort priority numerically.
		public static function sortPriority(item1:Object, item2:Object):int
		{
			return ObjectUtil.numericCompare(Number(item1.priority),Number(item2.priority));
		}

		// Sort user priority numerically.
		public static function sortUserPriority(item1:Object, item2:Object):int
		{
			return ObjectUtil.numericCompare(Number(item1.userPriority),Number(item2.userPriority));
		}

		// 	Display the user facing role in the table (rather than a code).	
		public static function formatRole(item:Object, column:DataGridColumn):String
		{
			switch(int(item.role))
			{
				case 0: return "Admin";
				case 1: return "Project Admin";
				case 2: return "Project User";
				default: return "Read Only User";
			}
		}		
	}
}