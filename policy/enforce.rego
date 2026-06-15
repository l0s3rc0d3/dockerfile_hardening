package policy

# Helper: check if the APP_ARGS variable is defined in ENV
has_app_args if {
	input[i].Cmd == "env"
	input[i].Value[0] == "APP_ARGS"
}

# 1a. PRESENCE CHECK: Verify that APP_ARGS environment variable exists
deny contains msg if {
	not has_app_args
	msg := "Policy Violation: The required environment variable 'APP_ARGS' is missing entirely from the Dockerfile."
}

# 1b. CONTENT CHECK: Verify that APP_ARGS contains parameters starting with '--'
deny contains msg if {
	input[i].Cmd == "env"
	input[i].Value[0] == "APP_ARGS"
	val := input[i].Value[1]
	not contains(val, "--")
	msg := sprintf("Policy Violation: The environment variable '%v' must contain parameters starting with '--'", [input[i].Value[0]])
}

# 2. FORMAT CHECK: Verify ENTRYPOINT uses JSON array format (exec form)
deny contains msg if {
	input[i].Cmd == "entrypoint"
	input[i].JSON == false
	msg := "Policy Violation: ENTRYPOINT must use JSON array format (exec form), e.g., ENTRYPOINT [\"sh\", \"-c\", ...]."
}

# 3. SHELL CHECK: Verify ENTRYPOINT (exec form) invokes 'sh -c' correctly
deny contains msg if {
	input[i].Cmd == "entrypoint"
	input[i].JSON == true
	not input[i].Value[0] == "sh"
	msg := "Policy Violation: ENTRYPOINT must use 'sh' as the first argument in the JSON array."
}

deny contains msg if {
	input[i].Cmd == "entrypoint"
	input[i].JSON == true
	not input[i].Value[1] == "-c"
	msg := "Policy Violation: ENTRYPOINT must use '-c' as the second argument in the JSON array."
}

# 4a. CONTENT CHECK: Verify ENTRYPOINT contains the compiled binary path anywhere
deny contains msg if {
	input[i].Cmd == "entrypoint"
	full_cmd := concat(" ", input[i].Value)
	pos_binary := indexof(full_cmd, "/usr/local/bin/mybinary")
	pos_binary == -1
	msg := "Policy Violation: ENTRYPOINT must execute the compiled binary '/usr/local/bin/mybinary'."
}

# 4b. CONTENT CHECK: Verify ENTRYPOINT contains the $APP_ARGS token anywhere
deny contains msg if {
	input[i].Cmd == "entrypoint"
	full_cmd := concat(" ", input[i].Value)
	pos_args := indexof(full_cmd, "$APP_ARGS")
	pos_args == -1
	msg := "Policy Violation: ENTRYPOINT must pass the '$APP_ARGS' environment variable to the binary."
}

# 4c. SEQUENCE CHECK: Verify $APP_ARGS comes AFTER the binary path
deny contains msg if {
	input[i].Cmd == "entrypoint"
	full_cmd := concat(" ", input[i].Value)

	pos_binary := indexof(full_cmd, "/usr/local/bin/mybinary")
	pos_args := indexof(full_cmd, "$APP_ARGS")

	pos_binary != -1
	pos_args != -1
	pos_binary > pos_args
	msg := "Policy Violation: In ENTRYPOINT, '$APP_ARGS' must be placed AFTER the binary path '/usr/local/bin/mybinary'."
}
