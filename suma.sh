#!/bin/bash

: '
PROJEKT 1 by @martapolcyn #322942
Skrypt bash sluzacy do sumowania liczb calkowitych zapisanych w pliku. Postac wywolania skryptu:

    nazwa_skryptu [-a] plik [kolumna1 ...]

Plik wejsciowy:
    - moze zawierac kilka kolumn liczb calkowitych
    - kolumny sa rozdzielone znakiem tab lub spacja

Skrypt:
    - sumuje ze soba wiersze wskazanych kolumn
    - tworzy wynikowa kolumne i wypisuje w konsoli
    - przy braku argumentu "kolumna" przyjmuje kolumne numer 1
    - -a dodatkowo podaje wynik sumowania wszystkich liczb z kolumny wynikowej

Obsluga bledow:
    - bledy skladni (podaje poprawna postac)
    - niepoprawny argument (np. nieistniejacy plik)
    - brak praw dostepu
'


# check for flag -a
# exit script if the flag is incorrect

has_a_flag=false
while getopts ":a" flag;
do
    case $flag in
        a)
            has_a_flag=true
            ;;
        \?)
            # syntax error
            echo "--------------------------"
            echo "SYNTAX ERROR"
            echo "--------------------------"
            echo "Illegal option has been entered."
            echo "Please use the correct syntax:"
            echo "suma [-a] file.txt [column_no ...]"
            echo "--------------------------"
            exit -1
            ;;
    esac
done

# take a correct argument for a filename

if $has_a_flag;
then
    filename=$2
    col_args=$(($#-3))
else
    filename=$1
    col_args=$(($#-2))
fi

# check if file exists
# exit if filename is incorrect

if [ ! -f "$filename" ];
then
    # file error
    echo "--------------------------"
    echo "FILE ERROR"
    echo "--------------------------"
    echo "File $filename does not exist."
    echo "Please check for correct file name and extention."
    echo "Please make sure to use correct syntax:"
    echo "suma [-a] file.txt [column_no ...]"
    echo "--------------------------"
    exit -1
fi

# check user permissions to the file

if ! [[ $(stat -c "%A" $filename) =~ "r" ]];
then
    echo "--------------------------"
    echo "FILE ERROR"
    echo "--------------------------"
    echo "You have no read permissions to this file."
    echo "Please ask your administrator to adjust the permissions."
    echo "--------------------------"
    exit -1
fi


# check what columns need to be summed up
# take column 1 by default if no column arguments

if test $col_args = -1
then
    columns=(1)
else
    columns=${@: $#-$col_args}
fi


# read file and sum columns

i=0
read -r line < $filename
array=($line)
n=${#array[@]}
while read line;
do
    # validate file:
    # - all lines have the same amount of columns?
    # - all entries are numeric?
    array=($line)
    m=${#array[@]}
    if [ $m -ne $n ];
    then
        echo "--------------------------"
        echo "FILE ERROR:"
        echo "--------------------------"
        echo "The file does not contain an equal number of columns in each line."
        echo "Please check the contents of the file."
        echo "--------------------------"
        exit -1
    fi

    for column in ${columns[@]}
    do
        # validate column argument
        # exit if column is not a number
        if ! [[ $column =~ ^[0-9]+$ ]] ;
        then
            echo "--------------------------"
            echo "VALIDATION ERROR"
            echo "--------------------------"
            echo "\"$column\" is no valid column number."
            echo "Please use the correct syntax:"
            echo "suma [-a] file.txt [column_no ...]"
            echo "--------------------------"
            exit -1
        fi
        # validate column arguments
        # exit if column number is 0 or less
        if  test $column -le 0
        then
            echo "--------------------------"
            echo "VALIDATION ERROR"
            echo "--------------------------"
            echo "Column number cannot be 0 or less"
            echo "--------------------------"
            exit -1
        fi
        # validate column arguments
        # exit if there are less columns in the file
        if test $column -gt ${#array[@]}
        then
            echo "--------------------------"
            echo "VALIDATION ERROR"
            echo "--------------------------"
            echo "Column number $column does not exist in the file $filename."
            echo "There are only ${#array[@]} columns in this file."
            echo "--------------------------"
            exit -1
        fi

        # validate if there are no non-numeric characters to add
        if ! [[ ${array[$(($column-1))]} =~ ^[0-9]+$ ]] ;
        then
            echo "--------------------------"
            echo "FILE ERROR"
            echo "--------------------------"
            echo "There is non numeric character in the file."
            echo "Column: $column, character: ${array[$(($column-1))]}"
            echo "Please check the contents of the file."
            echo "--------------------------"
            exit -1
        fi

        output[$i]=$((${output[$i]}+${array[$(($column-1))]}))
    done
    i=$(($i+1))
done < $filename

# output column:

echo "--------------------------"
echo "The output column: "
echo "--------------------------"
for element in ${output[@]}
do
    echo $element
done
echo "--------------------------"

# sum of all the numbers in output column:

if $has_a_flag
then
    sum=0
    for number in ${output[@]}
    do
        sum=$(($sum+$number))
    done
    echo "Sum of the output is: $sum"
    echo "--------------------------"
fi









