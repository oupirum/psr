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
		while true; do
			prompt_command
			echo ""
		done
	fi
}

print_help() {
	cat <<-EOF
		Available commands:
		  a <value>       - add new entry
		  add <value>       - long form

		  d <N>           - delete entry with id N
		  rm <N>
		  delete <N>
		  remove <N>

		  p               - print all entries
		  print

		  s <somestr>     - search entries by given substring (or extended regex pattern)
		  search <somestr>

		  chpass          - change encryption key

		  q               - quit
		  quit
		  exit
	EOF
}

prompt_command() {
	local command
	read -e -p "Command: > " command
	handle_command $command
}

handle_command() {
	local args=("$@")
	local cmd="${args[0]}"
	local payload=("${args[@]:1}")

	case $cmd in
		p|print) print_all ;;
		a|add) add_entry "${payload[@]}" ;;
		d|rm|delete|remove) delete_entry_by_id "${payload[@]}" ;;
		s|search) search "${payload[@]}" ;;
		chpass) change_password ;;
		q|quit|exit) exit 0 ;;

		h|help) print_help ;;
		*) print_help ;;
	esac
}

print_all() {
	password="$(request_password "$password")"
	read_storage "$password"
	if [[ $? != 0 ]]; then
		password=""
		echo "Could not decrypt data" >&2
		return 1
	fi
}

add_entry() {
	local data="$*"
	if [[ -z $data ]]; then
		echo "Specify content to add" >&2
		return 1
	fi
	password="$(request_password "$password")"

	data="$(echo "$data" | sed -E "s/^/ /")"
	data="$data"$'\n'-------------------------------------

	local entries
	entries="$(read_storage "$password")"
	if [[ $? != 0 ]]; then
		password=""
		echo "Could not decrypt data" >&2
		return 1
	fi

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

	[[ $? == 0 ]] && echo "Added entry with id $id"
}

delete_entry_by_id() {
	local delete_id="$1"
	if [[ ! $delete_id =~ ^[[:digit:]]+$ ]]; then
		echo "Specify entry id" >&2
		return 1
	fi
	password="$(request_password "$password")"

	local entries
	entries="$(read_storage "$password")"
	if [[ $? != 0 ]]; then
		password=""
		echo "Could not decrypt data" >&2
		return 1
	fi

	local delete_entry="$(
		echo "$entries" | \
		sed -En "/^\[${delete_id}\].*/,/^---.*/ p" | \
		sed "$ d"
	)"
	if [[ ! -z $delete_entry ]]; then
		local entries="$(
			echo "$entries" | \
			sed -E "/^\[${delete_id}\].*/,/^---.*/ d"
		)"
		write_storage "$password" "$entries"

		[[ $? == 0 ]] && echo "Deleted entry: \"${delete_entry}\""
	else
		echo "Not found"
	fi
}

search() {
	query="$1"
	if [[ -z $query ]]; then
		echo "Specify search query" >&2
		return 1
	fi
	password="$(request_password "$password")"

	local entries
	entries="$(read_storage "$password")"
	if [[ $? != 0 ]]; then
		password=""
		echo "Could not decrypt data" >&2
		return 1
	fi

	local entry=""
	while IFS= read -r line; do
		entry="${entry}${line}"$'\n'
		if [[ ! -z $(echo "$line" | grep -E "^---") ]]; then
			if [[ ! -z $(echo "$entry" | grep -E "$query") ]]; then
				echo -n "$entry"
			fi
			entry=""
		fi
	done <<< "$entries"
}

change_password() {
	local old_password="$(request_password "")"
	local new_password="$(request_password "")"

	local entries
	entries="$(read_storage "$old_password")"
	if [[ $? != 0 ]]; then
		password=""
		echo "Could not decrypt data" >&2
		return 1
	fi

	write_storage "$new_password" "$entries"
}

request_password() {
	local password="$1"
	if [[ -z $password ]]; then
		read -p "Password: > " -s password
		echo "" >&2
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

	encrypted="$(cat "$STORAGE")"
	decrypt "$password" "$encrypted"
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

	local data
	data="$(echo "$encrypted" | openssl enc -d -a -aes-256-cbc -pass "pass:$password")"

	[[ $? == 0 ]] && echo "$data"
}



main "$@"
