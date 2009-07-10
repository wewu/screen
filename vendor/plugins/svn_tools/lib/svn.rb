require 'tempfile'

#from http://www.bigbold.com/snippets/posts/show/2317
#APP_VERSION = IO.popen("svn info").readlines[2].split(' ').last

class Subversion

  def run( command, options = {} )
    defaults = { :message => "ERROR: svn error", :expect_error => false, :capture_output => false }
    options = defaults.merge(options)
    
    command_line = "svn #{command}"
    puts "running: #{command_line}"
    if options[:capture_output]
      output = `#{command_line}`
      result = $?.success?
      puts output
    else
      result = system command_line
    end
    if (options[:expect_error] && result) || (!options[:expect_error] && !result)
      $stderr.puts "#{options[:message]} running #{command_line}"
      exit 1
    end
    output
  end

  def ignore( filename, directory )
    propadd 'ignore', directory, filename
  end
  
  def propadd( property, dir, content )
    originals = propget( property, dir )
    new_ones = (originals + [content]).uniq
    propset( property, dir, new_ones )
  end

  def propdel( property, dir, content )
    originals = propget( property, dir )
    new_ones = (originals - [content]).uniq
    propset( property, dir, new_ones )
  end

  def propget( property, dir )
    ext = run "propget #{property} \"#{dir}\"", :capture_output => true
    ext.reject{ |line| line.strip == '' }.map {|line| line.strip}
  end

  def commit( dir, message )
    Tempfile.open("svn-commit") do |file|
      file.write(message)
      file.flush
      run "commit #{dir} -F \"#{file.path}\""
    end
  end

  def propset( property, dir, lines )
    unless lines.is_a? String
      lines = lines.join("\n")
    end
    Tempfile.open("svn-set-prop") do |file|
      file.write(lines)
      file.flush
      run "propset -q #{property} -F \"#{file.path}\" \"#{dir}\""
    end
  end
  
end