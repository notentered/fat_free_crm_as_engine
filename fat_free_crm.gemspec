# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name = %q{fat_free_crm}
  s.version = "0.11.0"
  s.platform    = Gem::Platform::RUBY
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Michael Dvorkin"]
  s.date = %q{2011-08-03}

  s.summary = %q{Fat Free CRM Engine}
  s.description = %q{Fat Free CRM Engine for Rails 3.}
  s.email = %q{mike@fatfreecrm.com}
  s.homepage = %q{http://www.fatfreecrm.com}

  s.extra_rdoc_files = [
    "LICENSE",
    "README.rdoc",
    "CONTRIBUTORS",
    "CHANGELOG"
  ]

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency(%q<rails>, ["= 3.0.7"])
  s.add_runtime_dependency(%q<rake>, ["= 0.8.7"])
  s.add_runtime_dependency(%q<acts_as_commentable>, [">= 3.0.1"])
  s.add_runtime_dependency(%q<haml>, [">= 3.1.1"])
  s.add_runtime_dependency(%q<sass>, [">= 3.1.1"])
  s.add_runtime_dependency(%q<paperclip>, [">= 2.3.3"])
  s.add_runtime_dependency(%q<will_paginate>, ["= 3.0.pre2"])
  s.add_runtime_dependency(%q<jeweler>, [">= 1.6.4"])
  s.add_runtime_dependency(%q<calendar_date_select>, ["= 1.16.1"])
  s.add_runtime_dependency(%q<dynamic_form>, ["= 1.0.0"])
  s.add_development_dependency(%q<ruby-debug19>, [">= 0"])
  s.add_development_dependency(%q<annotate>, [">= 2.4.0"])
  s.add_development_dependency(%q<awesome_print>, [">= 0.3.1"])
  s.add_development_dependency(%q<test-unit>, ["= 1.2.3"])
  s.add_development_dependency(%q<rspec-rails>, [">= 2.5.0"])
  s.add_development_dependency(%q<faker>, [">= 0.9.5"])
  s.add_development_dependency(%q<factory_girl>, [">= 1.3.3"])
end

