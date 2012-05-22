require 'rubygems'
require 'git'

g = Git.init('c:\Sites\soundtrack')

g.add('.')
g.commit('ruby update!')
g.push
