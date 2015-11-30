require 'spec_helper'

module Codebreaker
  describe Game do
    let(:game) { Game.new }
    before(:each) { game.start }

    describe "#initialize" do

      it "initialize default user name" do
        expect(game.user_name).to eq('Player1')
      end
    end

    describe "#start" do

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

      it 'resets attempts' do
        expect(game.instance_variable_get(:@attempts)).to eq(ATTEMPTS)
      end

      it 'resets score' do
        expect(game.instance_variable_get(:@score)).to eq(SCORE_MULTIPLIER * ATTEMPTS)
      end

      it 'returns Game object' do
        expect(game.start).to equal(game)
      end
    end

    describe "#guess" do

      it "calls #attempts_left?" do
        expect(game).to receive(:attempts_left?).and_return(true)
        game.guess(1234)
      end

      it "sets value to @user_code" do
        expect{game.guess(3333)}.to change{game.user_code}.to([3, 3, 3, 3])
      end

      it "calls #validation" do
        expect(game).to receive(:validation)
        game.guess(1111)
      end

      it "returns the Array" do
        expect(game.guess(1234)).to be_a(Array)
      end

      it "returns '++++' if guess the secret code" do
        game.instance_variable_set(:@secret_code, [1, 2, 3, 4])
        expect(game.guess(1234)).to eq(['+', '+', '+', '+'])
      end

      it "returns '+++' if guess the secret code" do
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

      it "change score by -#{SCORE_MULTIPLIER}" do
        expect{game.guess(1234)}.to change{game.score}.by(-SCORE_MULTIPLIER)
      end

      it "did not change score by -#{SCORE_MULTIPLIER} if game.win?" do
        game.instance_variable_set(:@secret_code, [1, 1, 1, 1])
        expect{game.guess(1111)}.to_not change{game.score}
      end

      it "receives match method" do
        expect(game).to receive(:match)
        game.guess(4444)
      end

      it "raises RuntimeError, \"0 from #{ATTEMPTS} attempts left\"" do
        game.instance_variable_set(:@attempts, 0)
        expect {game.guess(1234)}.to raise_error(RuntimeError, "0 from #{ATTEMPTS} attempts left")
      end
    end

    describe "#attempts_left?" do

      it "returns true if the user has attempts" do
        game.instance_variable_set(:@attempts, 1)
        expect(game.attempts_left?).to be true
      end

      it "returns false if the user has no attempts" do
        game.instance_variable_set(:@attempts, 0)
        expect(game.attempts_left?).to be false
      end
    end

    describe "#win?" do

      before do
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

    describe "#lose?" do

      it "returns true if user loses game" do
        game.instance_variable_set(:@attempts, 0)
        expect(game.lose?).to be true
      end

      it "returns false if the user has not yet lose a game" do
        game.instance_variable_set(:@attempts, 1)
        expect(game.lose?).to be false
      end
    end

    describe "#have_hint?" do

      it "returns true if the user has hint" do
        game.instance_variable_set(:@hint_count, 1)
        expect(game.have_hint?).to be true
      end

      it "returns false if the user has no hint" do
        game.instance_variable_set(:@hint_count, 0)
        expect(game.have_hint?).to be false
      end
    end

    describe "#validation" do

      it "raises ArgumentError, 'User name is empty'" do
        game.instance_variable_set(:@user_name, '')
        game.instance_variable_set(:@user_code, [1, 1, 1, 1])
        expect { game.validation }.to raise_error(ArgumentError, 'User name is empty')
      end

      it "raises ArgumentError, 'Secret code is empty'" do
        game.instance_variable_set(:@secret_code, [])
        game.instance_variable_set(:@user_code, [1, 1, 1, 1])
        expect { game.validation }.to raise_error(ArgumentError, 'Secret code is empty')
      end

      it "raises ArgumentError, 'It must be a numeric code, or be 1..6'" do
        game.instance_variable_set(:@user_code, [7, 7, 7, 1])
        expect { game.validation }.to raise_error(ArgumentError, 'It must be a numeric code, or be 1..6')
      end

      it "raise ArgumentError, \"Code length must be #{CODE_SIZE}\"" do
        game.instance_variable_set(:@user_code, [1, 2, 3, 4, 5, 6])
        expect { game.validation }.to raise_error(ArgumentError, "Code length must be #{CODE_SIZE}")
      end
    end
    describe "#match" do

      before do
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

    describe "#hint" do

      it "returns hint" do
        game.instance_variable_set(:@secret_code, [1, 2, 3 ,4])
        expect(game.hint).to include(1).or include(2).or include(3).or include(4)
      end

      it "change hint count by -1" do
        expect{game.hint}.to change{game.hint_count}.by(-1)
      end

      it "change attempts count by -1" do
        expect{game.hint}.to change{game.attempts}.by(-1)
      end

      it "change score by -#{SCORE_MULTIPLIER}" do
        expect{game.hint}.to change{game.score}.by(-SCORE_MULTIPLIER)
      end

      it "raise RuntimeError, \"Hint may be used only #{HINT_COUNT} times\"" do
        game.instance_variable_set(:@hint_count, 0)
        expect {game.hint}.to raise_error(RuntimeError, "Hint may be used only #{HINT_COUNT} times")
      end
    end

    context 'private' do
      describe "#matching_numbers" do

        before do
          game.instance_variable_set(:@secret_code, [1, 3, 2, 4])
          game.instance_variable_set(:@user_code, [6, 2, 6, 4])
        end

        it "returns matching numbers" do
          expect(game.send(:matching_numbers)).to include(2, 4)
        end

        it "returns Array of matching numbers" do
          expect(game.send(:matching_numbers)).to be_a(Array)
        end
      end

      describe "#exact_matching_numbers" do

        before do
          game.instance_variable_set(:@secret_code, [1, 3, 2, 4])
          game.instance_variable_set(:@user_code, [3, 3, 3, 4])
        end

        it "returns exact matching numbers" do
          expect(game.send(:exact_matching_numbers)).to include(3, 4)
        end

        it "returns Array of exact matching numbers" do
          expect(game.send(:exact_matching_numbers)).to be_a(Array)
        end
      end

      describe "#not_exact_matching_numbers" do

        before do
          game.instance_variable_set(:@secret_code, [1, 2, 3, 4])
          game.instance_variable_set(:@user_code, [4, 3, 2, 1])
        end

        it "returns exact matching numbers" do
          expect(game.send(:not_exact_matching_numbers)).to include(1, 2, 3, 4)
        end

        it "returns Array of exact matching numbers" do
          expect(game.send(:not_exact_matching_numbers)).to be_a(Array)
        end
      end
    end
  end
end
