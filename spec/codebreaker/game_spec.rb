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

      it "saves secret code as Array" do
        expect(game.instance_variable_get(:@secret_code)).to be_a(Array)
      end

      it "saves 4 numbers secret code" do
        expect(game.instance_variable_get(:@secret_code).count).to eq(CODE_SIZE)
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

        it "returns '++++' if guess the secret code" do
          game.instance_variable_set(:@secret_code, [2, 2, 3, 2])
          expect(game.guess(2222)).to eq(['+', '+', '+'])
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

    context "#win?" do
      let(:game) { Game.new }

      before do
        game.start
        game.instance_variable_set(:@secret_code, [1, 2, 3, 4])
      end

      it "returns true if user wins game" do
        game.guess(1234)
        expect(game.win?).to be true
      end

      it "returns false if the user has not yet won a game" do
        game.guess(4321)
        expect(game.win?).to be false
      end
    end

    context "#lose?" do
      let(:game) { Game.new }

      before do
        game.start
      end

      it "returns true if user loses game" do
        game.instance_variable_set(:@attempts, 0)
        expect(game.lose?).to be true
      end

      it "returns false if the user has not yet lose a game" do
        game.instance_variable_set(:@attempts, 1)
        expect(game.lose?).to be false
      end
    end

    context "#attempts_left?" do
      let(:game) { Game.new }

      before do
        game.start
      end

      it "returns true if the user has attempts" do
        game.instance_variable_set(:@attempts, 1)
        expect(game.attempts_left?).to be true
      end

      it "returns false if the user has no attempts" do
        game.instance_variable_set(:@attempts, 0)
        expect(game.attempts_left?).to be false
      end
    end

    context "#have_hint?" do
      let(:game) { Game.new }

      before do
        game.start
      end

      it "returns true if the user has hint" do
        game.instance_variable_set(:@hint_count, 1)
        expect(game.have_hint?).to be true
      end

      it "returns false if the user has no hint" do
        game.instance_variable_set(:@hint_count, 0)
        expect(game.have_hint?).to be false
      end
    end

    context "#matching_numbers" do
      let(:game) { Game.new }

      before do
        game.start
        game.instance_variable_set(:@secret_code, [1, 3, 2, 4])
        game.instance_variable_set(:@user_code, [6, 2, 6, 4])
      end

      it "returns matching numbers" do
        expect(game.matching_numbers).to include(2, 4)
      end

      it "returns Array of matching numbers" do
        expect(game.matching_numbers).to be_a(Array)
      end
    end

    context "#exact_matching_numbers" do
      let(:game) { Game.new }

      before do
        game.start
        game.instance_variable_set(:@secret_code, [1, 3, 2, 4])
        game.instance_variable_set(:@user_code, [3, 3, 3, 4])
      end

      it "returns exact matching numbers" do
        expect(game.exact_matching_numbers).to include(3, 4)
      end

      it "returns Array of exact matching numbers" do
        expect(game.exact_matching_numbers).to be_a(Array)
      end
    end

    context "#not_exact_matching_numbers" do
      let(:game) { Game.new }

      before do
        game.start
        game.instance_variable_set(:@secret_code, [1, 2, 3, 4])
        game.instance_variable_set(:@user_code, [4, 3, 2, 1])
      end

      it "returns exact matching numbers" do
        expect(game.not_exact_matching_numbers).to include(1, 2, 3, 4)
      end

      it "returns Array of exact matching numbers" do
        expect(game.not_exact_matching_numbers).to be_a(Array)
      end
    end

    context "#match" do
      let(:game) { Game.new }

      before do
        game.start
        game.instance_variable_set(:@secret_code, [1, 2, 3, 3])
        game.instance_variable_set(:@user_code, [4, 3, 2, 1])
      end

      it "returns ['-', '-', '-']" do
        expect(game.match).to eq(['-', '-', '-'])
      end

      it "returns Array" do
        expect(game.match).to be_a(Array)
      end
    end
  end
end
