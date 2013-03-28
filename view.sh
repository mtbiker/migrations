#!/bin/bash

EXPECTED_ARGS=3
E_BADARGS=65

if [ $# -lt $EXPECTED_ARGS ]
then
  echo "Using: `basename $0` \"table name\" \"view name\" \"comment\" "
  exit $E_BADARGS
fi

test -d migrations || mkdir migrations
test -d migrations/up || mkdir migrations/up
#test -d migrations/down || mkdir migrations/down

generateHeader()
{
	header="ALTER SESSION SET CURRENT_SCHEMA = SYSDBA;
	SET SQLBLANKLINES ON
	SET SQLTERMINATOR ';'\n"
	printf "${header}"
}

generateFooter()
{
	printf "COMMIT;\n" 
}

generateBodyUP()
{   
	local table_name="${1}" ;shift
	local comment="${1}" ;shift
	for i in "${@}"
	do
		local view_name=$1 ;shift
        sql="CREATE VIEW SYSDBA.$view_name AS (SELECT * FROM SYSDBA.$table_name);\n"
		sql="$sql exec SYSDBA.FB_INSERT_INTO_SECTABLES ('$view_name','${table_name}ID','$comment');\n"
		printf "$sql"
	done
}                                  



generateBodyDOWN()
{   
	local table_name="${1}" ;shift
	for i in "${@}"
	do
		local view_name=$1 ;shift
		sql="DROP VIEW SYSDBA.$view_name;\n"
		printf "$sql"
	done
} 

filename=$(date +%s)-view-
generateHeader    	   > ./migrations/up/"$filename"up.sql
generateBodyUP "${@}" >> ./migrations/up/"$filename"up.sql
generateFooter        >> ./migrations/up/"$filename"up.sql

#generateHeader    	     > ./migrations/down/"$filename"down.sql
#generateBodyDOWN "${@}" >> ./migrations/down/"$filename"down.sql
#generateFooter   	    >> ./migrations/down/"$filename"down.sql