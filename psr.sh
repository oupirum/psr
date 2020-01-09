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
	local args=("$@")
	local cmd="${args[0]}"
	local payload=("${args[@]:1}")

	case $cmd in
		p|print) print_all ;;
		a|add) add_entry "${payload[@]}" ;;
		d|delete) delete_entry_by_id "${payload[@]}" ;;

		*) print_help ;;
	esac
}

print_all() {
	password="$(request_password "$password")"
	read_storage "$password"
}

add_entry() {
	local data="$*"
	if [[ -z $data ]]; then
		return 0
	fi
	password="$(request_password "$password")"

	data="$(echo "$data" | sed -E "s/^/ /")"

	local entries="$(read_storage "$password")"
	if [[ ! -z $entries ]]; then
		local last_number=$(
			echo "$entries" | \
			grep -E "^\[[[:digit:]]+\]" | \
			tail -n 1 | \
			sed -E "s/^\[([[:digit:]]+)\].*$/\1/"
		)
		if [[ ! $last_number =~ ^[[:digit:]]+$ ]]; then
			echo "Could not parse id of last entry" >&2
			return 1
		fi
		local id=$((last_number+1))
		write_storage "$password" "${entries}"$'\n'"[${id}]${data}"
	else
		local id=0
		write_storage "$password" "[${id}]${data}"
	fi
}

delete_entry_by_id() {
	local delete_id="$1"
	password="$(request_password "$password")"

	local entries="$(read_storage "$password" | grep -E -v "^\[${delete_id}\]")"
	write_storage "$password" "$entries"
}

request_password() {
	local password="$1"
	if [[ -z $password ]]; then
		read -p "Password:" -s password
	fi
	echo "$password"
}

write_storage() {
	local password="$1"
	local data="$2"

	encrypt "$password" "$data" > "$STORAGE"
}

read_storage() {
	local password="$1"

	if [[ ! -s $STORAGE ]]; then
		echo "Storage file does not exist" >&2
		return 0
	fi

	decrypt "$password" "$(cat "$STORAGE")"
}

encrypt() {
	local password="$1"
	local data="$2"

	echo "$data" | openssl enc -e -a -aes-256-cbc -pass "pass:$password"
}

decrypt() {
	local password="$1"
	local encrypted="$2"
	if [[ -z $encrypted ]]; then
		return 0
	fi

	echo "$encrypted" | openssl enc -d -a -aes-256-cbc -pass "pass:$password"
}



main "$@"
