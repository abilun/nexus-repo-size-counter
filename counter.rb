require 'mixlib/cli'
require 'json'
require 'benchmark'

def get_value(string)
  /(?<==).*$/.match(string).to_s
end

# CLI arguments class
class CLI
  include Mixlib::CLI

  option :path,
         short: '-p PATH',
         long: '--path PATH',
         required: true,
         description: 'Directory to process'

  option :help,
         short: '-h',
         long: '--help',
         description: 'Show this message',
         on: :tail,
         boolean: true,
         show_options: true,
         exit: 0
end

cli = CLI.new
cli.parse_options
Dir.chdir cli.config[:path]

repos = {}
# Iterate over all .properties files
time = Benchmark.realtime do
  Dir.glob('content/**/*.properties') do |filename|
    File.open(filename, 'r') do |file|
      repo_name = ''
      is_deleted = false
      size = 0
      file.each_line do |line|
        is_deleted = true if line =~ /deleted=true/
        repo_name = get_value(line) if line =~ /repo-name/
        size = get_value(line).to_i if line =~ /size/
      end
      next if is_deleted || repo_name.empty?

      repos[repo_name] = 0 unless repos.key?(repo_name)
      repos[repo_name] += size
    end
  end
end

repos.each do |repo, size|
  puts "Repo name: #{repo}"
  puts "Repo size: #{size}"
  puts '-' * 20
end

puts "Elapsed time: #{time}"
