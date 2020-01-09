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
	args=("$@")
	cmd="${args[0]}"
	payload=("${args[@]:1}")

	case $cmd in
		p|print) print_all ;;
		a|add) add_entry "${payload[@]}" ;;
		d|delete) delete_entry_by_id "${payload[@]}" ;;

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

	entries="$(read_storage)"
	if [[ ! -z $entries ]]; then
		last_number=$(echo "$entries" | tail -n 1 | sed -E "s/^\[([[:digit:]]+)\][[:space:]].*$/\1/")
		if [[ ! $last_number =~ ^[[:digit:]]+$ ]]; then
			echo "Could not parse id of last entry" >&2
			return 1
		fi
		id=$((last_number+1))
		write_storage "${entries}"$'\n'"[${id}] ${data}"
	else
		id=0
		write_storage "[${id}] ${data}"
	fi
}
# TODO: allow multiline entries

delete_entry_by_id() {
	delete_id="$1"

	entries="$(read_storage)"
	entries="$(echo "$entries" | grep -E -v "^\[${delete_id}\][[:space:]]")"
	write_storage "$entries"
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
