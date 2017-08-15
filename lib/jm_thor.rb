require "jm_thor/version"
require "sqlite3"
require "pry" # TODO: remove this line.

module JiraManpower
  class DatabaseUtil
    def self.connect
      db = SQLite3::Database.new "jm.db"
      begin
        db.execute sql_create_table
        puts "'jm.db' created successfully."
      rescue => e
        # do nothing.
        # TODO: sql_create_tableをする前に存在確認
      end
      db
    end

    def self.sql_create_table
      <<-SQL
create table manpowers (
  id integer,
  ticket_name varchar(255),
  manpower integer,
  comment varchar(1000),
  date text
);
SQL
    end

    def self.insert_sql
      <<-SQL
insert into manpowers
  (ticket_name, manpower, comment, date)
  values
  (?, ?, ?, ?);
SQL
    end

    # @param [True/False] where 真ならチケット名を指定、偽なら指定なし
    def self.select_sql(where=true)
      sql = "select ticket_name, manpower, comment, date from manpowers "
      sql += "where ticket_name = ?" if where
      sql += "order by date"
      sql
    end

    def self.select_by_date_sql
      <<-SQL
select ticket_name, manpower, comment from manpowers
where date = ?
SQL
    end
  end

  class Logger
    def initialize
      @calc = Calculator.new
      @con = DatabaseUtil.connect
    end

    def show_datelog(date)
      raise "日付を指定してください。(フォーマット：YYYY-MM-DD)" unless date
      puts date
      res = @con.execute(DatabaseUtil.select_by_date_sql, [date])
      res.each do |name, mp, comment|
        puts <<-OUT
チケット名：\t#{name}
工数：\t#{@calc.disp_format(mp)}
コメント：\t#{comment}
OUT
      end
    end

    # 全ログを表示
    def show_log_all
      res = @con.execute(DatabaseUtil.select_sql(false))
      res.map{|_, _, _, date| date}.uniq.each do |date|
        puts date
        res.select{|r| r[3] == date}.each do |name, mp, comment, _|
          puts <<-OUT
-----------------------------------
チケット名：\t#{name}
工数合計：\t#{@calc.disp_format(mp)}
コメント：\t#{comment}
OUT
        end
      end
    end

    # 指定したチケットのログを表示
    # 無指定の場合、当日のログを表示
    # @param [String] ticket_name チケット名
    def show_log(ticket_name=nil)
      if ticket_name
        # チケット名指定の場合
        res = @con.execute(DatabaseUtil.select_sql, [ticket_name])
        if res.size == 0
          puts "#{ticket_name}に該当するチケット名が存在しません。"
          exit
        end
        sum = res.map{|name, mp, comment, date| mp}.inject(:+)
        # 日付は出さない
        puts <<-OUT
チケット名：\t#{ticket_name}
工数合計：\t#{@calc.disp_format(sum)}
コメント：
OUT
        # コメント一覧表示
        res.each { |_, _, comment| puts comment }
      else
        # チケット名無指定の場合
        # 当日のログを表示
        res = @con.execute(DatabaseUtil.select_sql(false))
        today = Date.today.to_s
        puts "本日（#{today}）のログ："
        res.select {|r| r[3] == today}.each do |name, mp, comment, _|
          puts <<-OUT
-----------------------------------
チケット名：\t#{name}
工数合計：\t#{@calc.disp_format(mp)}
コメント：\t#{comment}
OUT
        end
      end
    end
  end

  class Register
    def initialize
      @calc = Calculator.new
      @con = DatabaseUtil.connect
    end

    # @param [String] ticket_name チケット名。作業の対象を表す文言
    # @param [String] manpower 工数を表す文字列。
    def register(ticket_name, manpower, comment)
      mins = @calc.convert(manpower)
      date = Date.today.to_s
      @con.execute(DatabaseUtil.insert_sql, [ticket_name, mins, comment, date])
      puts "[#{date}: #{ticket_name} #{manpower} #{comment}]を登録しました。"
    rescue => e
      puts e.inspect
      puts "DB登録に失敗しました"
    end
  end

  class Calculator
    # @param [String] manpower 工数を表す文字列。e.g. "100m", "1.5h"
    def convert(manpower)
      m = /(\d+(?:\.\d+)?)\s*([hm])/.match(manpower)
      raise "工数のフォーマットが不適切です。" unless m

      to_minutes(m[1].to_f, m[2])
    end

    # @param [Float] time 時間を表す数値
    # @param [String] unit 時間の単位
    def to_minutes(time, unit)
      case unit
      when "h" then time * 60
      when "m" then time
      else raise "単位の指定が誤っています(hかmのみ)"
      end
    end

    # @param [Fixnum] mins 何分かを表す
    def disp_format(mins)
      if mins < 60
        "#{mins} m"
      else
        "#{(mins / 60.0).round(2)} h"
      end
    end
  end
end
