#!/bin/sh

# pinosaur's blog script

blog_index_file="blogindex.html"
rolling_file="rolling.html"
template_file="template.html"
rss_file="rss.xml"
data_dir="blog"

[ ! -z "$EDITOR" ] && EDITOR="vim"


init() {
    echo "initing blog"
    mkdir -p "$data_dir/drafts" &&\
    mkdir -p "$data_dir/published" &&\
    mkdir -p "$data_dir/html" 
}

refresh() {
    echo 1
    # add a confirmation of sorts here

    # deletes all html files and republishes all published files
}

new() {
    [ -z "$1" ] && echo "please supply a name" && exit 1 

    # sanitize input
    sanitized=`echo -n "$1" | sed -e 's/[^A-Za-z0-9 _-]//g'| sed -e 's/ /-/g'`

    # open in editor
    $EDITOR "$data_dir/drafts/$sanitized.draft.html"
}

publish() {
    
    drafts=`ls -1 "$data_dir/drafts" | sed -e 's/\.draft\.html$//'`
    [ -z "$drafts" ] && echo "No drafts to publish" && exit 0

    echo "Select which post to publish"
    echo "$drafts" | nl 

    read -p '> ' choice
    to_publish=`ls -1 "$data_dir/drafts/" | sed -n "$choice p"`
    [ -z "$to_publish" ] && echo "Invalid choice" && exit 1

    cat $template_file |\
        sed -e "s/{{TITLE}}/$to_publish/g;
            s/{{DATE}}/`date +'%a, %b %d %H:%M'`/g" |\
        sed -e "/{{BODY}}/r $data_dir/drafts/$to_publish" |\
        sed -e "/{{BODY}}/d" \
       > "$data_dir/html/${to_publish%.draft.html}.html" 

    mv "$data_dir/drafts/$to_publish" "$data_dir/published/"

    # Add new entry to blog index
    #sed -e ""


}


delete() {
    published=`ls -1 "$data_dir/published" | sed -e 's/\.draft\.html$//'`
    [ -z "$published" ] && echo "No posts to delete" && exit 0

    echo "Select which post to delete"
    echo "$published" | nl 

    read -p '> ' choice
    to_delete=`ls -1 "$data_dir/published/" | sed -n "$choice p"`
    [ -z "$to_delete" ] && echo "Invalid choice" && exit 1

    mv "$data_dir/published/$to_delete" "$data_dir/drafts/" &&\
        rm "$data_dir/html/${to_delete%.draft.html}.html"

    # remove entry from blog index
}

# check to see if all required files are present
[ ! -f $blog_index_file ] && echo "missing $blog_index_file" && exit 1
[ ! -f $rolling_file ] && echo "missing $rolling_file" && exit 1
[ ! -f $template_file ] && echo "missing $template_file" && exit 1
[ ! -f $rss_file ] && echo "missing $rss_file" && exit 1

# possibly also check to see if index and rolling have the proper headers


# check if blog dir exists
[ ! -d $data_dir ]  && init

case $1 in
    i|init) init;;
    n|new) new "$2";;
    p|publish) publish;;
    d|delete) delete;;
    r|refresh) echo "refresh";;
    h|*) echo "helper" && exit 1;;
esac

