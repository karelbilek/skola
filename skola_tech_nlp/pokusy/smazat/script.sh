#! /bin/bash
filecount=0
dircount=0
nondir=0

if [[ $1 =~ ^--?h(elp)?$ ]] ; then
    cat<<EOF
Usage: $0 dirs
Counts how many shell scripts there are in the given directories, how
many directories containing such files there are and what is an
average shell scripts count per directory.
EOF
    exit
fi

for dir ; do

    if [[ -d $dir ]] ; then
        count=$(ls "$dir"/*.sh 2>/dev/null | wc -l)
        if (( count )) ; then
          shdirs+=("$dir")
          let filecount+=count
        fi

    else
        let nondir++
    fi

done

if (( filecount )) ; then
    echo Sh-files: $filecount
fi

if (( ${#shdirs[@]} )) ; then
    echo Sh-dirs: "${shdirs[@]}"
fi

if (( $# != $nondir )) ; then
    echo -n "$filecount/($#-$nondir)="
    bc -l <<< "$filecount/($#-$nondir)"
fi
