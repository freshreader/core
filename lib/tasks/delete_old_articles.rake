desc "Delete articles older than 14 days"
task delete_old_articles: :environment do
  old_articles = Article.where('created_at < ?', 14.days.ago)
  articles_to_delete = old_articles.size
  old_articles.destroy_all
  puts "Destroyed #{articles_to_delete} article#{articles_to_delete == 1 ? '' : 's'}."
end
