#!/bin/bash

EXPECTED_ARGS=2
E_BADARGS=65

if [ $# -lt $EXPECTED_ARGS ]
then
  echo "Using: `basename $0` \"table name\" \"comment\" "
  exit $E_BADARGS
fi

test -d migrations || mkdir migrations
test -d migrations/up || mkdir migrations/up
#test -d migrations/down || mkdir migrations/down

generateHeader()
{
	local header="ALTER SESSION SET CURRENT_SCHEMA = SYSDBA;
	SET SQLBLANKLINES ON
	SET SQLTERMINATOR ';'\n"
	printf "${header}"
}

generateFooter()
{
	printf "COMMIT;\n" 
}

normalizeSeparator()
{
	echo "${1}" | sed 's/:/ / g'
}   

generateBodyUP()
{
	local table_name="${1}" ;shift
	local comment="${1}" ;shift
	local script="CREATE TABLE SYSDBA.$table_name
	(
	${table_name}ID  CHAR(12 BYTE) NOT NULL,
	"
    for i in "${@}"
	do
		local field_description=`normalizeSeparator "${i}"` ;shift
		script="$script ${field_description},\n"  			
	done	

	script="${script%???}
	);
	exec SYSDBA.FB_INSERT_INTO_SECTABLES ('$table_name','${table_name}ID','$comment');";
	printf "$script"
}


generateBodyDOWN()
{
		local sql="DROP TABLE SYSDBA."${1}" CASCADE CONSTRAINTS;\n"
		printf "$sql"
}

filename=$(date +%s)-table-
generateHeader    	   > ./migrations/up/"$filename"up.sql
generateBodyUP "${@}" >> ./migrations/up/"$filename"up.sql
generateFooter        >> ./migrations/up/"$filename"up.sql

#generateHeader    	     > ./migrations/down/"$filename"down.sql
#generateBodyDOWN "${@}" >> ./migrations/down/"$filename"down.sql
#generateFooter   	    >> ./migrations/down/"$filename"down.sql
 


