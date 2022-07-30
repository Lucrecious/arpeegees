class_name PinAction
extends Resource

enum TargetType {
	Single,
}

enum ActionType {
	Physical,
	Magic,
}

export(String) var nice_name := 'Action'
export(String, MULTILINE) var description := ''
export(TargetType) var target_type := TargetType.Single
export(ActionType) var action_type := ActionType.Physical


