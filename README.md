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

### p / publish

### d / delete


# Configuration
For more fine tuned configuration, navigate to the data\_dir directory that was created (by default it's blog/) and find the templates folder.
These are the html snippets that get included in your index, rolling and rss files.
You can use certain keywords that will be substituted in:
- {{TITLE}} for the title of the blog post
- {{DATE}}
- {{URL}} pointing to that post
- {{BODY}} the html of that post
