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
      @started_at = Time.now
    end

    def guessing
      loop do
        if @game.win?
          puts 'You win!'
          save_score
          break
        elsif @game.lose?
          puts 'You lose!'
          answer_if_lose
          break
        else
          guess_input
        end
      end
    end

    def restart_game
      puts 'Do you want to try again? y/n'
      input = gets.chomp
    end

    def user_name_input
      puts 'Enter youre name:'
      @game.user_name = gets.chomp
      @game.validation
      rescue ArgumentError => e
      if @game.user_name.empty?
        (puts 'Name must contain at least one character') && user_name_input
      end
    end

    def save_score
      puts 'Do you want to save score? y/n'
      input = gets.chomp
      score_hash = { "player - #{@game.user_name}" => 
                      { 'score'         => @game.score,
                        'attempts left' => "#{@game.attempts} of #{ATTEMPTS}",
                        'hints left'    => "#{@game.hint_count} of #{HINT_COUNT}",
                        'started at'    => @started_at,
                        'ended at'      => "#{Time.now}" } }
      @game.save_game(score_hash) if input == 'y'
    end

    private

    def game_info
      puts "attempts left: #{@game.attempts}"
      puts "score: #{@game.score}"
      puts "hint count: #{@game.hint_count}"
    end

    def guess_input
      puts "Enter four numbers from 1 to 6, or a 'hint' to help:"
      code = gets.chomp
      if code == 'hint'
        begin
        puts @game.hint.join
        game_info
        rescue RuntimeError => e
        puts "Hint may be used only #{HINT_COUNT} times"
        end
      else
        begin
        puts @game.guess(code).join
        game_info
        rescue ArgumentError => e
        puts 'Wrong input'
        end
      end
    end
    
    def answer_if_lose
      puts "Secret code was: #{@game.secret_code.join}" if @game.lose?
    end
  end
end
