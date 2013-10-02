#------------------------------------------------------
# unirand.sh 
# 
# Return some random blurb. 
#-----------------------------------------------------#
WORD="0123456789abcdefghijklmnopqrstuvwxyz"

__RANDOMIZE() {
	LETTERS=( $(echo $1 | \
	tr -s ' ' '_' | \
	sed 's/\(.\)/\1 /g') )

	declare -a NEW_LETTERS
	STRING=""
	RANGE=${#LETTERS[@]}
	C=0	
	for E in ${LETTERS[@]}
	do
		if [ ! -z $NUM ]
		then
			OLDNUM=$NUM
		else
			NUM=$RANDOM
			let "NUM %= $RANGE"
			OLDNUM=-1
		fi

		while [ $NUM -ge $RANGE ] || [ $NUM -eq $OLDNUM ] 
		do
			NUM=$RANDOM
			let "NUM %= $RANGE"
		done
		STRING=${STRING}${LETTERS[$NUM]}
	done

	echo $STRING
}

# Return a full ID.
__GET_UUID() {
	echo $(__RANDOMIZE "$WORD")
}

# Return a six character ID.
__GET_SHORT_UUID() {
	__LOCALUUID=$(__RANDOMIZE "$WORD")
	echo ${__LOCALUUID:(-6)}	
}

# Return a full ID.
__GET_CUUID() {
	__CUUID_LENGTH=$1
	if (( $__CUUID_LENGTH > 35 ))
	then 
		__CUUID_LENGTH="10"
	fi
	__LOCALUUID=$(__RANDOMIZE "$WORD")
	echo ${__LOCALUUID:(-${__CUUID_LENGTH})}	
}
