#!/bin/bash

export PSR_TEST_STORAGE="/tmp/.psr_test_storage"

test_add_one() {
	echo "" > "$PSR_TEST_STORAGE"

	./psr.sh a qwe rty <<< passw

	entries="$(./psr.sh p <<< passw)"
	read -d '' expect <<-EOF
		[0] qwe rty
		-------------------------------------
	EOF
	echo "$entries"
	if [[ $entries != "$expect" ]]; then
		exit 1
	fi
}

test_add_multiple() {
	echo "" > "$PSR_TEST_STORAGE"

	./psr.sh a qwe rty <<< passw
	./psr.sh a sdasd <<< passw

	entries="$(./psr.sh p <<< passw)"
	read -d '' expect <<-EOF
		[0] qwe rty
		-------------------------------------
		[1] sdasd
		-------------------------------------
	EOF
	echo "$entries"
	echo "$expect"
	if [[ $entries != "$expect" ]]; then
		exit 1
	fi
}

test_add_with_tab() {
	echo "" > "$PSR_TEST_STORAGE"

	./psr.sh a qwe		rty <<< passw
	./psr.sh a "qwe		rty" <<< passw

	entries="$(./psr.sh p <<< passw)"
	read -d '' expect <<-EOF
		[0] qwe rty
		-------------------------------------
		[1] qwe		rty
		-------------------------------------
	EOF
	echo "$entries"
	echo "$expect"
	if [[ $entries != "$expect" ]]; then
		exit 1
	fi
}

test_delete_by_id() {
	echo "" > "$PSR_TEST_STORAGE"

	./psr.sh a zero zero <<< passw
	./psr.sh a one <<< passw
	./psr.sh a two <<< passw
	./psr.sh d 1 <<< passw

	entries=$(./psr.sh p <<< passw)
	read -d '' expect <<-EOF
		[0] zero zero
		-------------------------------------
		[2] two
		-------------------------------------
	EOF
	echo "$entries"
	echo "$expect"
	if [[ $entries != "$expect" ]]; then
		exit 1
	fi
}

test_multiline_entries() {
	echo "" > "$PSR_TEST_STORAGE"

	./psr.sh a zero zero <<< passw
	./psr.sh a one$'\n'one <<< passw
	./psr.sh a two <<< passw

	entries=$(./psr.sh p <<< passw)
	read -d '' expect <<-EOF
		[0] zero zero
		-------------------------------------
		[1] one
		 one
		-------------------------------------
		[2] two
		-------------------------------------
	EOF
	echo "$entries"
	echo "$expect"
	if [[ $entries != "$expect" ]]; then
		exit 1
	fi
}

test_add_interactive() {
	echo "" > "$PSR_TEST_STORAGE"

	./psr.sh <<-EOF
		a zero
		passw
		a one one
		q
	EOF

	entries=$(./psr.sh p <<< passw)
	read -d '' expect <<-EOF
		[0] zero
		-------------------------------------
		[1] one one
		-------------------------------------
	EOF
	echo "$entries"
	echo "$expect"
	if [[ $entries != "$expect" ]]; then
		exit 1
	fi
}

test_add_interactive_with_print() {
	echo "" > "$PSR_TEST_STORAGE"

	output="$(
		./psr.sh <<-EOF
			a zero
			passw
			a one one
			a two
			d 1
			p
			q
		EOF
	)"

	read -d '' expect <<-EOF
		Added entry with id 0

		Added entry with id 1

		Added entry with id 2

		Deleted entry: "[1] one one"

		[0] zero
		-------------------------------------
		[2] two
		-------------------------------------
	EOF
	echo "$output"
	echo "$expect"
	if [[ $output != "$expect" ]]; then
		exit 1
	fi
}

test_delete_multiline() {
	echo "" > "$PSR_TEST_STORAGE"

	./psr.sh a zero <<< passw
	./psr.sh a one$'\n'qwe$'\n'rty <<< passw
	./psr.sh d 1 <<< passw

	entries=$(./psr.sh p <<< passw)
	read -d '' expect <<-EOF
		[0] zero
		-------------------------------------
	EOF
	echo "entries"
	echo "$expect"
	if [[ $entries != "$expect" ]]; then
		exit 1
	fi
}

# TODO: test saving same content multiple times

test_add_one && echo "Done" && \
test_add_multiple && echo "Done" && \
test_add_with_tab && echo "Done" && \
test_delete_by_id && echo "Done" && \
test_multiline_entries && echo "Done" && \
test_add_interactive && echo "Done" && \
test_add_interactive_with_print && echo "Done" && \
test_delete_multiline && echo "Done" && \
echo "Success"
