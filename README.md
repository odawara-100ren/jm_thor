# JmThor

JmThor is a tool to register and to manage manpower.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'jm_thor', github: "odawara-100ren/jm_thor"
```

And then execute:

 ```
 $ bundle
 ```

Or you can install it by yourself.
[`specific_install`](https://github.com/rdp/specific_install) gem is needed for gem install.

```
$ gem install specific_install
$ gem specific_install -l "https://github.com/odawara-100ren/jm_thor"
```

## Usage

### 登録

- -t: 作業内容（チケット名）
- -m: 工数（h, mをサポート、小数をサポート）
- -c: コメント

```
$ jm_thor -t SJDEV-123 -m 5.5h -c 設計、仮実装
```

### 閲覧

```
# 引数なし（当日のログを出力）
$ jm_thor jmlog
# 日付を指定
$ jm_thor jmlog --date 2017-09-01
# 作業名を指定
$ jm_thor jmlog --name SJDEV-123
```

### Example

```
$ jm_thor -t SJDEV-130 -m 1.5h -c 疲れました
[2017-09-14: SJDEV-130 1.5h 疲れました]を登録しました。
$ jm_thor jmlog
2017-09-14
チケット名：	SJDEV-130
工数：	1.5 h
コメント：	疲れました
$ jm_thor -t SJDEV-230 -m 100m -c 設計、実装
[2017-09-14: SJDEV-230 100m 設計、実装]を登録しました。
$ jm_thor jmlog
2017-09-14
チケット名：	SJDEV-130
工数：	1.5 h
コメント：	疲れました
チケット名：	SJDEV-230
工数：	1.67 h
コメント：	設計、実装
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/jm_thor. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the JmThor project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/jm_thor/blob/master/CODE_OF_CONDUCT.md).
