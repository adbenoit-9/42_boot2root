change_name() {
    nb_arg=$#
    nb_arg=$((nb_arg+1))
    i=1
    while [ $i -lt $nb_arg ]
    do
        file=${!i}
        chmod 777 $file
        sed -i 's/\/\/file/file/g' $file
        newName=`cat $file | grep file`
        sed -i '/file/d' $file
        mv $file $newName 2> /dev/null
        i=$((i+1))
    done
}

get_script() {
    nb_arg=$#
    nb_arg=$((nb_arg+1))
    i=1
    while [ $i -lt $nb_arg ]
    do
        cat file${i} >> ../script.c
        i=$((i+1))
    done
}

rm -rf order_fun
mkdir order_fun 2> /dev/null
cp ft_fun/* order_fun
cd order_fun
arg=`ls`
change_name $arg
rm -rf ../script.c
touch ../script.c
get_script $arg
cd ..
gcc script.c ; ./a.out
rm -rf order_fun
