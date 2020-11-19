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
    touch "$data_dir/database" 
}

refresh() {
    echo 1
    # add a confirmation of sorts here
}

new() {
    [ -z "$1" ] && echo "please supply a name" && exit 1 

    # sanitize input
    sanitized=`echo -n "$1" | sed -e 's/[^A-Za-z0-9 _-]//g'| sed -e 's/ /-/g'`

    # open in editor
    $EDITOR "$data_dir/drafts/$sanitized"

}

publish() {
    echo "Select which post to publish"
    ls -1 "$data_dir/drafts" | nl 

    read -p '> ' choice
    to_publish=`ls -1 "$data_dir/drafts/" | sed -n "$choice p"`
    [ -z "$to_publish" ] && echo "Invalid choice" && exit 1

    cat $template_file |\
        sed -e "s/{{TITLE}}/$to_publish/g" |\
        sed -e "s/{{DATE}}/`date +'%a, %b %d %H:%M'`/g" |\
        sed -e "/{{BODY}}/r $data_dir/drafts/$to_publish" |\
        sed -e "/{{BODY}}/d" # rly ugly for now

}

delete() {
    echo "Select which post to delete"
    ls -1 "$data_dir/published" | nl 
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
    d|delete) echo "delete";;
    r|refresh) echo "refresh";;
    *) echo "helper" && exit 1;;
esac

