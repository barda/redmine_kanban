# Generated by jeweler
# DO NOT EDIT THIS FILE
# Instead, edit Jeweler::Tasks in Rakefile, and run `rake gemspec`
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{redmine_kanban}
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Eric Davis"]
  s.date = %q{2009-10-14}
  s.description = %q{The Redmine Kanban plugin is used to manage issues according to the Kanban system of project management.}
  s.email = %q{edavis@littlestreamsoftware.com}
  s.extra_rdoc_files = [
    "README.rdoc"
  ]
  s.files = [
    "COPYRIGHT.txt",
     "CREDITS.txt",
     "GPL.txt",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "app/controllers/kanbans_controller.rb",
     "app/helpers/kanbans_helper.rb",
"app/controllers/kanban_iteration_controller.rb",
     "app/helpers/kanbans_helper.rb",
     "app/models/kanban.rb",
     "app/models/kanban_issue.rb",
     "app/models/unknown_user.rb",
     "app/views/kanban_iteration/_active.html.erb",
     "app/views/kanban_iteration/_backlog.html.erb",
     "app/views/kanban_iteration/_empty_issue.html.erb",
     "app/views/kanban_iteration/_finished.html.erb",
     "app/views/kanban_iteration/_grouped_issues.html.erb",
     "app/views/kanban_iteration/_incoming.html.erb",
     "app/views/kanban_iteration/_issue.html.erb",
     "app/views/kanban_iteration/_quick.html.erb",
     "app/views/kanban_iteration/_selected.html.erb",
     "app/views/kanban_iteration/_testing.html.erb",
     "app/views/kanban_iteration/_user.html.erb",
     "app/views/kanban_iteration/show.html.erb",
     "app/models/kanban.rb",
     "app/models/kanban_issue.rb",
     "app/models/unknown_user.rb",
     "app/views/kanbans/_active.html.erb",
     "app/views/kanbans/_backlog.html.erb",
     "app/views/kanbans/_empty_issue.html.erb",
     "app/views/kanbans/_finished.html.erb",
     "app/views/kanbans/_grouped_issues.html.erb",
     "app/views/kanbans/_incoming.html.erb",
     "app/views/kanbans/_issue.html.erb",
     "app/views/kanbans/_quick.html.erb",
     "app/views/kanbans/_selected.html.erb",
     "app/views/kanbans/_testing.html.erb",
     "app/views/kanbans/_user.html.erb",
     "app/views/kanbans/show.html.erb",
     "app/views/settings/_kanban_settings.html.erb",
     "assets/javascripts/jquery-1.3.2.min.js",
     "assets/javascripts/jquery-ui-1.7.2.custom.min.js",
     "assets/javascripts/jquery.json-1.3.min.js",
     "assets/javascripts/kanban.js",
     "assets/stylesheets/redmine_kanban.css",
     "config/locales/en.yml",
     "config/routes.rb",
     "init.rb",
     "lang/en.yml",
     "lib/redmine_kanban/issue_patch.rb",
     "lib/redmine_kanban/kanban_compatibility.rb",
     "lib/tasks/plugin_stat.rake",
     "rails/init.rb",
     "test/blueprints/blueprint.rb",
     "test/functional/kanbans_controller_test.rb",
     "test/test_helper.rb",
     "test/unit/issue_test.rb",
     "test/unit/kanban_issue_test.rb",
     "test/unit/kanban_test.rb",
     "test/unit/sanity_test.rb"
  ]
  s.homepage = %q{https://projects.littlestreamsoftware.com/projects/TODO}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{redmine_kanban}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{The Redmine Kanban plugin is used to manage issues according to the Kanban system of project management.}
  s.test_files = [
    "test/unit/kanban_issue_test.rb",
     "test/unit/issue_test.rb",
     "test/unit/kanban_test.rb",
     "test/unit/sanity_test.rb",
     "test/test_helper.rb",
     "test/functional/kanbans_controller_test.rb",
     "test/blueprints/blueprint.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
