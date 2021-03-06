#!/bin/bash

#Input $html_file
del_comments (){
    # Delete all lines that begin with #
    sed -i '/^#/d' "$1"
    # Delete comments inline
    sed -ri 's/(.+)(#.+)/\1/' "$1"
}

#Input $html_file
del_blank (){
    # This sed script will delete double blank lines
    sed -ri '
    /^$/ b check # Check if pattern buffer is holding a blank line
    b
    
    :check
    h # Copy the pattern buffer to the hold buffer
    N # Append the new line into the pattern buffer
    
    /\n$/ b delete # Check if the pattern buffer ends with a new line
    b
    
    :delete
    g # Override the pattern buffer with the hold pattern
    ' "$1"
}
    
#Input $html_file
create_para(){
    # This sed script will wrap the text with paragraph symbols
    sed -rni '
    /^$/ b wrap # Check if the pattern buffer is holding a blank line
    
    H # Append the pattern buffer to the hold buffer
    
    $ b wrap # Jump to wrap if end of file
    
    b
    
    :wrap
    x # Swap the pattern and hold buffer
    /\n(title|header|nav|picture|footer)/!{ # Check if the line is not a regular text
    s/(\n*)(.*)/\1\<p\>\n\2\n\<\/p\>/p # Surround the text block with paragraph symbols
    b
    }
    p # Print
    ' "$1"
}    


# Input is $html_file
create_header (){
    sed -rin "
    s/(^h)([0-9])(.*)/<h\2>\3<\/h\2>/
    " "$1"
}

# Input is $html_file
create_symbols (){
    sed -rin '
    /^(link|picture|ul|nl|\*)/ b wrap
    b
    
    :wrap
    /^link/ b link_wrap
    /^picture/ b picture_wrap
    /^ul/ b unorder_wrap
    /^\*/ b list_wrap
    b
    
    :link_wrap
    s/(link )(https*:\/\/[[:graph:]]+\/)(.*$)/<a href=\"\2\">\3<\/a>/
    b
    
    :picture_wrap
    s/(picture )(.*)/<img src=\"..\/pictures\/\2\"\/>/
    b

    :unorder_wrap
    s/ul/<ul>/
    b

    :list_wrap
    /(.*link.*)/ b link_in_list
    /(.*picture.*)/ b picture_in_list
    :jmp_back_2_list_wrap
    s/(^\* )(.*)/<li>\2<\/li>/
    b

    :link_in_list
    s/(^\* )(link )(https*:\/\/[[:graph:]]+\/)(.*$)/\1<a href=\"\3\">\4<\/a>/
    b jmp_back_2_list_wrap

    :picture_in_list

    ' "$1"
}

create_list (){
    sed -rin "
        # If a line starts with <ul> jump to wrap label
        /^<ul>/ b move
        b
    
        :move
        n # Read in next line into the pattern buffer (line counter increases)
        /^<li>/{
        b move # primitive looping!!
        }
        s/.*/<\/ul>/ # Substitute all of the pattern buffer for <\ul>
    " "$1"
}

create_title (){
    title=$(sed -rn "s/(title \")(.*)(\")/<h1>\2<\/h1>/p" ./html/"$file_name".html)
    title_tag=$(sed -rn "s/(title \")(.*)(\")/<title>\2<\/title>/p" ./html/"$file_name".html)
    style_sheet="<link rel="stylesheet" href="../style/style.css">"
    sub_title=$(sed -rn "s/header/<small>$author \| $date<\/small>/p" ./html/"$file_name".html)
    sed -in "1,4d" ./html/"$file_name".html
    # these inserts all happen in one sed command so just insert in first line
    sed -i "
    1 i $style_sheet
    1 i $title_tag
    1 i $title
    1 i $sub_title
    " ./html/"$file_name".html
}

create_footer (){
    # Delete the last line of file
    sed -rin "$ d" ./html/"$file_name".html
    echo "<small><a name="top" href="">Top</a></small>" >> ./html/"$file_name".html
}

create_code (){
    sed -rin "
        # If a line starts with code jump to wrap label
        s/^code/<div class=hl_box>\n<pre>\n<code>/
        t move
        b
    
        :move
        n # Read in next line into the pattern buffer (line counter increases)

        /^!/{
        s/.*/\n/
        t move # Jump to move label only if substitution occurs
        }

        /^$/!{
        b move # primitive looping!!
        }
        s/.*/<\/code>\n<\/pre>\n<\/div>/ # Substitute all of the pattern buffer
    " "$1"
}

# Input is path to htmlfile
create_html (){
    if [[ -f $1 ]]; then
        del_comments "$1"
        del_blank "$1"
        create_para "$1"
        create_header "$1"
        create_symbols "$1"
        create_list "$1"
        create_code "$1"
        create_title 
        create_footer
    else
        echo "$1 does not exits"
    fi
}

