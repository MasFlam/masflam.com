#!/bin/sh

[ -d output ] && rm -rf output
cp -r site output

find output -type f \! -regex '.*\.temp$' | while IFS='' read -r fname
do
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
				[ -f "$f" ] && cat "$f" >> "$fname".temp
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
	mv "$fname".temp "$fname"
done
