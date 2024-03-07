if RUBY_VERSION < "3.4.0"
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

  appraise "rails-7-0" do
    group :test do
      gem "activerecord", "~> 7.0.0"
    end
  end
end

appraise "rails-7-1" do
  group :test do
    gem "activerecord", "~> 7.1.0"
  end
end

if RUBY_VERSION >= "3.1.0"
  appraise "rails-edge" do
    group :test do
      gem "activerecord", github: "rails/rails", branch: "main"
    end
  end
end
