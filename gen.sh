#!/bin/sh

errfile=output/errs.$$.temp

log() {
	echo '[gen.sh]' "$@"
}

err() {
	log '   ERROR:' "$@"
	echo err >> "$errfile"
}

[ -d output ] && log 'Removing output dir' && rm -rf output
log 'Copying over site to output'
cp -r site output

touch "$errfile"

find output -type f \! -regex '.*\.temp$' | while IFS='' read -r fname
do
	log 'Processing' "${fname#output/}"
	state=normal
	while IFS='' read -r line
	do
		case "$state" in
		normal)
			if [ "$line" = '###codeblock start' ]
			then
				state=codeblock
				echo "<div class=codeblock><pre>" >> "$fname".temp
			elif [ "${line%% *}" = '###include' ]
			then
				f=res/"${line#\#\#\#include }"
				if [ -f "$f" ]
				then
					cat "$f" >> "$fname".temp
				else
					err 'File' "$f" 'not found'
				fi
			elif [ "${line%% *}" != '###ignore' ]
			then
				echo "$line" >> "$fname".temp
			fi
		;;
		codeblock)
			if [ "$line" = '###codeblock end' ]
			then
				state=normal
				echo "</pre></div>" >> "$fname".temp
			else
				if [ -n "$line" ]
				then
					l="$(echo "$line" | sed 's/</\&lt;/g;s/>/\&gt;/g')"
				else
					l=''
				fi
				echo "$l" >> "$fname".temp
			fi
		;;
		esac
	done < "$fname"
	log 'Processed' "${fname#output/}"
	mv "$fname".temp "$fname"
done


log 'Generation done.' "$(wc -l "$errfile" | cut -d' ' -f 1)" 'errors occurred.'
rm "$errfile"

[ -f website.tar.gz ] && log 'Removing website.tar.gz' && rm website.tar.gz
log 'Packing output dir into website.tar.gz'
tar -czf website.tar.gz output
