# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'tasks/rails'

namespace :build do
  desc "Build the Flex components in test mode"
  task(:test) do
    puts %x[mxmlc.exe -compiler.source-path=src -compiler.source-path+=public -library-path+=libs -link-report=report.xml --include-libraries libs\\FunFXAdapter.swc libs\\automation_agent.swc libs\\automation.swc libs\\automation_agent_rb.swc -output=public\\Main.swf src\\Main.mxml]
    puts %x[mxmlc.exe -compiler.source-path=src -compiler.source-path+=public -library-path+=libs -load-externs=report.xml -output=public\\modules\\Core.swf src\\modules\\Core.mxml]
    puts %x[del report.xml]
  end

  desc "Build the Flex components in production mode"
  task(:production) do
    puts %x[mxmlc.exe -compiler.source-path=src -compiler.source-path+=public -library-path+=libs -link-report=report.xml -output=public\\Main.swf src\\Main.mxml]
    puts %x[mxmlc.exe -compiler.source-path=src -compiler.source-path+=public -library-path+=libs -load-externs=report.xml -output=public\\modules\\Core.swf src\\modules\\Core.mxml]
    puts %x[del report.xml]
  end
end