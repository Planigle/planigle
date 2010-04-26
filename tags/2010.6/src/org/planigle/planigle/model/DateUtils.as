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
		
		// Strip off the time from a date.
		public static function toDate(date:Date):Date
		{
			return new Date(date.fullYear, date.month, date.date, 0, 0, 0, 0);
		}

		// Answer a date that represents today.
		public static function today():Date
		{ // For some reason, the dates come across as 7 pm from RubyAMF.
			var today:Date = new Date();
			today.hours = 19;
			today.minutes = 0;
			today.seconds = 0;
			today.milliseconds = 0;
			return today;
		}
		
		// Answer whether the two dates are equal.
		public static function equals(date1:Date, date2:Date):Boolean {
			return (date1 == null || date2 == null) ? date1 == date2 : (date1.fullYear == date2.fullYear && date1.month == date2.month && date1.date == date2.date);
		}
		
		// Answer whether the first date is less than the second one.
		public static function lessThan(date1:Date, date2:Date):Boolean {
			date1 = toDate(date1);
			date2 = toDate(date2);
			return date1 < date2;
		}
		
		// Answer whether the first date is less or equals to the second one.
		public static function lessThanOrEquals(date1:Date, date2:Date):Boolean {
			date1 = toDate(date1);
			date2 = toDate(date2);
			return date1 < date2 || equals(date1, date2);
		}
		
		// Answer whether the first date is greater than the second one.
		public static function greaterThan(date1:Date, date2:Date):Boolean {
			date1 = toDate(date1);
			date2 = toDate(date2);
			return date1 > date2;
		}
		
		// Answer whether the first date is greater than or equal to the second one.
		public static function greaterThanOrEquals(date1:Date, date2:Date):Boolean {
			date1 = toDate(date1);
			date2 = toDate(date2);
			return date1 > date2 || equals(date1, date2);
		}
	}
}