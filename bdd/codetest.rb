#!/usr/bin/env ruby
#/ This script uses rspec, to test ruby code, within this repo.  The script
#/ accepts a ruby version (as an option), installs the specified ruby version
#/ via rvm, installs the ruby gem bundler and invokes the use of rspec.
# ** Tip: use #/ lines to define the --help usage message.
require 'optparse'
require 'logger'

# Initialize simple logging
# =========================
class LogIt
  def self.log
    if @logger.nil?
      @logger = Logger.new("| tee ./bdd/codetest.log")
      @logger.level = Logger::DEBUG
      @logger.datetime_format = '%Y-%m-%d %H:%M:%S '
    end
    @logger
  end
end

def usage(tips, more)
  puts tips
  puts
  puts more
  exit
end

def error(msg,status)
  LogIt.log.error "#{msg}: exit status #{status}. Exiting."
  exit 1
end

def source_file(file)
  LogIt.log.info "Sourcing file #{file}"
  system ". #{file}"
  error("Unable to source #{file}", $?.exitstatus) if $?.exitstatus > 0
end

def ensure_rvm()
  LogIt.log.info "Installing rvm from rvm.io"
  system "gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB"
  error("Unable to import keys from a keyserver using gpg", $?.exitstatus) if $?.exitstatus > 0

  system "curl -sSL https://get.rvm.io | bash -s stable --ruby"
  error("Unable to install rvm from rvm.io", $?.exitstatus) if $?.exitstatus > 0
end

rvm_config = File.expand_path('~/.rvm/scripts/rvm')
valid_versions = [ '1.9.3', '2.0.0', '2.1.1' ]

tips         = `grep ^#/<'#{$0}'|cut -c4-`
versions_msg = "Valid ruby versions for this test: #{valid_versions}"

missing = []
options = {}

parser = OptionParser.new do |opts|
  opts.banner = "Usage: #{$0} [options]"
  opts.on("-r", "--ruby VERSION", "Ruby versions for testing: #{valid_versions}. Required.") { |v| options[:ruby] = v }
  opts.on_tail("-h", "--help", "--usage", "Show help/usage message and quit.") { usage(tips, opts) }
end

#slurp options
parser.parse!

missing << '-r' if options[:ruby].nil?

if not missing.empty?
  puts
  puts "Missing options: #{missing.join(', ')}"
  puts
  usage(tips,parser)
end

LogIt.log.info "Starting #{$0} -r #{options[:ruby]}"

# Ensure ruby version option is in valid_versions
# ===============================================
if not valid_versions.include?(options[:ruby])
  LogIt.log.info ""
  LogIt.log.info "Invalid ruby version entered."
  LogIt.log.info "Valid versions for this test, are: #{valid_versions}"
  LogIt.log.info
  puts parser
  exit 2
end


# Ensure rvm installed... and such.
# =================================
ensure_rvm if not File.exists?( rvm_config )

source_file(rvm_config)

# Install ruby version for tests
# ==============================
LogIt.log.info "Installing ruby #{options[:ruby]} via rvm"
system "rvm install ruby-#{options[:ruby]}"
error("Unable to install ruby version #{options[:ruby]} via rvm", $?.exitstatus) if $?.exitstatus > 0

# Tell rvm to use specified version of ruby
# =========================================
LogIt.log.info "rvm use ruby #{options[:ruby]}"
system "rvm use {options[:ruby]}"
error("Unable to use ruby #{options[:ruby]}, via rvm", $?.exitstatus) if $?.exitstatus > 0

# Install ruby gem bundler
# ========================
LogIt.log.info "Installing ruby gem bundler"
system "gem install bundler"
error("Unable to install ruby gem bundler", $?.exitstatus) if $?.exitstatus > 0

# Install the dependencies specified in Gemfile.
# Sets: max # parallel download/install jobs; retry failed network/git requests.
# ==============================================================================
LogIt.log.info "Installing dependencies found within Gemfile"
system "bundle install --jobs=3 --retry=3"
error("Unable to install dependencies via bundle install", $?.exitstatus) if $?.exitstatus > 0

# Execute rspec in the context of the bundle
# ==========================================
LogIt.log.info "Executing rspec, via bundler"
system "bundle exec rspec spec --color --format documentation --order random"
error("Unable to execute rspec via bundle", $?.exitstatus) if $?.exitstatus > 0

LogIt.log.close

exit 0