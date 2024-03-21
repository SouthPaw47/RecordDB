#!/bin/bash

function printall(){ # main function that prints the records in alphabetical order
if [ ! -s "$1" ]; then
    echo "File is empty"
    log "attempt to print empty file" $logfile
else
    sort "$1" | while IFS= read -r line; do
    echo "$line" 
    log "printAll $line" $logfile
    done
fi

}
function printamount(){ # main function that prints the sum of the records and their copies
sum=0
sum=$(awk -F',' '{ sum += $2 } END { print sum }' "$1")
if ((sum>0))
then echo "There are "$sum" copies"
log "PrintAmount "$sum"" $logfile
else echo "There are no copies"
log "PrintAmount "0"" $logfile
fi
}
function updateamount(){ # main function that updates the amount of copies in an existing record
 local searchword=$1
    local amount=$2
    if [[ "$searchword" =~ ^[[:alpha:]]+$ ]]; then
    amount=$(positivenumber $amount)
    if (($amount != 0 )); then
    search $searchword
    output=$(search $searchword)
    lines=$(search $searchword | wc -l)

    if [[ "$output" == "No matches found for '$searchword'." ]]; then
    echo "No matches found"
    log  "UpdateAmount Failure" $logfile
    elif [[ "$output" != "No matches found for '$searchword'." ]]; then
    read -p "if you want to update an existing record enter the line number , if you want to add this as a new record enter 0 : " lineNumber
    regex="^[1-$lines]$"
        if (($lines >= 1)) && [[ $lineNumber =~ $regex ]]; then
            name_and_number=$(echo "$output" | awk -v line="$lineNumber" 'NR == line {print $2}')
            name=$(echo "$name_and_number" | cut -d ',' -f 1)
            number=$(echo "$name_and_number" | cut -d ',' -f 2)
            grep -o "$name,$number" $filename | sed -i "s/$name,$number/$name,$amount/" $filename
            echo "Updating amount done"
            log  "UpdateAmount Failure" $logfile
            fi
        elif (( $lineNumber == 0 )) &&  [[ "$lineNumber" =~ ^[0-9]+$ ]]; then
            echo "No matches found"
            log  "UpdateAmount Failure" $logfile
        else echo "run the script again and enter a valid input"
            log  "UpdateAmount Failure" $logfile
        fi
        else echo "The amount is invalid , please enter a positive number"
            log  "UpdateAmount Failure" $logfile
        fi
        else echo "The name is invalid , it can only contain letters and spaces"
            log  "UpdateAmount Failure" $logfile
        fi
} 
function updatename(){ # main function that updates the name of an existing record 
    local searchword=$1
    local amount=0
    if [[ "$searchword" =~ ^[[:alpha:]]+$ ]]; then
    search $searchword
    output=$(search $searchword)
    lines=$(search $searchword | wc -l)

    if [[ "$output" == "No matches found for '$searchword'." ]]; then
    echo "No matches found"
    log  "UpdateName Failure" $logfile
    elif [[ "$output" != "No matches found for '$searchword'." ]]; then
    read -p "if you want to update an existing record enter the line number , if you want to add this as a new record enter 0 : " lineNumber
    regex="^[1-$lines]$"
        if (($lines >= 1)) && [[ $lineNumber =~ $regex ]]; then
            name_and_number=$(echo "$output" | awk -v line="$lineNumber" 'NR == line {print $2}')
            name=$(echo "$name_and_number" | cut -d ',' -f 1)
            number=$(echo "$name_and_number" | cut -d ',' -f 2)
            grep -o "$name,$number" $filename | sed -i "s/$name,$number/$searchword,$number/" $filename
            echo "Updating name done"
            log  "UpdateName Success" $logfile
            fi
        elif (( $lineNumber == 0 )) &&  [[ "$lineNumber" =~ ^[0-9]+$ ]]; then
            echo "No matches found"
            log  "UpdateName Failure" $logfile
        else echo "run the script again and enter a valid input"
            log  "UpdateName Failure" $logfile
        fi
        else echo "The name is invalid , it can only contain letters and spaces"
            log  "UpdateName Failure" $logfile
        fi
} 
function search(){ # main function that searches for a record name 
    local result=$(grep -i "$1" "$filename" | sort | nl)
    if [ -z "$result" ]; then
        echo "No matches found for '$1'."
        log "Search Failure" "$logfile"
    else
        echo "$result"
        log "Search Success" "$logfile"
    fi
}
function delete(){ # main function that deletes an existing record
    local searchword=$1
    local amount=$2
    if [[ "$searchword" =~ ^[[:alpha:]]+$ ]]; then
    amount=$(positivenumber $amount)
    if (($amount != 0 ))
    then
    search $searchword
    output=$(search $searchword)
    lines=$(search $searchword | wc -l)
    if [[ "$output" == "No matches found for '$searchword'." ]]; then
    echo "No matches found"
    log  "Delete Failure" $logfile
    elif [[ "$output" != "No matches found for '$searchword'." ]]; then
    read -p "if you want to update an existing record enter the line number , if you want to add this as a new record enter 0 : " lineNumber
    regex="^[1-$lines]$"
    
    if (($lines >= 1)) && [[ $lineNumber =~ $regex ]]; then
        name_and_number=$(echo "$output" | awk -v line="$lineNumber" 'NR == line {print $2}')
        name=$(echo "$name_and_number" | cut -d ',' -f 1)
        number=$(echo "$name_and_number" | cut -d ',' -f 2)
        newamount=$(($number - $amount))
        if (($newamount < 0)); then
        echo "deletion amount is out of bounds"
        log  "Delete Failure" $logfile
        elif (($newamount == 0)); then
        grep -o "$name,$number" $filename | sed -i "/^$name,$number\$/d" $filename
        echo "Deletion done"
        log  "Delete Success" $logfile
        elif (($newamount > 0)); then
        grep -o "$name,$number" $filename | sed -i "s/$name,$number/$name,$newamount/" $filename
        echo "Deletion done"
        log  "Delete Success" $logfile
        fi
    elif (( $lineNumber == 0 )) &&  [[ "$lineNumber" =~ ^[0-9]+$ ]]; then
        echo "No matches found"
        log  "Delete Failure" $logfile
    else echo "run the script again and enter a valid input"
        log  "Delete Failure" $logfile
    fi
    fi
    else echo the amount of copies is invalid
         log  "Delete Failure" $logfile
    fi
    else echo "The name is invalid , it can only contain letters and spaces"
        log  "Delete Failure" $logfile
    fi
}

