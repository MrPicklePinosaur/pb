#!/bin/sh
# pinosaur's blog script

data_dir="blog"
website_url="https://www.youtube.com/watch?v=oHg5SJYRHA0/" # no ending slash
blog_index_file="blogindex.html"
rolling_file="rolling.html"
rss_file="rss.xml"
blog_template="template.html"
index_template="index_entry.html"
rolling_template="rolling_entry.html"
rss_template="rss_entry.html"

[ ! -z "$EDITOR" ] && EDITOR="vim"

init() {
    read -p "Initialize blog here? [y/n] " ask
    [ "$ask" != "y" ] && echo "Cancelled init" && exit 0

    mkdir -p "$data_dir/drafts" "$data_dir/published" "$data_dir/html" "$data_dir/templates" "$data_dir/backups"
    echo '<a href="{{URL}}">{{TITLE}}</a>' >> "$data_dir/templates/$index_template"
    echo -e '<div>\n<h2>{{TITLE}}</h2>\n<p>{{DATE}}</p>\n<p>{{BODY}}</p>\n</div>' >> "$data_dir/templates/$rolling_template"
    echo -e '<item>\n<title>{{TITLE}}</title>\n<link></link>\n<description><\description>\n<\item>' \
        >> "$data_dir/templates/$rss_template"

    echo "Successfully created blog files."
}
refresh() {
    read -p "Are you sure you want to refresh? [y/n] " ask
    [ "$ask" != "y" ] && echo "Aborting..." && exit 0

    echo -e "$blog_index_file\n$rolling_file\n$rss_file" | xargs sed -i "/<!-- BLOG START -->/,/<!-- BLOG END -->/{/<!-- BLOG START -->/!{/<!-- BLOG END -->/!d}}"
    echo "Successfully refreshed."
}

backup() {
    backup_name=`mktemp --tmpdir="$data_dir/backups" -d "backup_$(date +'%b-%d')_XXX"`
    echo "Creating backup, will be placed in $backup_name"
    cp -r "$data_dir/drafts/" "$backup_name"
    cp -r "$data_dir/published/" "$backup_name"
}

new() {
    [ -z "$1" ] && echo "Please give your blog post a name (you should put it inside quotations)" && exit 1 
    sanitized=`echo -n "$1" | sed -e 's/[^A-Za-z0-9 _-]//g'`
    [ -f "$data_dir/drafts/$sanitized.draft.html" ] && echo "Blog of that name already exists." && exit 1
    $EDITOR "$data_dir/drafts/$sanitized.draft.html"
}

sub() {
    cat - |\
        sed "1i <!-- ID:$1 START -->" |\
        sed  "\$a <!-- ID:$1 END -->" |\
        sed "s|{{TITLE}}|$1|g;
            s|{{DATE}}|`date +'%a, %b %d %H:%M'`|g;
            s|{{URL}}|$website_url/blog/html/$1.html|g" |\
        sed "/{{BODY}}/r $data_dir/drafts/$1.draft.html" |\
        sed "/{{BODY}}/d" 
}

# $1 is directory
choose() { 
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

    cat $blog_template | sub "$to_publish" > "$data_dir/html/$to_publish.html" 

    # make this part less horrendous
    temp_index="$(mktemp)" 
    cat "$data_dir/templates/$index_template" | sub "$to_publish" >> $temp_index
    temp_rolling="$(mktemp)" 
    cat "$data_dir/templates/$rolling_template" | sub "$to_publish" >> $temp_rolling
    temp_rss="$(mktemp)" 
    cat "$data_dir/templates/$rss_template" | sub "$to_publish" >> $temp_rss

    # Add new entry to blog index (do something about indent??)
    sed -i "/<!-- BLOG START -->/r $temp_index" "$blog_index_file"
    sed -i "/<!-- BLOG START -->/r $temp_rolling" "$rolling_file"
    sed -i "/<!-- BLOG START -->/r $temp_rss" "$rss_file"

    mv "$data_dir/drafts/$to_publish.draft.html" "$data_dir/published/"
    echo "Successfully published $to_publish"
}

delete() {
    choose "$data_dir/published"
    to_delete=${chosen%.draft.html}

    mv "$data_dir/published/$to_delete.draft.html" "$data_dir/drafts/" &&\
        rm "$data_dir/html/$to_delete.html"

    # remove entries from files 
    echo -e "$blog_index_file\n$rolling_file\n$rss_file" | xargs sed -i "/<!-- ID:$to_delete START -->/,/<!-- ID:$to_delete END -->/ d"

    echo "Successfully deleted $to_delete"
}

# check to see if all required files are present
[ -f $blog_index_file ] && [ -f $rolling_file ] && [ -f $blog_template ] && [ -f $rss_file ] || { echo "You are missing a file, please check that you have $blog_index_file, $blog_template, $rolling_file and $rss_file in your home directory" && exit 1; }

# check if blog dir exists
[ ! -d $data_dir ]  && init && exit 0

case $1 in
    n|new) new "$2";;
    p|publish) publish;;
    d|delete) delete;;
    b|backup) backup;;
    r|refresh) refresh;;
    h|*) echo -e "=-=-=-=-=-=-= Pb =-=-=-=-=-=-=\nAvailable commands:\nn - new blog post\np - publish existing blog post\nd - deletes published post\nb - creates a backup";;
esac
