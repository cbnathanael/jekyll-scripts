@echo off
chcp 65001
echo %1
pause
echo "Converting..."
ruby html2md.rb %1
pause
::echo "Generating..."
::jekyll C:\Sites\soundtrack\ C:\Sites\soundtrack\_site
::pause
echo "Uploading..."
ruby gitPush.rb
pause
