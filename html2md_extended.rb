
require './html2md_functions.rb'

OUTPUT_DIR  = "C:\\Sites\\jekyll-scripts\\"
STORY_DIR   = "story_" #"story\\_posts\\"
MUSINGS_DIR = "musings_" #"musings\\_posts\\"


fileInput = ARGV[0]
#isolate filename
fo = fileInput.split('\\')
i = fo.length
fileName = fo[fo.length-1]

if fileName.match(/A\d{2}T\d{2}/)
  FILE_IS_STORY = TRUE
else
  FILE_IS_STORY = FALSE
end

fileOutput =  makeFilename(fileName, FILE_IS_STORY)

text = File.read(fileInput)
File.open(fileOutput[0], 'w') do |md|

  if FILE_IS_STORY
    newMd = stripSoundtrack(text)
  else
    newMd = stripHTML(text)
  end
  yaml = generateYaml(fileOutput, FILE_IS_STORY)
  puts yaml
  newMd = newMd.insert(yaml, 0)

  md.puts(newMd)
end

