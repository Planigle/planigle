# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'tasks/rails'

@@Windows = RUBY_PLATFORM.include? "mswin32"

flex_compile = "mxmlc"
if @@Windows
  require 'win32/sound'
  include Win32
  flex_compile = flex_compile+".exe"
end

def normalize_paths(source)
  if @@Windows
    source
  else
    source.gsub("\\", "/")
  end
end

namespace :build do
  desc "Build the Flex components in test mode"
  task(:test) do
    puts %x[#{flex_compile} -target-player=10 -compiler.debug --services=src/services-config.xml -compiler.source-path=src -compiler.source-path+=public -library-path+=libs -link-report=report.xml #{normalize_paths(" --include-libraries libs\\FunFXAdapter.swc libs\\automation_agent.swc libs\\automation.swc libs\\automation_agent_rb.swc -output=public\\Main.swf src\\Main.mxml")}]
    puts %x[#{flex_compile} -target-player=10 -compiler.debug --services=src/services-config.xml -compiler.source-path=src -compiler.source-path+=public -library-path+=libs -load-externs=report.xml  #{normalize_paths("-output=public\\modules\\Core.swf src\\modules\\Core.mxml")}]
    File.delete('report.xml')
    if @@Windows
      Sound.play('tada.wav')
    end
  end

  desc "Build the Flex components in debug mode"
  task(:debug) do
    puts %x[#{flex_compile} -target-player=10 -compiler.debug --services=src/services-config.xml -compiler.incremental -compiler.source-path=src -compiler.source-path+=public -library-path+=libs -link-report=report.xml #{normalize_paths("-output=public\\Main.swf src\\Main.mxml")}]
    puts %x[#{flex_compile} -target-player=10 -compiler.debug --services=src/services-config.xml -compiler.incremental -compiler.source-path=src -compiler.source-path+=public -library-path+=libs -load-externs=report.xml #{normalize_paths("-output=public\\modules\\Core.swf src\\modules\\Core.mxml")}]
    File.delete('report.xml')
    if @@Windows
      Sound.play('tada.wav')
    end
  end

  desc "Build the Flex components in production mode"
  task(:production) do
    puts %x[#{flex_compile} -target-player=10 -show-unused-type-selector-warnings=false --services=src/services-config.xml -compiler.source-path=src -compiler.source-path+=public -library-path+=libs -link-report=report.xml #{normalize_paths("-output=public\\Main.swf src\\Main.mxml")}]
    puts %x[#{flex_compile} -target-player=10 --services=src/services-config.xml -compiler.source-path=src -compiler.source-path+=public -library-path+=libs -load-externs=report.xml #{normalize_paths("-output=public\\modules\\Core.swf src\\modules\\Core.mxml")}]
    File.delete('report.xml')
    if @@Windows
      Sound.play('tada.wav')
    end
  end
end

namespace :test do
  desc "Run the Flex tests in test/flex"
  Rake::TestTask.new(:flex => "db:test:prepare") do |t|
    t.libs << "test" 
    t.pattern = 'test/flex/**/*_test.rb'
    t.verbose = true
  end
end