#!/bin/bash

source ./config.bash

generateMigrationsList()
{
	local working_dir=$1; shift;
	local db_user=$1; shift;
	local db_pass=$1; shift;
	local db_instance=$1; shift;
	local output_file=$1; shift;

	rm -f $output_file
	touch $output_file
	
	pushd . > /dev/null
	
	cd $working_dir/up
	
	for migration in `ls *.sql | sort` 
	do
		local value=`echo "SELECT MIGRATION_NAME FROM MIGRATIONS WHERE MIGRATION_NAME = '$migration';" | sqlplus -s $db_user/$db_pass@$db_instance`
		
		if [[ "$value" =~ "$migration" ]]
		then
			continue
		fi
		
		echo "$migration" >> "../../$output_file"
	done
	
	popd > /dev/null
}

applyMigrations()
{
	local input_file=$1; shift;
	local working_dir=$1; shift;
	local db_user=$1; shift;
	local db_pass=$1; shift;
	local sb_instance=$1; shift;
	local script="";
	
	while read file
	do
		script="${script}
		@\"$working_dir/up/${file}\";
		insert into migrations values ('${file}');
		"
	done < "$input_file"
	
	echo "$script COMMIT;" | sqlplus -s $db_user/$db_pass@$db_instance	

	#printf "$input_file"
	#printf "$script"
	#sqlplus -s $db_user/$db_pass@$db_instance @"$input_file"
}

generateMigrationsList $working_dir $db_user $db_pass $db_instance $migrations_list
applyMigrations $migrations_list $working_dir $db_user $db_pass $db_instance

