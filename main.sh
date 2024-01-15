#!/bin/bash
LC_COLLATE=C #Terminal case sensitive
shopt -s extglob #enable special pattern

export PS3="Hello User>>"
pwd=$(pwd)
while true; do
    select choice in "Create Database" "List Database" "Drop Database" "Connect Database" "Exit"
    do
        case $REPLY in 
            1 ) echo "=============================Create New DB=========================="
                while true; do
                    read -p "Enter name of DB : " name
                    name=$(echo $name | tr ' ' '_')
                    if [[ $name =~ ^[a-zA-Z]+[-_a-zA-Z0-9]*$ ]]; then 
                        if [ -d "$pwd/.db/$name" ]; then
                            echo "DB already exists"
                        else
                            echo "DB FOLDER CREATED "
                            mkdir -p "$pwd/.db/$name"
                            chmod 777 "$PWD/.db/$name"
                            cd "$pwd/.db/$name" || exit 1
                            PS3="$name>>"
                            break
                        fi   
                    else 
                        echo "Invalid name of DB, please try again!"
                    fi
                done
                ;;
            2 ) #list all existing DB
                echo "=============================List DB============================="
                ls -F "$pwd/.db" | tr '/' ' '
                ;;
            3 )
                echo "=============================Drop DB============================="
                read -p "Enter name of DB you want to drop: " name
                if [[ $name =~ ^[a-zA-Z]+[-_a-zA-Z0-9]*$ ]]; then 
                    if [ -d "$pwd/.db/$name" ]; then
                        rm -r "$pwd/.db/$name"
                        echo "DB $name Dropped!"
                    else
                        echo "DB doesn't Exist"
                    fi   
                else 
                    echo "Invalid name of DB, please try again!"
                fi
                ;;
            4 )
                echo "=============================Connect DB============================="
                read -p "Enter name of DB : " name
                if [[ $name =~ ^[a-zA-Z]+[-_a-zA-Z0-9]*$ ]]; then 
                    if [ -d "$pwd/.db/$name" ]; then
                        cd "$pwd/.db/$name" || exit 1
                        echo "Entered DB $name"
                        PS3="$name>> "
                        while true; do
                            select choice in "Create Table" "Drop Table" "Insert into Table" "Select From Table" "Delete Table Data" "Update Table Data" "Return to Main Menu"
                            do 
                                case $REPLY in
                                    1 )
                                        echo "=============================Create Table============================="
                                        read -p "the name of table : " tableName

                                        if [[ $tableName =~ ^[a-zA-Z]+[-_a-zA-Z0-9]*$ ]]; then 
                                            if [ ${#tableName} -gt 20 ]; then
                                                echo "table name exceeds the maximum length of 20 characters. Please enter a shorter name."
                                            else
                                                tableName=$(echo "$tableName" | tr ' ' '_')
                                                touch "$tableName"
                                                chmod 777 "$tableName"
                                                PS3="You Are Inside Table>>"
                                                read -p "Enter number of columns : " num_col
                                                echo "WARNING: The First Column Entry Will Be The PK"

                                                metaDataArrTemp=()
                                                dataTypeArrTemp=()

                                                for ((idx=1; idx<=$num_col; idx++)); do 
                                                    while true; do
                                                        read -p "Enter column $idx name: " colName
                                                        if [ -z "$colName" ]; then
                                                            echo "Column name cannot be empty. Please try again!"
                                                        elif [ ${#colName} -gt 20 ]; then
                                                            echo "Column name exceeds the maximum length of 20 characters. Please enter a shorter name."
                                                        elif [[ $colName =~ ^[a-zA-Z]+[-_a-zA-Z0-9]*$ ]]; then 
                                                            metaDataArrTemp+=("$colName")
                                                            break
                                                        else 
                                                            echo "invalid column name! please try again"
                                                        fi
                                                    done
                                                    
                                                    while true; do
                                                        read -p "Enter DataType of column $idx: " colType
                                                        if [ -z "$colType" ]; then
                                                            echo "Column Data Type cannot be empty. Please try again!"
                                                        elif [ "$colType" = "string" ] || [ "$colType" = "int" ]; then
                                                            dataTypeArrTemp+=("$colType")
                                                            break
                                                        else
                                                            echo "Invalid data type. Please enter 'string' or 'int' only."
                                                        fi
                                                    done
                                                done
                                            
                                            # separate each one of the arrays columns with a :
                                            joinedMD=$(IFS=:; echo "${metaDataArrTemp[*]}")
                                            joinedDT=$(IFS=:; echo "${dataTypeArrTemp[*]}")

                                            # append the columns to the file which is named tableName
                                            echo "$joinedMD" >> "$tableName"
                                        
                                        
                                            echo "$joinedDT" >> "$tableName"
                                            fi
                                        else
                                             echo "Invalid  name of table name"   
                                        fi
                                        ;;
                                    2 )
                                        echo "=============================Drop Table=============================" #drop table file 
                                        read -p "Enter the name of file : " tellTableName
                                        rm -r "$pwd/.db/$name/$tableName/$tellTableName" 
                                        
                                        ;;
                                    3 )
                                        echo "=============================Insert into Table============================="

                                        is_string() {
                                            local value="$1"

                                            # Check if it's a string
                                            if [[ $value =~ ^[a-zA-Z]+[-_a-zA-Z]*$ ]]; then
                                                return 0  # It's a string 
                                            else
                                                return 0  # It's not a string 
                                            fi
                                        }
                                        is_integer() {
                                            local value="$1"
                                            if [[ $value =~ ^[0-9]+$ ]]; then
                                                return 0  # It's an integer
                                            else
                                                return 1  # It's not an integer
                                            fi
                                        }

                                        read -p "Enter the name of the table : " tellTableName
                                        file_path="$PWD/$tellTableName"
                                        tempArrForMeta=()
                                        tempArrForDT=()
                                        
                                        tempArrForEntries=()
                                        if [ -f $file_path ]; then 

                                            IFS=':' read -r -a metaDataArr < <(head -n 1 "$file_path")
                                            IFS=':' read -r -a dataTypeArr < <(awk -F':' 'NR==2 {print}' "$file_path")
                                    
                                            array_size=${#metaDataArr[@]}
                                            echo "metaDataArr : ${metaDataArr[@]}"
                                            echo "dataTypeArr : ${dataTypeArr[@]}"
                                            # echo "array size : $array_size"

                                            # Enforce uniqueness and non-emptiness for the first column
                                            while true; do
                                                read -p "Enter the value for the first column (unique and non-empty) PK: " value_in_insert
                                                echo "value_in_insert : $value_in_insert"

                                                # Validate if it's non-empty, unique, and of valid type
                                                if [ -n "$value_in_insert" ] && ! grep -q "^$value_in_insert:" "$file_path"; then
                                                    if [ "${dataTypeArr[0]}" == "int" ] && is_integer "$value_in_insert"; then
                                                        if [ ${#value_in_insert} -le 30 ]; then
                                                            tempArrForEntries+=("$value_in_insert")
                                                            break
                                                        else
                                                            echo "Invalid entry. The value must be of type ${dataTypeArr[0]} and should not exceed 30 characters. Please try again!"
                                                        fi
                                                    elif [ "${dataTypeArr[0]}" == "string" ] && is_string "$value_in_insert"; then
                                                        if [ ${#value_in_insert} -le 30 ]; then
                                                            tempArrForEntries+=("$value_in_insert")
                                                            break
                                                        else
                                                            echo "Invalid entry. The value must be of type ${dataTypeArr[0]} and should not exceed 30 characters. Please try again!"
                                                        fi
                                                    else
                                                        echo "Invalid entry. The value must be of type ${dataTypeArr[0]}. Please try again!"
                                                    fi
                                                else
                                                    echo "Invalid entry. The value must be non-empty and unique. Please try again!"
                                                fi
                                            done


                                            for idx in $(seq 1 $((array_size - 1)))
                                            do 
                                                while true; do
                                                    read -p "Enter the value of ${metaDataArr[$idx]}: " value_in_insert
                                                    echo "value_in_insert : $value_in_insert"
                                                    
                                                    if [ "${dataTypeArr[$idx]}" == "int" ]; then
                                                        if is_integer "$value_in_insert" ; then
                                                            if [ ${#value_in_insert} -le 30 ]; then
                                                                tempArrForEntries+=("$value_in_insert")
                                                                break
                                                            else
                                                                echo "Invalid entry. The value must be of type ${dataTypeArr[0]} and should not exceed 30 characters. Please try again!"
                                                            fi
                                                        else 
                                                            echo "Invalid entry, please try again!" 
                                                        fi
                                                    fi

                                                    if [ "${dataTypeArr[$idx]}" == "string" ]; then
                                                        if is_string "$value_in_insert" ; then
                                                            if [ ${#value_in_insert} -le 30 ]; then
                                                                tempArrForEntries+=("$value_in_insert")
                                                                break
                                                            else
                                                                echo "Invalid entry. The value must be of type ${dataTypeArr[0]} and should not exceed 30 characters. Please try again!"
                                                            fi
                                                        else 
                                                            echo "Invalid entry, please try again!" 
                                                        fi
                                                    fi
                                                done
                                                echo "arr of entries : $tempArrForEntries"
                                            done

                                            joinedmetaDATAarr=$(IFS=:; echo "${tempArrForEntries[*]}")
                                            echo "$joinedmetaDATAarr" >> "$file_path"
                                            # Add a newline character to separate rows
                                            # echo "" >> "$file_path"

                                            echo "Data inserted into $tellTableName successfully."
                                            # echo "array size : $array_size"
                                            echo "result : $joinedmetaDATAarr"
                                        else
                                            echo "table name is not existed"
                                        fi
                                    
                                        # ...

                                        # for idx in $(seq 0 $((array_size - 1))); do
                                        #     echo -n "${tempArrForEntries[$idx]}:" >> "$file_path"
                                        # done
                                        
                                    ;;
                                    4) echo "=============================Select from Table============================="
                                        select choice in "select all" "select specific column" "select specific record"
                                        do 
                                            case $REPLY in
                                            1 ) echo "=============================Select All============================="
                        
                                                read -p "Enter the name of file : " tellTableName
                                                cat "$PWD/$tellTableName" | tail -n +3 
                                                echo "Select All DONE!"
                                            ;;
                                            2 ) echo "=============================Select Specific Column============================="
                                                read -p "Enter the name of file : " tellTableName
                                                echo "select specific column"
                                                read -p "Enter the column name of file : " columnName
                                                col_index=$(head -n 1 "$PWD/$tellTableName"| tr ':' '\n' | grep -n "^$columnName$" | cut -d':' -f1)
                                                if [ -n "$col_index" ]; then
                                                    # Skip the first two lines and then extract the specified column
                                                    tail -n +3 "$PWD/$tellTableName" | cut -d ':' -f "$col_index"
                                                else
                                                    echo "Column '$columnName' not found in file '$tellTableName'"
                                                fi 

                                            ;;
                                            3 ) echo "=============================Select Specific Record============================="
                                                read -p "Enter the table name: " tellTableName

                                                # Construct the file path
                                                file_path="$PWD/$tellTableName"

                                                echo $file_path

                                                # Check if the file exists
                                                if [ -f "$file_path" ]; then
                                                    read -p "Enter the column name and value (column=value): " input_criteria

                                                    # Split the user input into column and value
                                                    IFS='=' read -r -a criteria <<< "$input_criteria"
                                                    columnN="${criteria[0]}"
                                                    value="${criteria[1]}"
                                                    col_index=$(head -n 1 "$file_path" | tr ':' '\n' | grep -n "^$columnN$" | cut -d':' -f1)

                                                    check_value=($(awk -v col="$col_index" -F':' 'NR > 2 {print $col}' "$file_path")) # store every nth value of each row

                                                    echo "columnN : $columnN"
                                                    echo "value : $value"
                                                    echo "col_index : $col_index"
                                                    echo "check value : ${check_value[@]}"

                                                    for val in "${check_value[@]}"; do
                                                        if [ "$val" == "$value" ]; then
                                                            selected_record=$(awk -F':' -v column="$col_index" -v value="$value" '
                                                                {
                                                                    if ($column == value) {
                                                                        print;
                                                                        exit;
                                                                    }
                                                                }
                                                            ' "$file_path")

                                                            echo "Record details for the specified criteria:"
                                                            echo "$selected_record"
                                                            break  # Exit the loop after finding a match
                                                        fi
                                                    done

                                                    if [ -z "$selected_record" ]; then
                                                        echo "No record found for the specified criteria."
                                                    fi
                                                else
                                                    echo "Error: File not found - $file_path"
                                                fi
                                            ;;
                                            * )
                                            echo "exit"
                                            echo "Back to main menu"
                                            break
                                            ;;
                                            esac
                                        done
                                        ;;
                                    5 ) echo "=============================Delete Table Data============================="
                                        
                                    #Get user input for operation (delete data, column, or row)
                                        read -p "Choose operation (1 for delete data, 2 for delete column data, 3 for delete row): " operation

                                        # Get user input for file name
                                        read -p "Enter the table name: " tableName

                                        # Check if the file exists
                                        if [ -e "$PWD/$tableName" ]; then
                                            case $operation in
                                                1)  echo "=============================Delete Data============================="
                                                    # Read the first two lines (metadata) from the file
                                                    metadata=$(head -n 2 "$PWD/$tableName")

                                                    # Overwrite the file with the metadata
                                                    echo "$metadata" > "$PWD/$tableName"

                                                    echo "Table Data Deleted"
                                                    ;;
                                                2) echo "=============================Delete Column Data============================="
                                                    # Get user input for column name to delete data
                                                    read -p "Enter the column name to delete data: " columnName

                                                    # Find the column index
                                                    index=$(awk -v col="$columnName" -F ":" 'NR==1 {for (i=1; i<=NF; i++) if ($i == col) {print i; exit}}' "$PWD/$tableName")

                                                    if [ -z "$index" ]; then
                                                        echo "Column '$columnName' not found in the table."
                                                    else
                                                        # Delete data in the specified column from each row
                                                        awk -v col="$index" 'BEGIN{FS=OFS=":"} { if (NR>2) $col=""; gsub(/::/, ":"); gsub(/:$/, ""); print $0 }' "$PWD/$tableName" > "$PWD/$tableName.tmp"
                                                        mv "$PWD/$tableName.tmp" "$PWD/$tableName"

                                                        echo "Data in Column '$columnName' Deleted from the Table"
                                                    fi
                                                    ;;
                                                3)  echo "=============================Delete Row Data============================="
                                                    # Get user input for the value in the first column to delete the row
                                                    read -p "Enter the value in the first column to delete the row: " rowValue

                                                    # Delete the row based on the specified value in the first column
                                                    awk -v value="$rowValue" -F ":" '{ if (NR==1 || $1 != value) print $0 }' "$PWD/$tableName" > "$PWD/$tableName.tmp"
                                                    mv "$PWD/$tableName.tmp" "$PWD/$tableName"

                                                    echo "Row with value '$rowValue' Deleted from the Table"
                                                    ;;
                                                *)
                                                    echo "Invalid operation. Please choose 1 for delete data, 2 for delete column data, or 3 for delete row."
                                                    ;;
                                            esac
                                        else
                                            echo "File not found: $PWD/$tableName"
                                        fi
                                        ;;
                                    6)
                                        is_string() {
                                            local value="$1"

                                            # Check if it's a string
                                            if [[ $value =~ ^[a-zA-Z]+[-_a-zA-Z]*$ ]]; then
                                                return 0  # It's a string
                                            else
                                                return 1  # It's not a string
                                            fi
                                        }

                                        is_integer() {
                                            local value="$1"
                                            if [[ $value =~ ^[0-9]+$ ]]; then
                                                return 0  # It's an integer
                                            else
                                                return 1  # It's not an integer
                                            fi
                                        }

                                        echo "==================== Update Table Data ========================="

                                        read -p "Enter the table name: " tellTableName

                                        # Construct the file path
                                        file_path="$PWD/$tellTableName"
                                        if [ -e "$file_path" ]; then
                                            echo "WARNING: you can't update the PK itself which is the first column!"
                                            read -p "Enter the value for the first column (PK): " pk

                                            record_found=false # a flag to check if the record with PK is found

                                            # Select the record which the PK points to
                                            selected_record=$(awk -F':' -v column=1 -v value="$pk" '
                                                NR > 2 {
                                                    if ($column == value) {
                                                        print;
                                                        exit;
                                                    }
                                                }
                                            ' "$file_path")

                                            if [ -n "$selected_record" ]; then
                                                record_found=true
                                                echo "Record details for the PK $pk:"
                                                echo "$selected_record"

                                                read -p "Enter the column name you want to update: " columnNameU

                                                IFS=':' read -r -a dataTypeArrU < <(awk -F':' 'NR==2 {print}' "$file_path")
                                                IFS=':' read -r -a metaDataArrU < <(head -n 1 "$file_path")

                                                if [[ " ${metaDataArrU[@]} " =~ " $columnNameU " ]]; then
                                                    read -p "Enter the new value for $columnNameU: " valueU

                                                    # Check if the column name is valid
                                                    col_index_for_update=$(awk -F':' -v col="$columnNameU" 'NR==1 {for (i=1; i<=NF; i++) if ($i == col) print i}' "$file_path")
                                                    if [ -n "$col_index_for_update" ]; then
                                                        data_type="${dataTypeArrU[col_index_for_update-1]}"
                                                        # Loop until the user enters the correct data type
                                                        while true; do
                                                            # Validate the input based on the data type
                                                            if [ "$data_type" == "int" ]; then
                                                                if is_integer "$valueU"; then
                                                                    break
                                                                else
                                                                    echo "Error: Invalid input. $columnNameU must be an integer."
                                                                fi
                                                            elif [ "$data_type" == "string" ]; then
                                                                if is_string "$valueU"; then
                                                                    break
                                                                else
                                                                    echo "Error: Invalid input. $columnNameU must be a string."
                                                                fi
                                                            fi

                                                            # Ask the user to re-enter the value
                                                            read -p "Re-enter the value for $columnNameU: " valueU
                                                        done

                                                        # Update the file
                                                        awk -v pk="$pk" -v pos="$col_index_for_update" -v val="$valueU" -F: 'BEGIN{OFS=":"} {if ($1==pk) $pos=val; print}' "$file_path" > "$file_path.tmp" && mv "$file_path.tmp" "$file_path"

                                                        echo "Data updated successfully."
                                                        cat "$file_path"
                                                    else
                                                        echo "Error: Column name $columnNameU not found."
                                                    fi
                                                else
                                                    echo "Error: Column name $columnNameU does not exist in the file."
                                                fi
                                            else
                                                echo "Record with PK $pk not found."
                                                # Give the user the choice to re-enter the PK or go back to the main menu
                                                while true; do
                                                    read -p "Do you want to (1) re-enter the PK or (2) go back to the main menu? Enter 1 or 2: " choice
                                                    case $choice in
                                                        1)
                                                            read -p "Re-enter the value for the first column (PK): " pk
                                                            selected_record=$(awk -F':' -v column=1 -v value="$pk" '
                                                                NR > 2 {
                                                                    if ($column == value) {
                                                                        print;
                                                                        exit;
                                                                    }
                                                                }
                                                            ' "$file_path")

                                                            if [ -n "$selected_record" ]; then
                                                                record_found=true
                                                                echo "Record details for the PK $pk:"
                                                                echo "$selected_record"

                                                                read -p "Enter the column name you want to update: " columnNameU

                                                                IFS=':' read -r -a dataTypeArrU < <(awk -F':' 'NR==2 {print}' "$file_path")
                                                                IFS=':' read -r -a metaDataArrU < <(head -n 1 "$file_path")

                                                                if [[ " ${metaDataArrU[@]} " =~ " $columnNameU " ]]; then
                                                                    
                                                                    read -p "Enter the new value for $columnNameU: " valueU
                                                                    # echo "Column name $columnNameU found in the header."
                                                                    # Get the data type for the column
                                                                    col_index_for_update=$(awk -F':' -v col="$columnNameU" 'NR==1 {for (i=1; i<=NF; i++) if ($i == col) print i}' "$file_path")
                                                                    echo "col_index_for_update: $col_index_for_update"
                                                                    # Check if the column name is valid
                                                                    if [ -n "$col_index_for_update" ]; then
                                                                        data_type="${dataTypeArrU[col_index_for_update-1]}"
                                                                        # echo "dataTypeArrU: ${dataTypeArrU[@]}"
                                                                        # echo "data_type: $data_type"
                                                                        # echo "col_index_for_update: $col_index_for_update"
                                                                        # Loop until the user enters the correct data type
                                                                        while true; do
                                                                            # Validate the input based on the data type
                                                                            if [ "$data_type" == "int" ]; then
                                                                                if is_integer "$valueU"; then
                                                                                    break
                                                                                else
                                                                                    echo "Error: Invalid input. $columnNameU must be an integer."
                                                                                fi
                                                                            elif [ "$data_type" == "string" ]; then
                                                                                if is_string "$valueU"; then
                                                                                    break
                                                                                else
                                                                                    echo "Error: Invalid input. $columnNameU must be a string."
                                                                                fi
                                                                            fi

                                                                            # Ask the user to re-enter the value
                                                                            read -p "Re-enter the value for $columnNameU: " valueU
                                                                        done

                                                                        # Update the file
                                                                        awk -v pk="$pk" -v pos="$col_index_for_update" -v val="$valueU" -F: 'BEGIN{OFS=":"} {if ($1==pk) $pos=val; print}' "$file_path" > "$file_path.tmp" && mv "$file_path.tmp" "$file_path"

                                                                        echo "Data updated successfully."
                                                                        cat "$file_path"
                                                                    else
                                                                        echo "Error: Column name $columnNameU not found."
                                                                    fi
                                                        

                                                                else
                                                                    echo "Error: Column name $columnNameU does not exist in the file."
                                                                fi
                                                                break
                                                            else
                                                                echo "Record with PK $pk still not found. Please try again."
                                                            fi
                                                            ;;
                                                        2)
                                                            echo "Returning to Main Menu"
                                                            break
                                                            ;;
                                                        *)
                                                            echo "Invalid choice. Please enter 1 or 2."
                                                            ;;
                                                    esac
                                                done
                                            fi
                                        else
                                            echo "File not found: $file_path"
                                        fi
                                        ;;

                                    
                                    7 )
                                        echo "Returning to Main Menu"
                                        break 2
                                    ;;

                                    * )
                                        echo "Invalid choice. Please try again."
                                    ;;
                                

                                esac
                            done
                        done
                    else
                        echo "Database $name not found"
                
                    fi   
                else  echo "invalid DB name "    
                fi
                ;;
            
            5 )
                echo "Exiting the program. Goodbye!"
                exit 0
            ;;

            * )
                echo "Invalid choice. Please try again."
            ;;
        esac      
    done
done