# Create an array of files in the page directory
get_files (){
    # Store file path to text file (relative to root direcotry)
    for entry in page/*
    do
        file_array+=("$entry")
    done

    # Get just the names of the file
    
    for file_path in "${file_array[@]}"
    do
        file_name=$(echo "$file_path" | sed -nr 's/(.*\/)(.*)/\2/p')
        cp "$file_path" "./html/$file_name.html"
        create_html "./html/$file_name.html"
    done
}

deploy (){
    dir_reqired=("html" "page" "pictures" "style")
    missing_flag=0

    for i in "${dir_reqired[@]}"
    do 
        if [[ ! -d "$i" ]]; then
            if [[ $missing_flag -eq 0 ]]; then
                missing_flag=1
            fi
            printf "%s does not exits, creating ...\n" $i
            mkdir -p $i
        fi
    done

    if [[ $missing_flag -eq 1 ]]; then
        cat <<EOF > ./page/sample
title "Test Website" # The title of the website
header #Contains the Author and Date
nav

# Basic Text
h2 Header
This is how you write the text.
# <p>This is how you write the text</p>
You can have multiple lines.
If you have a new line inbetween the lines, it gets counted as a new paragraph.

Like in regular markdown!

h2 Basic Link: 
link https://www.google.com/ link_to_google

h2 This is a Picture
Basic Picture

picture pic1.jpg
# <img src="./sample_pic/pic1.jpg"/>

h2 Basic Lists

ul
* The first item
* The second item
* The third item

h2 Some C Code
code
static void
fill_str_arr(void *strArr, void *string, int index)
{
    void *temp_str_p = &string; /* create a pointer to string */
!
    memcpy((char *)(strArr + sizeof(unsigned long)*index), 
            temp_str_p, sizeof(unsigned long));
}
!
static void
free_str_arr(void *strArr, int logicalLen, int bool){
    if (bool > 0)
    {
        for (int i = 0; i < logicalLen; i++)
        {
            free(*(char **)(strArr + sizeof(unsigned long)*i));
        }
    }
    else
    {
        free(strArr);
    }
}

footer # Back to the Top
EOF
        cat <<EOF >./style/style.css
body:not(.hl_box) {
    width: 40em;
    margin-left: auto;
    margin-right: auto;
    word-wrap: break-word;
    background-color: #ffffee;
    line-height: 1.3;
    word-spacing: 5px;
}

img {
	max-width: 20em;
	padding-top: 1em;
	padding-bottom: 1em;
}

small {
    word-spacing: 3px;
}

h1 {
    /* color: #8888cc; */
    color: #17a;
}

a {
    color: #17a;
}

a:hover {
    color:#8888cc; text-decoration: underline;
}

.hl_box {
    padding-left: 20px;
    padding-right: 5px;
    background-color: #A9A9A9;
}

.hl_box pre {
    background-color: #A9A9A9;
}

.hl_box code {  
    line-height: 1.3;
    background-color: #A9A9A9;
}
EOF
        
        echo 
        printf "Missing directories created\n"
        printf "Sample files have been created in /page and /style\n"
        echo
        printf "Run ./wwbs --help\n"
        exit 1
    fi
}

# Main
# Create the HTML file
shopt -s extglob # Enable regex for rm command
declare -a param_array
declare -a file_array
author="GrapeJuiceSoda"
date=$(date)

deploy

while [ ! $# -eq 0 ] # While parameter is not equal to 0/null
do
    param_array+=("$1") # Add parameter to an array list
    shift
done

if [[ ${#param_array} -eq 0 ]]; then
    get_files
fi

for i in "${param_array[@]}" # Loop through array
do
    
    # Check each item in array
    if [[ "$i" =~ ^--help ]]; then
        cat <<EOF
USEAGE: wwbs [OPTION]
  --help                  Print help message
  --file='page/text'      Input text
  --raw='text'            Print raw html file
  --delete='text'         Delete raw html file
    no flags              Convert all files to html
EXAMPLE:
  ./wwbs --file=page/sample
  ./wwbs --raw=sample

* Text files go into /page
* CSS style sheets go into /style
* Pictures go into /pictures
* When creating text files follow the syntax in page/sample
EOF
        exit 0

    elif [[ "$i" =~ ^--file ]]; then
        file_path=$(echo "$i" | sed -nr 's/(^--file=)(.*)/\2/p')
        file_name=$(echo "$i" | sed -nr 's/(^--file=)(.*\/)(.*)/\3/p')
        cp "$file_path" "./html/""$file_name"".html"
        create_html "./html/""$file_name"".html"

    elif [[ "$i" =~ ^--raw ]]; then
        file=$(echo "$i" | sed -nr 's/(^--raw=)(.*)/\2/p')
        cat html/"$file.html"
        exit

    elif [[ "$i" =~ ^--delete ]]; then
        file=$(echo "$i" | sed -nr 's/(^--delete=)(.*)/\2/p')
        html_file="$file.html"
        if [[ -f html/$html_file ]]; then
            rm html/"$html_file"
            echo "Deleted $html_file"
        fi
        exit

    else
        echo "Please check wwbs --help"
        exit
    fi
done

# Clean up
file="./html/""$file_name"".html"
if [[ -f $file ]]; then
    echo "Removing temp files"
    rm html/!(*.html)
fi
