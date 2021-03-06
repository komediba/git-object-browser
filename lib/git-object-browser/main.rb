# -*- coding: utf-8 -*-
module GitObjectBrowser
  class Main
    def execute
      host = '127.0.0.1'
      port = 8080
      dump = nil
      step = nil
      diff_dir = nil
      nextstep = false
      opts = OptionParser.new do |opts|
        opts.on('-p', '--port PORT', 'port number') do |value|
          port = value.to_i if 0 < value.to_i
        end
        opts.on('-b', '--bind HOST', 'address to bind') do |value|
          host = value
        end
        opts.on('-d', '--dump PATH', 'dump .git as JSON and HTMLs') do |value|
          dump = value
        end
        opts.on('--step STEP', 'dump JSONs into sub directory') do |value|
          step = value
        end
        opts.on('--diff OLD_JSON_DIR', 'dump JSONs with diff data') do |value|
          diff_dir = value
        end
        opts.on('--next', 'same with --step step${N} --diff step${N-1}') do |value|
          nextstep = true
        end
        opts.on_tail("-h", "--help", "show this help.") do
          puts opts
          exit
        end
        opts.on_tail("-v", "--version", "show version.") do
          puts "git-object-browser " + VERSION
          exit
        end
        opts.parse!(ARGV)
      end
      target = find_target(ARGV[0])
      if dump.nil?
        GitObjectBrowser::Server::Main.execute(target, host, port)
      else
        if nextstep
          step = :next
          diff_dir = nil
        end
        GitObjectBrowser::Dumper::Main.execute(target, dump, step, diff_dir)
      end
    end

    def find_target(target = nil, git_dir_name = '.git')
      target ||= Dir::pwd
      return target if git_dir?(target)

      if File.directory?(target)
        dir = parent_git_dir(target, git_dir_name)
        return dir if dir
      end

      raise 'Git directory not found'
    end

    def git_dir?(dir)
      return false unless File.directory?(dir)
      return false unless File.directory?(File.join(dir, 'objects'))
      return false unless File.file?(File.join(dir, 'HEAD'))
      true
    end

    def parent_git_dir(target, git_dir_name)
      begin
        gitdir = File.join(target, git_dir_name)
        return gitdir if git_dir?(gitdir)
        lastdir = target
        target = File.dirname(target)
      end while lastdir != target
      nil
    end
    private :parent_git_dir
  end
end
