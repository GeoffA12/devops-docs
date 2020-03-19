#! /bin/bash
echo "Welcome to the team22 mysql program."
# Print user menu
echo -e "1. Update column in existing table\n2. Add new column in existing table\n3. Delete column in existing table\n4. View contents of table column (Select *)\n5. Rename a column in a table\n6. Query a table using SELECT params\n"
#Constants
dbName="team22supply"

# Subroutines
updateColumn () {
	read -p 'Enter the table name where the column exists: ' tableName
	read -p 'Enter the name of the column AND new data type of column AND any other info (separate with spaces): ' columnChange
	echo "use $dbName; alter table $tableName modify $columnChange"
	mysql -e "use $dbName; alter table $tableName modify $columnChange"
	getDescFromTable $tableName
	return
}

addColumn () {
	read -p 'Enter the table name where you want to add new column: ' tableName
	read -p 'Enter the name of new column AND data type AND any other info (separate with spaces): ' columnAdd
	echo "use $dbName; alter table $tableName $columnAdd"
	mysql -e "use $dbName; alter table $tableName add $columnAdd"
	getDescFromTable $tableName
	return
}

deleteColumn () {
	read -p 'Enter the table name where you want to delete column: ' tableName
	read -p 'Enter the column name you want to delete: ' columnName
	echo "use $dbName; alter table $tableName drop column $columnName"
	mysql -e "use $dbName; alter table $tableName drop column $columnName"
	getDescFromTable $tableName
	return
}

selectTableData () {
	read -p 'Enter the table you wish to select * from: ' tableName
	mysql -e "use $dbName; select * from $tableName"
	return
}

renameColumn() {
	read -p 'Enter the table where you want to rename a column: ' tableName
	read -p 'Enter the old name FOLLOWED BY new name of the column (separate with space): ' oldColumn newColumn
	echo "use $dbName; alter table $tableName rename column $oldColumn to $newColumn"
	mysql -e "use $dbName; alter table $tableName rename column $oldColumn to $newColumn"
	getDescFromTable $tableName
}

queryTableUsingSelect() {
	read -p 'Enter the select statement here: ' query
	echo "use $dbName; $query"
	mysql -e "use $dbName; $query"
	return
}

getDescFromTable () {
	table=$1
	mysql -e "use $dbName; describe $table"
	return
}

# Initialize loop invariant
end=6
start=1
userSelection=$start
while (( userSelection >= start )) && (( userSelection <= end))
do
	read -p 'Enter an number between 1 and 6: ' userSelection
	echo "Your number was equal to $userSelection"
	if (( userSelection == 1 )); then
		updateColumn

	elif (( userSelection == 2 )); then
		addColumn

	elif (( userSelection == 3 )); then
		deleteColumn

	elif (( userSelection == 4 )); then
		selectTableData

	elif (( userSelection == 5 )); then
		renameColumn

	elif (( userSelection == 6 )); then
		queryTableUsingSelect

	else
		echo "Goodbye!"
	fi

done

