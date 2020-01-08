#!/bin/bash

export PSR_TEST_STORAGE="/tmp/.psr_test_storage"

test_add_one() {
	echo "" > "$PSR_TEST_STORAGE"

	./psr.sh a qwe rty

	decrypted="$(./psr.sh p)"
	echo "$decrypted"
	if [[ $decrypted != "0 qwe rty" ]]; then
		exit 1
	fi
}

test_add_multiple() {
	echo "" > "$PSR_TEST_STORAGE"

	./psr.sh a qwe rty
	./psr.sh a sdasd

	decrypted="$(./psr.sh p)"
	echo "$decrypted"
	if [[ $decrypted != "0 qwe rty\\n1 sdasd" ]]; then
		exit 1
	fi
}

test_add_with_tab() {
	echo "" > "$PSR_TEST_STORAGE"

	./psr.sh a qwe		rty
	./psr.sh a "qwe		rty"

	decrypted="$(./psr.sh p)"
	echo "$decrypted"
	if [[ $decrypted != "0 qwe rty\n1 qwe		rty" ]]; then
		exit 1
	fi
}

test_add_one && \
test_add_multiple && \
test_add_with_tab && \
echo "Success"
