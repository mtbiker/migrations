#!/bin/bash

EXPECTED_ARGS=4
E_BADARGS=65

if [ $# -lt $EXPECTED_ARGS ]
then
  echo "Using: `basename $0` \"table name\" \"field name\" \"field description\"  \"comment\" "
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
	printf "COMMIT;\n" # 
}

generateBodyUP()
{   
	local table_name="${1}" ;shift
	local field_name="${1}" ;shift
	local field_description="${1}";shift
	
	for i in "${@}"		
	do
		sql="ALTER TABLE SYSDBA.$table_name ADD "${field_name}" "${field_description}";\n"	
		local comment="${1}";shift
		sql="$sql exec SYSDBA.FB_ADD_FIELD_ST_DESC ('$table_name', '$field_name', '$field_description', '$comment');\n"
		printf "$sql"
    done
}

generateBodyDOWN()
{   
	local table_name="${1}" ;shift
	for i in "${@}"
	do
		local field_description=`normalizeSeparator "${i}"` ;shift
	    local field_name=`echo $field_description | cut -d' ' -f1` 
	    sql="exec SYSDBA.FB_DROP_FIELD_FROM_SECTABLES ('$table_name', '${field_name}');\n"
		sql="$sql ALTER TABLE SYSDBA.$table_name DROP COLUMN $field_name;\n"
		printf "$sql"
	done
}


filename=$(date +%s)-tablefields-
generateHeader    	   > ./migrations/up/"$filename"up.sql
generateBodyUP "${@}" >> ./migrations/up/"$filename"up.sql
generateFooter        >> ./migrations/up/"$filename"up.sql

#generateHeader    	     > ./migrations/down/"$filename"down.sql
#generateBodyDOWN "${@}" >> ./migrations/down/"$filename"down.sql
#generateFooter   	    >> ./migrations/down/"$filename"down.sql
