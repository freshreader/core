require 'test_helper'
require 'rake'

class DeleteOldArticlesTest < ActiveSupport::TestCase
  def setup
    Freshreader::Application.load_tasks if Rake::Task.tasks.empty?

    @user = User.new(account_number: '1234123412341234')
    @user.save
  end

  def teardown
    @user.destroy
  end

  test "task deletes articles created or updated more than 7 days ago" do
    @article_created_8_days_ago = Article.new(url: 'https://freshreader.app/old', user: @user, created_at: 8.days.ago, updated_at: 8.days.ago)
    assert @article_created_8_days_ago.save
    @article_created_6_days_ago = Article.new(url: 'https://freshreader.app/less-old', user: @user, created_at: 6.days.ago, updated_at: 6.days.ago)
    assert @article_created_6_days_ago.save

    Rake::Task["delete_old_articles"].invoke

    remaining_articles = ::Article.all
    refute_includes remaining_articles, @article_created_8_days_ago
    assert_includes remaining_articles, @article_created_6_days_ago
  end
end
