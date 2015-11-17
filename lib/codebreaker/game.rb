require_relative 'errors'

module Codebreaker
  ATTEMPTS   = 10
  CODE_SIZE  = 4
  HINT_COUNT = 1
  SCORE      = 100

  class Game
    attr_reader :score, :attempts, :hint_number, :hint_count, :user_code
    attr_accessor :user_name

    def initialize(user_name = 'Player1')
      @secret_code = ''
      @user_name   = user_name
      @hint_count  = HINT_COUNT
      @attempts    = ATTEMPTS
      @score       = SCORE
    end

    def start
      @secret_code = secret_code
      @user_code   = ''
      @hint_number = ''
      @hint_count  = HINT_COUNT
      @attempts    = ATTEMPTS
      @score       = SCORE
      self
    end
    alias_method :restart, :start

    def win?
      match == ['+'] * CODE_SIZE
    end

    def lose?
      @attempts == 0
    end

    def attempts_left?
      @attempts > 0
    end
    alias_method :attempts?, :attempts_left?

    def have_hint?
      @hint_count > 0
    end
    alias_method :hint?, :have_hint?

    def guess(code)
      if attempts_left?
        @attempts -= 1
        @score -= 10
        @user_code = code.to_s.chars.map(&:to_i)
        check_secret_code
        check_user_code
        match
      else
        raise AttemptsError, "0 from #{ATTEMPTS} attempts left"
      end
    end

    def check_secret_code
      raise SecretCodeError, 'Secret code is empty' if @secret_code.empty?
    end

    def check_user_code
      if @user_code.join.match(/[^1-6]+/)
        raise ArgumentError, 'It must be a numeric code, or be 1..6'
      elsif @user_code.count != CODE_SIZE
        raise ArgumentError, "Code length must be #{CODE_SIZE}"
      else
        @user_code
      end
    end

    def matching_numbers
      @user_code.select { |i| @secret_code.include?(i) }
    end

    def exact_matching_numbers
      @secret_code.zip(@user_code).select { |s, u| s == u }.map(&:uniq).flatten
    end

    def not_exact_matching_numbers
      matched = matching_numbers
      if exact_matching_numbers.empty?
        matched
      else
        delete_list = exact_matching_numbers
        delete_list.each { |del| matched.delete_at(matched.index(del)) }
      end
      matched
    end

    def match
      result = []
      result << exact_matching_numbers.fill('+')
      result << not_exact_matching_numbers.fill('-')
      result.flatten
    end

    def hint
      if have_hint?
        @hint_count -= 1
        random_index = rand(0..CODE_SIZE - 1)
        @hint_number = @secret_code[random_index]
        hint_arr = Array.new(CODE_SIZE, '*')
        hint_arr[random_index] = @hint_number
        @hint_number = hint_arr
      else
        raise HintCountError, "Hint may be used only #{HINT_COUNT} times"
      end
    end

    private

    def secret_code
      CODE_SIZE.times.map { rand(1..6) }
    end
  end
end
