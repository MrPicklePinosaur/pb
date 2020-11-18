#!/bin/sh

# pinosaur's blog script

blog_index_file="blogindex.html"
rolling_file="rolling.html"
template_file="template.html"
rss_file="rss.xml"
data_dir="blog"

[ ! -z "$EDITOR" ] && EDITOR="vim"


init() {
    echo 1
}

purge() {
    echo 1
    # add a confirmation of sorts here
}

new() {
    [ -z $1 ] && echo "please supply a name" && exit 1 

    # do some sed stuff here
    cp $template_file "$data_dir/drafts/$1"

}

publish() {
    echo "Select which post to publish"
    ls -1 "$data_dir/drafts" | nl 
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
[ ! -d $data_dir ] && echo "initing blog" &&\
    mkdir -p "$data_dir/drafts" &&\
    mkdir -p "$data_dir/published" &&\
    touch "$data_dir/database" 

case $1 in
    i|init) echo "init";;
    n|new) new $2;;
    p|publish) publish;;
    d|delete) echo "delete";;
    D|purge) echo "purge";;
    *) echo "helper" && exit 1;;
esac

