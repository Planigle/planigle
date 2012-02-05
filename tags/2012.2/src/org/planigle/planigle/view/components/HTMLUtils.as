package org.planigle.planigle.view.components
{
	public class HTMLUtils
	{
		public static function convertToHTML(string:String):String
		{
			string = string.replace(/</g, "&lt;");
			string = string.replace(/>/g, "&gt;");
			string = string.replace(/(https?:\/\/\S*(?=[\.,;\)](\s|$)))/gi, "<a target='_blank' href='$1'><u>$1</u></a>");
			string = string.replace(/(https?:\/\/\S*[^\.,;\)\s](?=(\s|$)))/gi, "<a target='_blank' href='$1'><u>$1</u></a>");
			string = string.replace(/\r/g, "<br>");
			return string;
		}
	}
}