validate_content() { # aid function that checks if the content of the executed file is valid
    validator=0 # global variable that equals to 0 when the file's content is valid and 1 otherwise
    local content="$1"
    while IFS= read -r line; do
        if [[ $line =~ ^[[:alnum:][:space:]]+,[1-9][0-9]*$ ]]; then
            :
        else
            validator=1
        fi
    done <<< "$content"
    if (($validator==0))
    then
    log "file validation valid" $logfile
    else
    log "file validation invalid or empty " $logfile
    fi
}
function positivenumber(){ # aid function that check if the number is positive
 local num=$1
    if [ -z "$num" ]; then
        num=0
        echo $num
    elif (($num > 0)); then
        echo $num
    elif (( $num == 0)); then
        num=0
        echo $num
    else
        num=0
        echo $num
    fi
}
function insert(){ # main function that inserts or updates an existing record
    local searchword=$1
    local amount=$2
    if [[ "$searchword" =~ ^[[:alpha:]]+$ ]]; then
    amount=$(positivenumber $amount)
    if (($amount != 0 ))
    then
    search $searchword
    output=$(search $searchword)
    lines=$(search $searchword | wc -l)
    if [[ "$output" == "No matches found for '$searchword'." ]]; then
    echo "$searchword,$amount" >> $filename
    echo "insertion done"
    log  "Insert Success" $logfile
    elif [[ "$output" != "No matches found for '$searchword'." ]]; then
    read -p "if you want to update an existing record enter the line number , if you want to add this as a new record enter 0 : " lineNumber
    regex="^[1-$lines]$"
    
    if (($lines >= 1)) && [[ $lineNumber =~ $regex ]]; then
        name_and_number=$(echo "$output" | awk -v line="$lineNumber" 'NR == line {print $2}')
        name=$(echo "$name_and_number" | cut -d ',' -f 1)
        number=$(echo "$name_and_number" | cut -d ',' -f 2)
        newamount=$(($number + $amount))
        grep -o "$name,$number" $filename | sed -i "s/$name,$number/$name,$newamount/" $filename
        echo "insertion done"
        log  "Insert Success" $logfile
    elif (( $lineNumber == 0 )) &&  [[ "$lineNumber" =~ ^[0-9]+$ ]]; then
        echo "$searchword,$amount" >> $filename
        echo "insertion done"
        log  "Insert Success" $logfile
    else echo "run the script again and enter a valid input"
        log  "Insert Failure" $logfile
    fi
    fi
    else echo the amount of copies is invalid
         log  "Insert Failure" $logfile
    fi
    else echo "The name is invalid , it can only contain letters and spaces"
         log  "Insert Failure" $logfile
    fi
}

function log(){ # main(invisible to the user)function that records every process in the program
echo $(date +"%Y-%m-%d %H:%M:%S ") "$1"  >> "$2"
}
function createlogfile(){ # aid function to create a suitable log file
        local filename=$1
        local basename_no_extension=${filename%.*}
        local new_filename="${basename_no_extension}_log"
        if [ -f $new_filename ]; then
        :
        else
        touch $new_filename
        log "log file creation" $new_filename
        fi  
        echo "$new_filename"
}
filename=$1 # global variable to save the file name and use it in functions
if [ -f $filename ]; then
logfile=$(createlogfile $filename)
file_content=$(<$filename)
validate_content "$file_content"
if (($validator == 0))
then
:
options=("Insert" "Delete" "Search" "UpdateName" "UpdateAmount" "PrintAmount" "PrintAll" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Insert")
            read -p "enter the record name space then the amount of copies : " name amount 
            insert $name $amount 
            ;;
        "Delete")
            read -p "enter the record name space then the amount of copies : " name amount 
            delete $name $amount
            ;;
        "Search")
            read -p "enter keyword to search : " keyword
            search $keyword 
            ;;
        "UpdateName")
            read -p "enter the record name : " name 
            updatename $name 
            ;;
        "UpdateAmount")
            read -p "enter the record name space then the amount of copies : " name amount 
            updateamount $name $amount
            ;;
        "PrintAmount")
            printamount $filename $logfile
            ;;
        "PrintAll")
            printall $filename $logfile
            ;;
        "Quit")
            break
            ;;
        *)
            echo "Invalid option"
            ;;
    esac
done
else
    echo "the file content is invalid or empty , please fix it and try again"
    fi
else
echo "file doesnt exist"
fi