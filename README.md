![logo](https://user-images.githubusercontent.com/8457808/77265724-d5123300-6c73-11ea-96fd-e3a56177ada7.png)

# Freshreader

Save content to read later. Read what's most interesting. **Get a fresh start every week.**

Drawing inspiration from Instapaper and Pocket, Freshreader aims to be the place where you save content from around the Web to enjoy later. The major difference is this: Freshreader automatically lets go of saved content after 7 days. No more massive reading backlog: just what is still relevant.

Don't worry — if it's important, it'll somehow come back into your life.

Made using Ruby on Rails.

## Screenshot

![screenshot](https://user-images.githubusercontent.com/8457808/77265722-d4799c80-6c73-11ea-873f-1aad3d82629b.png)

## Dependencies

At the time of writing this, the following dependencies are recommended:

- Ruby 2.7.0
- Rails 6.0.2.2
- PostgreSQL 10.12

## Getting started

1. Setup two PostgreSQL database: one named `freshreader_development`, the other `freshreader_test`.
2. Install project dependencies using `bundle`.
3. Start the application using `rails s`.

### Deploying

You're free to deploy the application wherever/however you see fit. https://freshreader.app/ is deployed on Heroku.

## Contributing

For bug fixes, documentation changes, and small features:  

1. [Fork it](https://github.com/maximevaillancourt/freshreader/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)  
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)  
5. Create a new [Pull Request](https://github.com/maximevaillancourt/freshreader/compare)

## Licensing

The code in this project is licensed under MIT license. See the [LICENSE](LICENSE).
