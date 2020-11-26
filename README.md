All you really need is just the pb file, the others are there for demonstration purposes, you can just download that file by itself if you don't want the extra garbage.

# 'Installation'
Before running the script, open it up and change the variables at the top of the file to your liking.

You need a couple of things to get the script:
- A blog index file (a page with a list of all of your posts)
- A rolling blog file (a feed of posts will be placed here)
- A rss file

In each of these files, you need to include the comments:
```
<!-- BLOG START -->
<!-- BLOG END -->

```

# Usage
### n / new
Takes in a name for your blog post, put the name inside quotations if you want to have spaces. Also, only alphanumeric characters, underscores, dashes and spaces are allowed in the blog name (at this point).

### p / publish
Publishes a draft, which means that it takes the html snippet you wrote and shoves it inside your template file.

### d / delete
Deletes an already published blog post, this does not delete your draft.

### b / backup
Simply copies all draft and published blog entries into the backup directory.

### r / refresh (planned)
Used when you change the template file and want to keep all blog entries consistent. It deletes all html files and republishes them all.

# Configuration
For more fine tuned configuration, navigate to the data\_dir directory that was created (by default it's blog/) and find the templates folder.
These are the html snippets that get included in your index, rolling and rss files.
You can use certain keywords that will be substituted in:
- {{TITLE}} for the title of the blog post
- {{DATE}}
- {{URL}} pointing to that post
- {{BODY}} the html of that post
