# RecordDB &#127926;
## About app
it acts as a database that contains record names and amount of copies in a specific format<br />
for example : sweetchildofmine,5<br />
the database contains the song sweetchildofmine and 5 copies of it<br />
## Installation
1. Clone or download the script to your local machine.
2. Open your terminal and navigate to the script's directory.
3. Grant execution permissions to the script (if necessary) with `chmod +x recordexplorer.sh`.
4. Run the script by executing `./recordexplorer.sh`.
## Functions 
| Function Name | Function Type | Function Description  |
| ------------- | ------------- | ------------- |
| printall  | Main menu function  | prints the records in alphabetical order  |
| ‎printamount  | Main menu function  | prints the sum of the records and their copies  |
| updateamount  | Main menu function  | updates the amount of copies in an existing record  |
| updatename  | Main menu function  | updates the name of an existing record  |
| search  | Main menu function  | searches for a record name  |
| ‎delete  | Main menu function  | deletes an existing record or deletes a specified amount of copies  |
| ‎insert  | Main menu function  | inserts or updates an existing record  |
| log  | Main(invisible to the user)  | records every process in the program  |
| ‎createlogfile  | Aid Function  | create a suitable log file  |
| positivenumber  | Aid Function  | check if the number is positive  |
| validate_content  | Aid Function  | checks if the content of the executed file is valid  |
