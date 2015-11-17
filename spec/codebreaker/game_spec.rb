require 'spec_helper'

module Codebreaker
  describe Game do
    context "#start" do
      let(:game) { Game.new }

      before do
        game.start
      end

      it "saves secret code" do
        expect(game.instance_variable_get(:@secret_code)).not_to be_empty
      end

      it "saves 4 numbers secret code" do
        expect(game.instance_variable_get(:@secret_code).count).to eq(CODE_SIZE)
      end

      it "saves 4 numbers with Fixnum class" do
        expect(game.instance_variable_get(:@secret_code).each(&:class)).to contain_exactly(([Fixnum] * CODE_SIZE).flatten)
      end

      it "saves secret code with numbers from 1 to 6" do
        expect(game.instance_variable_get(:@secret_code).join).not_to match(/[^1-6]+/)
      end

      it "resets user code" do
        expect(game.instance_variable_get(:@user_code)).to be_empty
      end

      it "resets hint number" do
        expect(game.instance_variable_get(:@hint_number)).to be_empty
      end

      it "resets the count of hints" do
        expect(game.instance_variable_get(:@hint_count)).to eq(HINT_COUNT)
      end

      it "resets score" do
        expect(game.instance_variable_get(:@score)).to eq(SCORE)
      end

      it "resets attempts" do
        expect(game.instance_variable_get(:@attempts)).to eq(ATTEMPTS)
      end
    end
    
    context "#guess" do
      let(:game) { Game.new }

      before do
        game.start
      end

        it "returns the Array" do
          expect(game.guess(1234)).to be_a(Array)
        end

        it "returns '++++' if guess the secret code" do
          game.instance_variable_set(:@secret_code, [1, 2, 3, 4])
          expect(game.guess(1234)).to eq(['+', '+', '+', '+'])
        end

        it "returns '+++'" do
          game.instance_variable_set(:@secret_code, [2, 2, 3, 4])
          expect(game.guess(1234)).to eq(['+', '+', '+'])
        end

        it "returns '+-'" do
          game.instance_variable_set(:@secret_code, [1, 3, 2, 3])
          expect(game.guess(1256)).to eq(['+', '-'])
        end

        it "returns '++'" do
          game.instance_variable_set(:@secret_code, [4, 3, 2, 3])
          expect(game.guess(5523)).to eq(['+', '+'])
        end

        it "returns '----'" do
          game.instance_variable_set(:@secret_code, [1, 2, 3 ,4])
          expect(game.guess(4321)).to eq(['-', '-', '-', '-'])
        end

        it "returns '+'" do
          game.instance_variable_set(:@secret_code, [2, 2, 2 ,2])
          expect(game.guess(1234)).to eq(['+'])
        end

        it "raises ArgumentError 'It must be a numeric code, or be 1..6'" do
          expect {game.guess(7890)}.to raise_error(ArgumentError, "It must be a numeric code, or be 1..6")
        end

        it "raises ArgumentError 'It must be a numeric code, or be 1..6'" do
          expect {game.guess('abcd')}.to raise_error(ArgumentError, "It must be a numeric code, or be 1..6")
        end

        it "raises ArgumentError \"Code length must be #{CODE_SIZE}\"" do
          expect {game.guess(123456)}.to raise_error(ArgumentError, "Code length must be #{CODE_SIZE}")
        end

        it "change attempts count by -1" do
          expect{game.guess(1234)}.to change{game.attempts}.by(-1)
        end

        it "change score by -10" do
          expect{game.guess(1234)}.to change{game.score}.by(-10)
        end

        it "raises AttemptsError, \"0 from #{ATTEMPTS} attempts left\"" do
          game.instance_variable_set(:@attempts, 0)
          expect {game.guess(1234)}.to raise_error(AttemptsError, "0 from #{ATTEMPTS} attempts left")
        end
      end

      context "#hint" do
        let(:game) { Game.new }

        before do
          game.start
        end

        it "returns hint" do
          game.instance_variable_set(:@secret_code, [1, 2, 3 ,4])
          expect(game.hint).to include(1).or include(2).or include(3).or include(4)
        end

        it "change hint count by -1" do
          expect{game.hint}.to change{game.hint_count}.by(-1)
        end

        it "raise HintCountError, \"Hint may be used only #{HINT_COUNT} times\"" do
          game.instance_variable_set(:@hint_count, 0)
          expect {game.hint}.to raise_error(HintCountError, "Hint may be used only #{HINT_COUNT} times")
        end
      end
  end
end
