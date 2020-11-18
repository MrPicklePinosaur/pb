#!/bin/sh

# pinosaur's blog script

blog_index_file="blogindex.html"
rolling_file="rolling.html"
blog_template_file="template.html"
data_dir="blog"

[ ! -z "$EDITOR" ] && EDITOR="vim"


init() {
    echo 1
}

purge() {
    echo 1
}

new() {
    echo 1
}

publish() {
    echo 1
}

delete() {
    echo 1
}

# check to see if all required files are present
[ -f $blog_index_file ] || echo "missing $blog_index_file"
[ -f $rolling_file ] || echo "missing $rolling_file"
[ -f $blog_template_file ] || echo "missing $blog_template_file"

# possibly also check to see if index and rolling have the proper headers


# check if blog dir exists
[ ! -d $data_dir ] && echo "initing blog" && mkdir -p "$data_dir/drafts" \
    && touch "$data_dir/database" 

case $1 in
    i|init) echo "init";;
    n|new) echo "new";;
    p|publish) echo "publish";;
    d|delete) echo "delete";;
    D|purge) echo "purge";;
    *) echo "helper";;
esac

