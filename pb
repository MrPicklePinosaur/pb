#!/bin/sh

# pinosaur's blog script

data_dir="blog"
website_url="https://www.youtube.com/watch?v=oHg5SJYRHA0/" 

blog_index_file="blogindex.html"
rolling_file="rolling.html"
rss_file="rss.xml"

blog_template="template.html"
index_template="index_entry.html"
rolling_template="rolling_entry.html"
rss_template="rss_entry.html"

[ ! -z "$EDITOR" ] && EDITOR="vim"

init() {
    read -p "Initialize blog? [y/n] " ask
    [ "$ask" != "y" ] && exit 0

    mkdir -p "$data_dir/drafts" "$data_dir/published" "$data_dir/html" "$data_dir/templates" 

    echo '<p id="{{TITLE}}">{{TITLE}}</p>' >> "$data_dir/templates/$index_template"
    echo -e '<div id="{{TITLE}}">\n<h2>{{TITLE}}</h2>\n<p>{{DATE}}</p></div>' >> "$data_dir/templates/$rolling_template"
    echo -e '<item>\n<title>{{TITLE}}</title>\n<link></link>\n<description><\description>\n<\item>' \
        >> "$data_dir/templates/$rss_template"

    echo "Created blog files"
}

refresh() {

    read -p "Are you sure you want to refresh? [y/n] " ask
    [ "$ask" != "y" ] && exit 0

    # delete everything between tokens (remove dupe code)
    echo -e "$blog_index_file\n$rolling_file\n$rss_file" | xargs sed -i "/<!-- BLOG START -->/,/<!-- BLOG END -->/{/<!-- BLOG START -->/!{/<!-- BLOG END -->/!d}}"

    # deletes all html files and republishes all published files

    echo "Refreshed."
}

new() {
    [ -z "$1" ] && echo "Please give your blog post a name (you should put it inside quotations)" && exit 1 
    sanitized=`echo -n "$1" | sed -e 's/[^A-Za-z0-9 _-]//g'| sed -e 's/ /-/g'`
    $EDITOR "$data_dir/drafts/$sanitized.draft.html"
}

sub() {
    cat - |\
        sed "s|{{TITLE}}|$1|g;
            s|{{DATE}}|`date +'%a, %b %d %H:%M'`|g;
            s|{{URL}}|$website_url/$1|g" |\
        sed "/{{BODY}}/r $data_dir/drafts/$1" |\
        sed "/{{BODY}}/d" 
}

# $1 is directory
choose() { # working on abstraction
    options=`ls -1 "$1" | sed 's/\.draft\.html$//;s/\.html$//'` 
    [ -z "$options" ] && echo "No drafts to publish" && exit 0
    echo "$options" | nl
    read -p 'Choose an entry by number > ' choice
    chosen=`ls -1 "$1" | sed -n "$choice p"`
    [ -z "$chosen" ] && echo "Invalid choice" && exit 1
}

publish() {
    
    choose "$data_dir/drafts"
    to_publish=${chosen%.draft.html}

    cat $blog_template | sub "$to_publish" \
       > "$data_dir/html/$to_publish.html" 

    # Add new entry to blog index (do something about indent??)
    sed -i "/<!-- BLOG START -->/ a\
        <!-- ID:$to_publish START -->\n`cat "$data_dir/templates/$index_template" | sub "$to_publish"`\n<!-- ID:$to_publish END -->" "$blog_index_file"

    mv "$data_dir/drafts/$to_publish.draft.html" "$data_dir/published/"

}

delete() {
    choose "$data_dir/published"
    to_delete=${chosen%.draft.html}

    mv "$data_dir/published/$to_delete.draft.html" "$data_dir/drafts/" &&\
        rm "$data_dir/html/$to_delete.html"

    # remove entries from files 
    echo -e "$blog_index_file\n$rolling_file\n$rss_file" | xargs sed -i "/<!-- ID:$to_delete START -->/,/<!-- ID:$to_delete END -->/ d"

}

# check to see if all required files are present
[ -f $blog_index_file ] && [ -f $rolling_file ] && [ -f $blog_template ] && [ -f $rss_file ] || { echo "You are missing a file, please check that you have $blog_index_file, $template_file, $rolling_file and $rss_file in your home directory" && exit 1; }

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

