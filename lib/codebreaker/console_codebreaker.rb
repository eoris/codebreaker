require_relative 'game'

module Codebreaker
  class Interface
    def exe
      loop do
        start_game
      user_name_input
        guessing
        restart_game == 'y' ? next : break
      end
    end

    def start_game
      @game = Game.new
      @game.start
    end

    def guessing
      loop do
        if @game.win?
          p 'You win!'
          save_score
          break
        elsif @game.lose?
          p 'You lose!'
          answer_if_lose
          break
        else
          guess_input
        end
      end
    end

    def restart_game
      p 'Do you want to try again? y/n'
      input = gets.chomp
    end

    def user_name_input
      loop do
        begin
        p 'Enter youre name:'
        name = gets.chomp
        @game.user_name = name
        break unless name.empty?
        validation
        rescue => e
        p 'Name must contain at least one character'
        end
      end
    end

    def save_score
      p 'Do you want to save score? y/n'
      input = gets.chomp
      score_hash = {
        "player - #{@game.user_name}" => {
          'score'         => @game.score,
          'attempts left' => "#{@game.attempts} of #{ATTEMPTS}",
          'hints left'    => "#{@game.hint_count} of #{HINT_COUNT}",
          'started at'    => @game.started_at,
          'ended at'      => "#{Time.now}"
          }
        }
      input == 'y' ? @game.save_game(score_hash) : return
    end

    private

    def game_info
      p "attempts left: #{@game.attempts}"
      p "score: #{@game.score}"
      p "hint count: #{@game.hint_count}"
    end

    def guess_input
      p "Enter four numbers from 1 to 6, or a 'hint' to help:"
      code = gets.chomp
      if code == 'hint'
        begin
        p @game.hint.join
        game_info
        rescue => e
        p "Hint may be used only #{HINT_COUNT} times"
        end
      else
        begin
        p @game.guess(code).join
        game_info
        rescue => e
        p 'Wrong input'
        end
      end
    end
    
    def answer_if_lose
      p "Secret code was: #{@game.instance_variable_get(:@secret_code).join}" if @game.lose?
    end
  end
end
