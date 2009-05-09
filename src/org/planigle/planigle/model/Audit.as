package org.planigle.planigle.model
{
	import mx.binding.utils.ChangeWatcher;
	
	import org.planigle.planigle.view.ViewHelper;
	
	[RemoteClass(alias='Audit')]
	[Bindable]
	public class Audit
	{
		ChangeWatcher.watch(IndividualFactory.getInstance(), "currentIndividual", Audit.clearAudits);
		public static var audits:Array;
		public var id:int;
		public var projectId:String;
		public var auditableType:String;
		public var auditableId:int;
		public var auditableName:String;
		public var userId:int;
		public var action:String;
		public var changes:Object;
		public var createdAt:Date;

		// Clear any audits.
		public static function clearAudits(event:Event):void
		{
			audits = new Array();
		}
		
		// Answer the name of the object changed.
		public function get name():String
		{
			return auditableName;
		}
		
		public function set name(name:String):void
		{
		}
		
		// Answer thte name of the user that made the changes.
		public function get userName():String
		{
			var individ:Individual = IndividualFactory.getInstance().find(String(userId));
			return individ ? individ.name : "Unknown User";
		}
		
		public function set userName(name:String):void
		{
		}
		
		// Answer the changess in a readable format.
		public function get changeDescription():String
		{
			var description:String = '';
			for (var key:String in changes)
			{
				if (action == 'create')
					description += '<li>' + (getKey(key) + " set to '" + getValue(key, changes[key][1]) + "'</li>");
				else
					description += '<li>' + (getKey(key) + " changed from '" + getValue(key, changes[key][0]) + "' to '" + getValue(key, changes[key][1]) + "'</li>");
			}
			return '<ul>' + description + '</ul>';
		}

		// Answer the user facing key.
		private function getKey(key:String):String
		{
			switch (key)
			{
				case 'companyId':
					return 'Company';
				case 'projectId':
					return 'Project';
				case 'teamId':
					return 'Team';
				case 'individualId':
					return 'Owner';
				case 'releaseId':
					return 'Release';
				case 'iterationId':
					return 'Iteration';
				case 'statusCode':
					return 'Status';
				case 'surveyMode':
					return 'Stories';
				case 'isPublic':
					return 'Public';
				default:
					var pattern:RegExp = /([A-Za-z][a-z]*)([A-Z][a-z]+)*/;
					return key.replace(pattern, replace);
			}
		}
		
		// Replace the key.
		private function replace():String
		{
			var string:String = capitalize(arguments[1]);
			for (var i:int = 2; i < arguments.length - 2; i++)
			{
				if (arguments[i] != "")
					string = string.concat( " ", capitalize(arguments[i]));
			}
			return string;
		}
		
		// Capitalize a string.
		private function capitalize(string:String):String
		{
			return string.charAt(0).toUpperCase() + string.substr(1);
		}
		
		// Answer a user visible value.
		private function getValue(key:String, value:Object):String
		{
			var object:Object = null;
			switch (key)
			{
				case 'companyId':
					object = CompanyFactory.getInstance().find(String(value));
					break;
				case 'projectId':
					object = IndividualFactory.current().company.find(String(value));
					break;
				case 'teamId':
					object = IndividualFactory.current().selectedProject.find(String(value));
					break;
				case 'individualId':
					object = IndividualFactory.getInstance().find(String(value));
					break;
				case 'releaseId':
					object = ReleaseFactory.getInstance().find(String(value));
					break;
				case 'iterationId':
					object = IterationFactory.getInstance().find(String(value));
					break;
				case 'statusCode':
					return ViewHelper.formatStatusValue(int(value));
				case 'role':
					return ViewHelper.formatRoleValue(int(value));
				case 'surveyMode':
					return ViewHelper.formatSurveyModeValue(int(value));
				case 'notificationType':
					return ViewHelper.formatNotificationTypeValue(int(value));
				case 'valueType':
					return ViewHelper.formatAttributeTypeValue(int(value));
				case 'acceptanceCriteria':
					return formatAcceptanceCriteria(String(value));
				default:
					return value is Date ? DateUtils.formatDate(value as Date) : ((value == null) ? '' : value.toString());
			}
			return object == null ? "Unknown" : object.name;
		}
		
		protected function formatAcceptanceCriteria(value:String):String
		{
			var newString:String = '';
			for each (var substring:String in value.split("\r"))
			{
				newString += newString == "" ? "" : ", ";
				newString += substring.length > 0 && substring.charAt(0) == '-' ? substring.substring(1) : substring;
			}
			return newString;
		}
		
		public function set changeDescription(name:String):void
		{
		}
		
		//  Answer the date the object was changed.
		public function get date():String
		{
			return DateUtils.formatTime(createdAt);
		}
		
		public function set date(date:String):void
		{
		}
		
		// Answer the type of object that was changed.
		public function get objectType():String
		{
			switch (auditableType)
			{
				case 'StoryAttribute': return 'Story Attribute';
				case 'StoryAttributeValue': return 'Story Attribute Value';
				default: return auditableType;
			}
		}
		
		public function set objectType(type:String):void
		{
		}
	}
}