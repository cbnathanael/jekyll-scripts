jekyll-scripts
==============

This is a collection of scripts I'm building for my Jeykll-based sites.

html2md
-------
This is so entirely backward. This script is specifically designed to convert OpenOffice/LibreOffice exported HTML\* into Jekyll-friendly markdown (rdiscount style; maruku doesn't like what I do to the md file). To be fair, this is aiding my wife with her blog. She's writing a story, and for the last few years, before starting to post it online, she's been writing in Word and OpenOffice. Wordpress has been utter hell, and I've fallen in love with Jekyll. So, here we are.

Despite this specific use-case, I think the parser is handy, and I haven't seen anyone else tackle it. Some simple modifications, and it's ready to roll for anyone else :)

The basic workflow is this:

1. Export MS Word .doc or OO.o/LO .odf as HTML (OO.o/LO export ONLY)
2. Drag & drop the exported HTML file onto upload.bat
3. Upload.bat directs the HTML file into the html2md script, whereupon the file is...converted. It's scary, really. There are two types: Story and Musing. They're handled differently, based on how the HTML file is named.
4. After converting, the file is saved into the appropriate folder.
5. Git is invoked: adding, commiting, and pushing.

There is no need for this script to be kept within the git repository for the jekyll site. It can be saved anywhere.

build\_twitter
--------------
Designed to work as part of a git post-receive hook, this script reads a "newPost.txt" file within the jekyll repository. It contains only two lines: Title and URL. The file is parsed, and pushed through twitter as a notification after the hook runs a jekyll build.
