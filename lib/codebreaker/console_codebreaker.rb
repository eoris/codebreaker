require_relative 'game'

module Codebreaker
  class Interface
    def exe
      loop do
        start_game
        game_flow
        restart_game == 'y' ? next : break
      end
      # answer_if_lose
      user_name_input
    end

    def start_game
      @game = Game.new
      @game.start
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

    def game_info
        p "attempts left: #{@game.attempts}"
        p "score: #{@game.score}"
        p "hint count: #{@game.hint_count}"
    end

    def guess_input
      #   p @game.instance_variable_get(:@secret_code)
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

    def game_flow
      loop do
        if @game.win?
          p 'You win!'
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
    
    def answer_if_lose
      p "Secret code was: #{@game.instance_variable_get(:@secret_code).join}" if @game.lose?
    end
  end
end
