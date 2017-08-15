require "spec_helper"
# require "string_io"

RSpec.describe JiraManpower do
  before do
    @con = JiraManpower::DatabaseUtil.connect
  end

  describe JiraManpower::Calculator do
    before do
      @cal = JiraManpower::Calculator.new
    end
    describe "#convert" do
      it do
        expect(@cal.convert("1000 m")).to eq 1000
        expect(@cal.convert("10 h")).to eq 600
        expect(@cal.convert("1.567 h")).to eq (1.567 * 60).to_i
      end
    end

    describe "#disp_format" do
      it do
        expect(@cal.disp_format(100)).to eq "#{(100/60.0).round(2)} h"
        expect(@cal.disp_format(59)).to eq "59 m"
        expect(@cal.disp_format(0)).to eq "0 m"
      end
    end

    describe "#to_minutes" do
      it do
        expect(@cal.to_minutes(10, "h")).to eq 600
        expect(@cal.to_minutes(500, "m")).to eq 500
      end
    end
  end

  describe JiraManpower::Register do
    before do
      @reg = JiraManpower::Register.new
    end
    describe "#register" do
      it do
        @reg.register("SJDEV-10", "100m", "設計、開発、レビュー")
        res = @con.execute("select * from manpowers")
        expect(res.size).to eq 1
      end
    end
  end

  describe JiraManpower::Logger do
    before do
      @reg = JiraManpower::Register.new
      @reg.register("SJDEV-10", "100m", "設計")
      today = Date.today
      allow(Date).to receive(:today).and_return(today + 1)
      @reg.register("SJDEV-10", "1h", "開発")
      allow(Date).to receive(:today).and_return(today + 2)
      @reg.register("SJDEV-10", "1.5h", "テスト、修正")
      @log = JiraManpower::Logger.new
    end

    describe "#show_log" do
      context "when ticket name is passed, " do
        it "show_log should not raise error." do
          expect{ @log.show_log("SJDEV-10") }.to output(/チケット名/).to_stdout
          expect{ @log.show_log("SJDEV-10") }.not_to output(/#{Date.today.to_s}/).to_stdout
        end
      end
      context "when ticket name is not passed, " do
        it "show_log should puts today's log." do
          expect{ @log.show_log }.to output(/本日（#{Date.today}）のログ.+/).to_stdout
        end
      end
    end

    describe "#show_log_all" do
      it do
        expect{ @log.show_log_all }.to output(/--------------/).to_stdout
      end
    end
  end

  describe JiraManpower::DatabaseUtil do
    describe "#connect" do
      it { expect(@con).not_to be_nil }

      it "manpowers table should have 0 records." do
        res = @con.execute("select * from manpowers")
        expect(res.size).to eq 0
      end
    end

    describe ".select_sql" do
      before do
        @sql = JiraManpower::DatabaseUtil.select_sql(l_where)
      end

      context "when true is passed, " do
        let(:l_where) { true }
        it "sql should include 'where'." do
          expect(@sql.include?("where")).to eq true
        end
      end

      context "when false is passed, " do
        let(:l_where) { false }
        it "sql should not include 'where'." do
          expect(@sql.include?("where")).to eq false
        end
      end
    end
  end
end
