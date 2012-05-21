require 'yaml'
require 'twitter'

#grab yaml config
CONFIG = YAML.load_file("html2md_cfg.yaml")

#returns array with appropriate information (file save path, title, album #, track #)
def makeFilename(fileName, story=FALSE)
  fileOutput = Array.new
  splitName = fileName.split('.')
  #the title
  if story
    fileOutput[1] = splitName[0][7..-1].gsub('-', ' ')
  else
    fileOutput[1] = splitName[0][11..-1].gsub('-', ' ')
  end
  #puts fileOutput[1]

  if story
    #Track Number
    fileOutput[3] = fileName[4,2]

    case fileName[1,2].to_i
    when 1
      fileOutput[2] = "One"
    when 2
      fileOutput[2] = "Two"
    when 3
      fileOutput[2] = "Three"
    when 4
      fileOutput[2] = "Four"
    when 5
      fileOutput[2] = "Five"
    when 6
      fileOutput[2] = "Six"
    else
      fileOutput[2] = "NA"
    end

    #filename format, to preserve track ordering needs to be in reverse date order. First track = "most recent" date.
    #Year indicates Album, Day indicates track (year = 2000-album#, day = 31-track#)
    #Ex: Album One, Track 1 = 1999-01-30-title.md
    year = 2000 - fileName[1,2].to_i
    day = 31 - fileOutput[3].to_i
    fileOutput[0] = OUTPUT_DIR + STORY_DIR + year.to_s + "-01-" + day.to_s + "-" + fileOutput[3].gsub(' ', '-') + ".md"
  else
    fileOutput[0] = OUTPUT_DIR + MUSINGS_DIR + fileName.gsub("\.html", "\.md")
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
  yamlString << "title: \"" + docInfo[1] + "\"\n"
  yamlString << "layout: story\n"
  if story
    yamlString << "category: story\n"
    yamlString << "permalink: /story/Album"+docInfo[2]+"/Track"+docInfo[3]+".html\n"
    yamlString << "album: "+docInfo[2]+"\n"
    yamlString << "track: "+docInfo[3]+"\n"
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

def postTweet(title, url)
  Twitter.configure do |config|
    config.consumer_key = CONFIG['consumer_key']
    config.consumer_secret = CONFIG['consumer_secret']
    config.oauth_token = CONFIG['oauth_token']
    config.oauth_token_secret = CONFIG['oauth_token_secret']
  end

  #puts CONFIG['base_url'] + url
  tweet = "A new post: " + title + " " + url 
  Twitter.update(tweet)
end
