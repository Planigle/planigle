// If there's a form, set the focus to the first element.
function set_focus(){
	if (document.forms.length > 0) {
		var form = document.forms[0];
		if (form.length > 0) {
			form.elements[0].focus();
		}
	}
}

// Toggle when expanding under an item in a table.
function toggle_expansion(image_name, body_name) {
	var image = document.getElementById(image_name);
	var body = document.getElementById(body_name);
	if (body.rows.length == 0) {
		image.src = "images/down_arrow.gif";
		image.alt = "Contract";
		return true;
	}
	else {
		image.src = "images/right_arrow.gif";
		image.alt = "Expand"
		while(body.rows.length>0) {
			body.deleteRow(0);
		}
		return false;
	}
}

// Delete an object.
function delete_object(object_name) {
	var object = document.getElementById(object_name);
	object.parentNode.removeChild(object);
}

// Delete two objects.
function delete_objects(object1_name, object2_name) {
	delete_object(object1_name);
	delete_object(object2_name);
}