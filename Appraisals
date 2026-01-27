if RUBY_VERSION < "3.1.0"
  appraise "rails-6-0" do
    group :test do
      gem "activerecord", "~> 6.0.0"
    end
  end

  appraise "rails-6-1" do
    group :test do
      gem "activerecord", "~> 6.1.0"
    end
  end
end

if RUBY_VERSION < "3.4.0"
  appraise "rails-7-0" do
    group :test do
      gem "activerecord", "~> 7.0.0"
    end
  end

  appraise "rails-7-1" do
    group :test do
      gem "activerecord", "~> 7.1.0"
    end
  end
end

if RUBY_VERSION >= "3.1.0" && RUBY_VERSION < "4.0.0"
  appraise "rails-7-2" do
    group :test do
      gem "activerecord", "~> 7.2.0"
    end
  end
end

if RUBY_VERSION >= "3.2.0"
  appraise "rails-8-0" do
    group :test do
      gem "activerecord", "~> 8.0.0"
      gem "sqlite3", "~> 2.9"
      gem "ostruct", "~> 0.6.3"
    end
  end
end

if RUBY_VERSION >= "3.3.0"
  appraise "rails-8-1" do
    group :test do
      gem "activerecord", "~> 8.1.0"
      gem "sqlite3", "~> 2.9"
      gem "ostruct", "~> 0.6.3"
    end
  end

  appraise "rails-edge" do
    group :test do
      gem "activerecord", github: "rails/rails", branch: "main"
      gem "sqlite3", "~> 2.9"
      gem "ostruct", "~> 0.6.3"
    end
  end
end
