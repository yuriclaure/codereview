__codereview() {

	__check_updates;

	if __check_parameters "$@"; then
		return
	fi

	__route "$@";
}