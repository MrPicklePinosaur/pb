#!/bin/sh
# pinosaur's blog script v2!

data_dir="blog"
website_url="https://www.youtube.com/watch?v=oHg5SJYRHA0/" 
rolling_file="rolling.html"
blog_index_file="blogindex.html"
rss_file="rss.xml"
blog_template="template.html"
database_file="$data_dir/database"
index_template="$data_dir/templates/index_entry.html"
rolling_template="$data_dir/templates/rolling_entry.html"
rss_template="$data_dir/templates/rss_entry.html"

init() {
    read -p "Initialize blog here? [y/n] " ask
    [ "$ask" != "y" ] && printf "Initialization cancelled.\n" && exit 0

    mkdir -p "$data_dir/drafts" "$data_dir/published" "$data_dir/html" "$data_dir/templates" 

    printf '<li><a href="{{URL}}">{{DATE}} - {{TITLE}}</a></li>' > "$index_template"
    printf '<div>\n<h2>{{TITLE}}</h2>\n<p>{{DATE}}</p>\n<p>{{BODY}}</p>\n</div>\n' > "$rolling_template"
    printf '<item>\n<title>{{TITLE}}</title>\n<link>{{URL}}</link>\n<description></description>\n{{BODY}}\n</item>\n' > "$rss_template"
    touch "$database_file"

    printf 'Successfully initialized pb.\n'
}

new() {
    printf 'new\n' 
}

publish() {
    printf 'publish\n' 
}

delete() {
    printf 'delete\n' 
}

[ -f $blog_index_file ] && [ -f $rolling_file ] && [ -f $rss_file ] && [ -f $blog_template ] || { echo "You are missing a file, please check that you have $blog_index_file, $blog_template, $rolling_file and $rss_file in your home directory" && exit 1; }

[ -f $blog ]

[ ! -d $data_dir ] && init && exit 0

case $1 in
    n|new) new;;
    p|publish) publish;;
    d|delete) delete;;
    r|refresh) printf 'refresh\n';;
    h|*) printf 'help\n';;
esac



