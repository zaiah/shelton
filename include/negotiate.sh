#------------------------------------------------------
# negotiate 
# 
# Search to see if a string matches.
#-----------------------------------------------------#

# Do more var setting.
# Awk may be more appropiate.
__SET_CLAUSE() {
	for TERM in $( _break_list $1 )
	do
		BLOCK=( $( _break_once $TERM	":") )
		case ${BLOCK[0]} in
			d|de|des|desc|descr|descri|descrip|\
			descript|descripti|descriptio|description)
				CONSTANT="description"
			;;
			n|na|nam|name)
				CONSTANT="name"
			;;
			f|'fi'|fil|file)	
				CONSTANT="file"
			;;
			i|id)
				CONSTANT="id"
			;;
			*)
				echo "Error: Unrecognized identifier '${BLOCK[0]}'"
			;;
		esac

		# Dynamically generate a long query.
		VALUE="${BLOCK[1]}" 
		OPERATOR="="

		# Check operators.
		test -z $WHERE && WHERE="WHERE" || WHERE="AND"
		[[ $CONSTANT = "id" ]] && VALUE="${BLOCK[1]}%" && OPERATOR="LIKE"

		QUERY="$QUERY $WHERE $CONSTANT $OPERATOR '$VALUE'"
	done
	echo $QUERY
}
