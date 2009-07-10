# Release under the MIT license
# Copyright (c) 2006 Chris Anderson
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require File.expand_path(File.dirname(__FILE__) + "/../lib/svn")

@svn = Subversion.new

def root_dir( escaped = true )
  escaped ? 
  Rake.original_dir.gsub(' ', '\ ') :
  Rake.original_dir
end


namespace :svn do
  
  namespace :check do
  
    task :version do
      $verbose = false
      response = `svn --version` rescue nil
      unless !$?.nil? && $?.success?
        $stderr.puts "ERROR: Must have subversion (svn) available in the PATH"
        exit 1
      else
        puts response.split("\n").first
      end
    end

    task :info do
      @svn.run "info #{root_dir}", :message => "ERROR: Must be a subversion checkout path"
    end
  
  end

  namespace :ignore do

    desc "Ignore Rails log files"
    task :logs => 'check:info' do      
      @svn.run "update   #{root_dir}"
      @svn.run "remove   #{root_dir}/log/ --force"
      @svn.run "commit   #{root_dir} -m 'removing all log files from subversion'"
      @svn.run "update   #{root_dir}"
      @svn.propadd 'svn:ignore', root_dir(false), "log"
      @svn.run "commit   #{root_dir} -m 'Ignoring log/ directory'"
      system "mkdir #{root_dir}/log/"
    end

    desc "Ignore Rails tmp directory"
    task :tmp => 'check:info' do
      @svn.run "update   #{root_dir}"
      @svn.run "remove   #{root_dir}/tmp/ --force"
      @svn.run "commit   #{root_dir} -m 'removing tmp directory from subversion'"
      @svn.run "update   #{root_dir}"
      @svn.propadd 'svn:ignore', root_dir(false), "tmp"
      @svn.run "commit   #{root_dir} -m 'Ignoring tmp/ directory'"
      system "cd #{root_dir} && rake tmp:create"
    end

    desc "Setup database.example.yml and ignore database.yml"
    task :database_yml => 'check:info' do
      @svn.run "update   #{root_dir}"
      @svn.run "move     #{root_dir}/config/database.yml #{root_dir}/config/database.example.yml"
      @svn.run "commit   #{root_dir} -m 'Moving database.yml to database.example.yml'"
      @svn.run "update   #{root_dir}"
      @svn.propadd 'svn:ignore', "#{root_dir(false)}/config/", "database.yml"      
      @svn.run "commit   #{root_dir} -m 'Ignoring database.yml'"
      @svn.run "update   #{root_dir}"
    end

    desc "Ignore the default files for a fresh Rails project"
    task :rails => [:logs, :tmp, :database_yml]

  end

  desc "Commit to repository"
  task :commit => 'check:info' do
    @svn.run "st --ignore-externals"
    puts "Please provide your commit message:"
    @message = STDIN.gets.chomp
    @svn.commit root_dir, @message
  end

  desc "Add and delete appropriate files, then commit"
  task :smart_commit => [:add, :del, :commit]

  desc "Import current directory to repository" 
  task :import => 'check:version' do
    @svn.run "info #{root_dir}", :message => "ERROR: Should not be a checkout path", :expect_error => true
    puts "Please provide the repository URL:"
    @url = STDIN.gets.chomp
    @svn.run "import #{@url} -m 'Bootstrapping #{root_dir.split('/').last} into the repository.'"
  end

  task :checkout => [:import, :move_old_path] do
    @svn.run "co #{@url} #{root_dir}"
  end

  #desc "Deletes the current directory, depends on importing to the repository"
  task :delete_old_path => :checkout do
    system "rm -rf #{root_dir}_old"
  end

  task :move_old_path => :import do
    system "mv #{root_dir} #{root_dir}_old"
  end

  desc "Bootstrap from a new Rails dir to a checkout from the repository" 
  task :bootstrap => [:import, :move_old_path, :checkout, 'ignore:rails', :delete_old_path] do
    puts "\n\n======================================================="
    puts "Successfully bootstrapped. You are ready to begin work."
    puts "Here is the current svn log for your new project:"
    @svn.run "log #{root_dir}"
    puts "\n\nYou probably want to issue the following command to get to the new project directory:"
    puts "cd ../#{root_dir.split('/').last}"
  end
  
#### from http://blog.unquiet.net/archives/2005/11/06/helpful-rake-tasks-for-using-rails-with-subversion/

  namespace :rails do
    desc "Hook into edge rails via svn:externals. Use rails:freeze:edge for the more traditional edge rails"
    task :edge => 'check:info' do
      @svn.propadd 'svn:externals', "#{root_dir(false)}/vendor/", "rails http://dev.rubyonrails.org/svn/rails/trunk"      
      @svn.run 'up'
    end
  end

  desc "Clean .svn directories out of a subdirectory"
  task :clean do
    puts "What directory do you want to de-version? (Be careful with this!)"
    dir = STDIN.gets.chomp
    `find #{dir} -name .svn -print0 | xargs -0 rm -rf` if dir.length > 0
  end

  desc "Add new files to subversion"
  task :add do
     @svn.run "status | grep '^\?' | sed -e 's/? *//' | sed -e 's/ /\ /g' | xargs svn add"
  end

  desc "Remove deleted files from version control."
  task :del do 
    @svn.run "status | grep '^!' | sed -e 's/? *//' | sed -e 's/ /\ /g' | xargs svn del"
  end

end