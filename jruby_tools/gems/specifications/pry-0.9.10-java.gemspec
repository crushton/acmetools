# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "pry"
  s.version = "0.9.10"
  s.platform = "java"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["John Mair (banisterfiend)", "Conrad Irwin"]
  s.date = "2012-07-15"
  s.description = "An IRB alternative and runtime developer console"
  s.email = ["jrmair@gmail.com", "conrad.irwin@gmail.com"]
  s.executables = ["pry"]
  s.files = ["bin/pry"]
  s.homepage = "http://pry.github.com"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.24"
  s.summary = "An IRB alternative and runtime developer console"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<coderay>, ["~> 1.0.5"])
      s.add_runtime_dependency(%q<slop>, ["~> 3.3.1"])
      s.add_runtime_dependency(%q<method_source>, ["~> 0.8"])
      s.add_development_dependency(%q<bacon>, ["~> 1.1"])
      s.add_development_dependency(%q<open4>, ["~> 1.3"])
      s.add_development_dependency(%q<rake>, ["~> 0.9"])
      s.add_runtime_dependency(%q<spoon>, ["~> 0.0"])
    else
      s.add_dependency(%q<coderay>, ["~> 1.0.5"])
      s.add_dependency(%q<slop>, ["~> 3.3.1"])
      s.add_dependency(%q<method_source>, ["~> 0.8"])
      s.add_dependency(%q<bacon>, ["~> 1.1"])
      s.add_dependency(%q<open4>, ["~> 1.3"])
      s.add_dependency(%q<rake>, ["~> 0.9"])
      s.add_dependency(%q<spoon>, ["~> 0.0"])
    end
  else
    s.add_dependency(%q<coderay>, ["~> 1.0.5"])
    s.add_dependency(%q<slop>, ["~> 3.3.1"])
    s.add_dependency(%q<method_source>, ["~> 0.8"])
    s.add_dependency(%q<bacon>, ["~> 1.1"])
    s.add_dependency(%q<open4>, ["~> 1.3"])
    s.add_dependency(%q<rake>, ["~> 0.9"])
    s.add_dependency(%q<spoon>, ["~> 0.0"])
  end
end
