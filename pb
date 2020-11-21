#!/bin/sh

# pinosaur's blog script

blog_index_file="blogindex.html"
rolling_file="rolling.html"
template_file="template.html"
index_entry_template="index_entry.html"
rss_file="rss.xml"
data_dir="blog"

[ ! -z "$EDITOR" ] && EDITOR="vim"


init() {
    read -p "Initialize blog? [y/n] " ask
    [ "$ask" != "y" ] && exit 0

    mkdir -p "$data_dir/drafts" "$data_dir/published" "$data_dir/html" "$data_dir/templates" 

    echo '<p id="{{TITLE}}">{{TITLE}}</p>' >> "$data_dir/templates/$index_entry_template"

    echo "Created blog files"
}

refresh() {
    start_token="<!-- BLOG START -->"
    end_token="<!-- BLOG END -->"

    read -p "Are you sure you want to refresh? [y/n] " ask
    [ "$ask" != "y" ] && exit 0

    # delete everything between tokens (remove dupe code)
    sed -i "/$start_token/,/$end_token/{/$start_token/!{/$end_token/!d}}" "$blog_index_file"
    sed -i "/$start_token/,/$end_token/{/$start_token/!{/$end_token/!d}}" "$rolling_file"
    sed -i "/$start_token/,/$end_token/{/$start_token/!{/$end_token/!d}}" "$rss_file"

    # deletes all html files and republishes all published files
}

new() {
    [ -z "$1" ] && echo "Please give your blog post a name (you should put it inside quotations)" && exit 1 

    # sanitize input
    sanitized=`echo -n "$1" | sed -e 's/[^A-Za-z0-9 _-]//g'| sed -e 's/ /-/g'`

    # open in editor
    $EDITOR "$data_dir/drafts/$sanitized.draft.html"
}

sub() {
    cat - |\
        sed -e "s/{{TITLE}}/$1/g;
            s/{{DATE}}/`date +'%a, %b %d %H:%M'`/g" |\
        sed -e "/{{BODY}}/r $data_dir/drafts/$1" |\
        sed -e "/{{BODY}}/d" 
}

publish() {
    
    drafts=`ls -1 "$data_dir/drafts" | sed -e 's/\.draft\.html$//'`
    [ -z "$drafts" ] && echo "No drafts to publish" && exit 0

    echo "Select which draft to publish"
    echo "$drafts" | nl 

    read -p '> ' choice
    to_publish=`ls -1 "$data_dir/drafts/" | sed -n "$choice p"`
    to_publish=${to_publish%.draft.html}
    [ -z "$to_publish" ] && echo "Invalid choice" && exit 1

    cat $template_file | sub "$to_publish" \
       > "$data_dir/html/$to_publish.html" 

    # Add new entry to blog index (do something about indent??)
    sed -i "/<!-- BLOG START -->/ a\
        `cat "$data_dir/templates/$index_entry_template" | sub "$to_publish"`" "$blog_index_file"
    #also clean up this bracket mess ^

    mv "$data_dir/drafts/$to_publish.draft.html" "$data_dir/published/"

}

delete() {
    published=`ls -1 "$data_dir/published" | sed -e 's/\.draft\.html$//'`
    [ -z "$published" ] && echo "No posts to delete" && exit 0

    echo "Select which post to delete"
    echo "$published" | nl 

    read -p '> ' choice
    to_delete=`ls -1 "$data_dir/published/" | sed -n "$choice p"`
    to_delete=${to_delete%.draft.html}
    [ -z "$to_delete" ] && echo "Invalid choice" && exit 1

    mv "$data_dir/published/$to_delete.draft.html" "$data_dir/drafts/" &&\
        rm "$data_dir/html/$to_delete.html"

    # remove entry from blog index (broken rn)
    #entry=`cat "$data_dir/templates/$index_entry_template" | sub "$to_publish"`
    #sed -i "/$entry/ d" "$blog_index_file"
}

# check to see if all required files are present
[ -f $blog_index_file ] && [ -f $rolling_file ] && [ -f $template_file ] && [ -f $rss_file ] || { echo "You are missing a file, please check that you have $blog_index_file, $template_file, $rolling_file and $rss_file in your home directory" && exit 1; }

# possibly also check to see if index and rolling have the proper headers


# check if blog dir exists
[ ! -d $data_dir ]  && init

case $1 in
    i|init) init;;
    n|new) new "$2";;
    p|publish) publish;;
    d|delete) delete;;
    r|refresh) refresh;;
    h|*) echo "helper";;
esac

