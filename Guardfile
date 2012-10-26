# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard :rspec do
  # Watch all of the files in the spec folder starting with any number of characters followed by _spec.rb 
  watch(%r{^spec/.+_spec\.rb$})

  # Watch the files in the lib directory and then run the tests associated with the changed file
  watch(%r{^lib/jacob/(.+)\.rb$})     { |m| "spec/#{m[1]}_spec.rb" }

  # Watch my spec helper and if anything changes run all the tests again
  watch('spec/spec_helper.rb') {'spec/'}

  # Watch the file that runs the project and if it gets change run all the tests again
  watch('bin/jacob.rb') {'spec/'}

end

# Watch my gem file and auto download any new gems
guard :bundler do
  watch('Gemfile')
end