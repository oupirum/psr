#!/bin/bash

if [[ ! -z $PSR_TEST_STORAGE ]]; then
	STORAGE="$PSR_TEST_STORAGE"
else
	STORAGE="$HOME/.psr_storage_1"
fi

main() {
	if [[ $# -ge 1 ]]; then
		handle_command "$@"
	else
		prompt_command
	fi
}

print_help() {
	echo "Help:"
}

handle_command() {
	# for word in "$@"; do
	# 	echo $word
	# done
	# echo ""
	args=("$@")
	cmd="${args[0]}"
	payload=("${args[@]:1}")

	case $cmd in
		p|print) print_all ;;
		a|add) add_entry "${payload[@]}" ;;

		*) print_help ;;
	esac
}

print_all() {
	read_storage
}

add_entry() {
	data="$*"
	if [[ -z $data ]]; then
		return 0
	fi

	stored_data="$(read_storage)"
	if [[ ! -z $stored_data ]]; then
		count="$(echo "$stored_data" | wc -l | sed -E "s/[[:space:]]+//")"
		write_storage "${stored_data}\n${count} ${data}"
	else
		write_storage "0 $data"
	fi
}

write_storage() {
	data="$1"
	password="qwe"

	encrypt "$password" "$data" > "$STORAGE"
}

read_storage() {
	password="qwe"
	if [[ ! -s $STORAGE ]]; then
		echo "Storage file does not exist" >&2
		return 0
	fi

	decrypt "$password" "$(cat "$STORAGE")"
}

encrypt() {
	password="$1"
	data="$2"

	echo "$data" | openssl enc -e -a -aes-256-cbc -pass "pass:$password"
}

decrypt() {
	password="$1"
	encrypted="$2"
	if [[ -z $encrypted ]]; then
		return 0
	fi

	echo "$encrypted" | openssl enc -d -a -aes-256-cbc -pass "pass:$password"
}



main "$@"
