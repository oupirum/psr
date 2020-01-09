#!/bin/bash

export PSR_TEST_STORAGE="/tmp/.psr_test_storage"

test_add_one() {
	echo "" > "$PSR_TEST_STORAGE"

	./psr.sh a qwe rty

	entries="$(./psr.sh p)"
	echo "$entries"
	if [[ $entries != "[0] qwe rty" ]]; then
		exit 1
	fi
}

test_add_multiple() {
	echo "" > "$PSR_TEST_STORAGE"

	./psr.sh a qwe rty
	./psr.sh a sdasd

	entries="$(./psr.sh p)"
	echo "$entries"
	if [[ $entries != "[0] qwe rty"$'\n'"[1] sdasd" ]]; then
		exit 1
	fi
}

test_add_with_tab() {
	echo "" > "$PSR_TEST_STORAGE"

	./psr.sh a qwe		rty
	./psr.sh a "qwe		rty"

	entries="$(./psr.sh p)"
	echo "$entries"
	if [[ $entries != "[0] qwe rty"$'\n'"[1] qwe		rty" ]]; then
		exit 1
	fi
}

test_delete_by_id() {
	echo "" > "$PSR_TEST_STORAGE"

	./psr.sh a zero zero
	./psr.sh a one
	./psr.sh a two
	./psr.sh d 1

	entries=$(./psr.sh p)
	echo "$entries"
	if [[ $entries != "[0] zero zero"$'\n'"[2] two" ]]; then
		exit 1
	fi
}

test_multiline_entries() {
	echo "" > "$PSR_TEST_STORAGE"

	./psr.sh a zero zero
	./psr.sh a one$'\n'one
	./psr.sh a two

	entries=$(./psr.sh p)
	echo "$entries"
	if [[ $entries != "[0] zero zero"$'\n'"[1] one"$'\n'" one"$'\n'"[2] two" ]]; then
		exit 1
	fi
}

# TODO: test saving same content multiple times

test_add_one && \
test_add_multiple && \
test_add_with_tab && \
test_delete_by_id && \
test_multiline_entries && \
echo "Success"
