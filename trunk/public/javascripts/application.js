/* Change the status of a story or task.*/
function changeStatus(url, newValue) {
	var reason = newValue == 2 ? prompt("Reason for blockage") : "";
	new Ajax.Request(url, {method:'post',parameters:{_method:'put','record[status_code]':newValue,'record[reason_blocked]':reason}})
}
