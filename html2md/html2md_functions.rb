require 'yaml'
require 'rubygems'
require 'git'


#grab yaml config
CONFIG = YAML.load_file("html2md_cfg.yaml")

#returns array with appropriate information (file save path, file name, title, album #, track #)
def makeFilename(fileName, story=FALSE)
  fileOutput = Array.new
  splitName = fileName.split('.')
  #the title
  if story
    fileOutput[2] = splitName[0][7..-1].gsub('-', ' ')
  else
    fileOutput[2] = splitName[0][11..-1].gsub('-', ' ')
  end
  #puts fileOutput[1]

  if story
    #Track Number
    fileOutput[4] = fileName[4,2]

    case fileName[1,2].to_i
    when 1
      fileOutput[3] = "One"
    when 2
      fileOutput[3] = "Two"
    when 3
      fileOutput[3] = "Three"
    when 4
      fileOutput[3] = "Four"
    when 5
      fileOutput[3] = "Five"
    when 6
      fileOutput[3] = "Six"
    else
      fileOutput[3] = "NA"
    end

    #filename format, to preserve track ordering needs to be in reverse date order. First track = "most recent" date.
    #Year indicates Album, Day indicates track (year = 2000-album#, day = 31-track#)
    #Ex: Album One, Track 1 = 1999-01-30-title.md
    year = 2000 - fileName[1,2].to_i
    day = 31 - fileOutput[4].to_i
    fileOutput[1] = year.to_s + "-01-" + day.to_s + "-" + fileOutput[2].gsub(' ', '-') + ".md"
    fileOutput[0] = CONFIG['output_dir'] + CONFIG['story_dir'] + fileOutput[1] 
  else
    fileOutput[1] = fileName.gsub("\.html", "\.md")
    fileOutput[0] = CONFIG['output_dir'] + CONFIG['musings_dir'] + fileOutput[1]
  end

  return fileOutput
end

def generateYaml(docInfo, story=FALSE)
  
  #---
  #layout: story
  #title: "Such Great Heights"
  #category: story
  #permalink: story/AlbumOne/Track01.html
  #album: One
  #track: 01
  #---
  yamlString = "---\n"
  yamlString << "title: \"" + docInfo[2] + "\"\n"
  yamlString << "layout: story\n"
  if story
    yamlString << "category: story\n"
    yamlString << "permalink: /story/Album"+docInfo[3]+"/Track"+docInfo[4]+".html\n"
    yamlString << "album: "+docInfo[3]+"\n"
    yamlString << "track: "+docInfo[4]+"\n"
  else
    yamlString << "category: musings\n"
  end
  yamlString << "---\n"

    return yamlString
end

def stripHTML(htmlString)
#remove doctype and head
  htmlString = htmlString.gsub(/<!DOC.*?>(.|\n)*?<\/head>/i, " ")

  #remove body, html and font tags
  htmlString = htmlString.gsub(/<\/?(BODY|FONT|HTML)[^>\r\n]*?>(\n)?/i," ")

  #remove line breaks (no worries! we put them back)
  htmlString = htmlString.gsub(/\n/, " ")

  #add line breaks for p, h* and br tags
  htmlString = htmlString.gsub /<\/(p|h1|h2|h3|h4|h5|h6)>/i, '</\1>'+"\n\n"
  htmlString = htmlString.gsub( /(<br ?\/?>)/i, "\n\n" )

  #remove other p tags
  htmlString = htmlString.gsub( /(<p(?! class)[^>\r\n]*?>)(.*?)(<\/p>)/i, '\2')
  #replace header tags, delete trailing
  htmlString = htmlString.gsub( /(<h1[^>\r\n]*?>)(.*?)(<\/h1>)/i, "# "+'\2' )
  htmlString = htmlString.gsub( /(<h2[^>\r\n]*?>)(.*?)(<\/h2>)/i, "## "+'\2' )
  htmlString = htmlString.gsub( /(<h3[^>\r\n]*?>)(.*?)(<\/h3>)/i, "### "+'\2' )
  htmlString = htmlString.gsub( /(<h4[^>\r\n]*?>)(.*?)(<\/h4>)/i, "#### "+'\2' )
  htmlString = htmlString.gsub( /(<h5[^>\r\n]*?>)(.*?)(<\/h5>)/i, "##### "+'\2' )
  htmlString = htmlString.gsub( /(<h6[^>\r\n]*?>)(.*?)(<\/h6>)/i, "###### "+'\2' )

  htmlString = htmlString.gsub( /<\/(h1|h2|h3|h4|h5|h6)>/i, '' )

  #remove empty tags
  htmlString = htmlString.gsub( /<([a-z])[^>\r\n]*?>\s*<\/\1>/i, '')

  #replace i/br/em/strong tags to make nice markdown
  htmlString = htmlString.gsub( /<\/?(i|em)>/i, "*" )
  htmlString = htmlString.gsub(/<\/?(b|strong)>/i,"__")
  #replace hypens; they're not for lists
  htmlString = htmlString.gsub(/\s-\s/,"&mdash;")
      
  #remove unnecessary newlines
  htmlString = htmlString.gsub( /\n(\s)?{3,}/, "\n\n" )
  #condense multiple spaces
  htmlString = htmlString.gsub(/[( |\t)]{2,}/i," ")
  return htmlString
end

def stripSoundtrack(htmlString)
  #manipulate styling (specifically looking for the font "Sunshine in my Soul" and replacing it with the css class="journal")
  htmlString = htmlString.gsub(/<P.*?>.*?<FONT.*?Sun.*?>/i, "<p class=\"journal\">")
 
  htmlString = stripHTML(htmlString)

  #replace breaks with an HR
  htmlString = htmlString.gsub( /\&#61591;\s*\&#61591;\s*\&#61591;/, "<hr \/>" )

  return htmlString

end

def newPostFile(fileOutput, is_story)

  url = "http://www.thesoundtrackseries.com/"

  if is_story
    url << "story/" + "Album" + fileOutput[3] + "/track" + fileOutput[4] + ".html"
  else
    url << "musings/" + fileOutput[1][0,4] + "/" + fileOutput[1][5,2] + "/" + fileOutput[2].gsub(' ', '-') + ".html"
  end

  fName = CONFIG['output_dir'] + "/newPost.txt"
  File.open(fName, 'w') do |md|
    outputText = fileOutput[2] + "\n"
    outputText << url
    md.puts(outputText)
  end

end

def gitCommit(gitDir, fileName)
  
  g = Git.init(gitDir)
  g.add('.')
  g.commit('Site Update: ' + fileName)
  g.push

end
