module Codebreaker
  ATTEMPTS         = 10
  CODE_SIZE        = 4
  HINT_COUNT       = 1
  SCORE_MULTIPLIER = 10

  class Game
    attr_reader :score, :attempts, :hint_number, :hint_count, :user_code
    attr_accessor :user_name
    
    def initialize(user_name = 'Player1')
      @secret_code = []
      @user_name   = user_name
      @hint_count  = HINT_COUNT
      @attempts    = ATTEMPTS
      @score       = SCORE_MULTIPLIER * ATTEMPTS
    end
    
    def start
      @secret_code = secret_code
      @user_code   = []
      @hint_number = []
      @hint_count  = HINT_COUNT
      @attempts    = ATTEMPTS
      @score       = SCORE_MULTIPLIER * ATTEMPTS
      self
    end
    alias_method :restart, :start
    
    def guess(code)
      if attempts_left?
        @user_code = code.to_s.chars.map(&:to_i)
        validation
        @attempts -= 1
        @score -= SCORE_MULTIPLIER unless self.win?
        match
      else
        raise RuntimeError, "0 from #{ATTEMPTS} attempts left"
      end
    end
    
    def attempts_left?
      @attempts > 0
    end
    alias_method :attempts?, :attempts_left?
    
    def win?
      @secret_code == @user_code
    end
    
    def lose?
      @attempts == 0
    end
    
    def have_hint?
      @hint_count > 0
    end
    alias_method :hint?, :have_hint?
    
    def validation
      raise ArgumentError, 'User name is empty' if user_name.empty? 
      raise ArgumentError, 'Secret code is empty' if @secret_code.empty?
      raise ArgumentError, 'It must be a numeric code, or be 1..6' if @user_code.join.match(/[^1-6]+/)
      raise ArgumentError, "Code length must be #{CODE_SIZE}" if @user_code.count != CODE_SIZE
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
        random_index = rand(CODE_SIZE)
        @hint_number = @secret_code[random_index]
        hint_arr = Array.new(CODE_SIZE, '*')
        hint_arr[random_index] = @hint_number
        @hint_number = hint_arr
      else
        raise RuntimeError, "Hint may be used only #{HINT_COUNT} times"
      end
    end
    
    private
    
    def matching_numbers
      s = @secret_code.dup
      @user_code.select { |i| s.delete_at(s.index(i)) if s.include?(i) }
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
    
    def secret_code
      CODE_SIZE.times.map { rand(1..6) }
    end
  end
end
