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

      it "saves #{CODE_SIZE} numbers secret code" do
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

      @guessing_tests = 
        ['1234', '1234', '++++'],
        ['1233', '1234', '+++'],
        ['2232', '2244', '++'],
        ['2234', '4444', '+'],
        ['4321', '1234', '----'],
        ['2132', '1224', '---'],
        ['1212', '2145', '--'],
        ['3331', '1222', '-'],
        ['5565', '5556', '++--'],
        ['4545', '4556', '++-'],
        ['3465', '3654', '+---'],
        ['2526', '2251', '+--'],
        ['3344', '3456', '+-'],
        ['6666', '5555', '']

      @guessing_tests.each do |gues|
        it "returns '#{gues[2]}' when secret code: #{gues[0]}; user code: #{gues[1]}" do
          game.instance_variable_set(:@secret_code, gues[0].split('').map(&:to_i))
          expect(game.guess(gues[1])).to eq(gues[2].split(''))
        end
      end

      it "raises ArgumentError 'It must be a numeric code, or be 1..6' when user input '7890'" do
        expect {game.guess(7890)}.to raise_error(ArgumentError, "It must be a numeric code, or be 1..6")
      end

      it "raises ArgumentError 'It must be a numeric code, or be 1..6 when user input 'abcd''" do
        expect {game.guess('abcd')}.to raise_error(ArgumentError, "It must be a numeric code, or be 1..6")
      end

      it "raises ArgumentError \"Code length must be #{CODE_SIZE}\" when user input more than #{CODE_SIZE} digits" do
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

      it "receives #answer method" do
        expect(game).to receive(:answer)
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

      it "raises ArgumentError, \"Code length must be #{CODE_SIZE}\"" do
        game.instance_variable_set(:@user_code, [1, 2, 3, 4, 5, 6])
        expect { game.validation }.to raise_error(ArgumentError, "Code length must be #{CODE_SIZE}")
      end
    end
    describe "#answer" do

      before do
        game.instance_variable_set(:@secret_code, [1, 2, 3, 3])
        game.instance_variable_set(:@user_code, [4, 3, 2, 1])
      end

      it "returns ['-', '-', '-'] when secret code: '1233'; user code: 4321" do
        expect(game.answer).to eq(['-', '-', '-'])
      end

      it "returns Array" do
        expect(game.answer).to be_a(Array)
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

    describe "#save_game" do
      after do
        File.delete("./saves/save1") if File.exist?("./saves/save1")
      end

      it "create score" do
        game.save_game({score: game.score}, 'save1')
        expect( File.exist? "./saves/save1" )
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
