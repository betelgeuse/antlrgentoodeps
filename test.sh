#!/bin/bash
for depend in $(find /var/db/pkg/ -name "DEPEND"); do
	echo ${depend}
	output=$(java -cp $(java-config -dp antlr-3):. Main "$(cat ${depend})" 2>&1)
	if [[ "${output}" ]]; then
		echo ${output}
		cat ${depend}
	fi
done
