package org.planigle.planigle.model
{
	public class DateUtils
	{
		public static const MILLIS_IN_DAY:int = 24*60*60*1000;

		// Convert a Rails date string to a Date.
		public static function stringToDate( st:String ):Date
		{
			try
			{
				st=st.replace(/(\d\d\d\d)-(\d\d)-(\d\d)/, "$1/$2/$3");
				st=st.replace(/T(\d\d):(\d\d):(\d\d)([+\- ])(\d\d):(\d\d)/, " $1:$2:$3 GMT$4$5$6");
				return new Date(st);
			}
			catch(exception:TypeError)
			{
			}		
		return new Date();
		}

		// Format a date object into a reasonable time string (ex., "12/11/07 5:55 pm").
		public static function formatTime( date:Date ):String
		{
			var hours:int = date.hours > 11 ? date.hours - 12 : date.hours;
			if (hours == 0) hours = 12;
			var m:String = date.hours > 11 ? " pm" : " am"
			return formatDate(date) + " " + hours + ":" + (date.minutes < 10 ? "0" : "") + date.minutes + m;
		}

		// Format a date object into a reasonable date string (ex., "12/11/07").
		public static function formatDate( date:Date ):String
		{
			return (date.month + 1) + "/" + date.date + "/" + date.fullYear;
		}
	}
}