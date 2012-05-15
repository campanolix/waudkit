#!/usr/bin/ruby
#
# showEnv.rb - Dump:
#

# DLN_LIBRARY_PATH	 Search path for dynamically loaded modules.
# HOME	 Directory moved to when no argument is passed to Dir::chdir. Also used by File::expand_path to expand "~".
# LOGDIR	 Directory moved to when no arguments are passed to Dir::chdir and environment variable HOME isn't set.
# PATH	 Search path for executing subprocesses and searching for Ruby programs with the -S option. Separate each path with a colon (semicolon in DOS and Windows).
# RUBYLIB	Search path for libraries. Separate each path with a colon (semicolon in DOS and Windows).
# RUBYLIB_PREFIX	Used to modify the RUBYLIB search path by replacing prefix of library path1 with path2 using the format path1;path2 or path1path2.
# RUBYOPT	 Command-line options passed to Ruby interpreter. Ignored in taint mode (Where $SAFE is greater than 0).
# RUBYPATH	With -S option, search path for Ruby programs. Takes precedence over PATH. Ignored in taint mode (where $SAFE is greater than 0).
# RUBYSHELL	 Specifies shell for spawned processes. If not set, SHELL or COMSPEC are checked.

puts "Show ruby environment variables:\n"

puts "DLN_LIBRARY_PATH:  #{ENV['DLN_LIBRARY_PATH']}"
puts "HOME:              #{ENV['HOME']}"
puts "LOGDIR:            #{ENV['LOGDIR']}"
puts "PATH:              #{ENV['PATH']}"
puts "RUBYLIB:           #{ENV['RUBYLIB']}"
puts "RUBYLIB_PREFIX:    #{ENV['RUBYLIB_PREFIX']}"
puts "RUBYOPT:           #{ENV['RUBYOPT']}"
puts "RUBYPATH:          #{ENV['RUBYPATH']}"
puts "RUBYSHELL:         #{ENV['RUBYSHELL']}"

