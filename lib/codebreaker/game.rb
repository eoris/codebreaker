module Codebreaker
  class Game
    attr_accessor :user_name

    def initialize
      @secret_code = ''
    end

    def start
      @secret_code = secret_code
    end

    def secret_code
      4.times.map { rand(1..6) }
    end

    def user_code(code)
      @user_code = code.to_s.chars.map(&:to_i)
      self.check_user_code
    end
    
    def check_user_code
      if @user_code.join.match(/[^1-6]+/)
          raise ArgumentError, "It must be a numeric code, or be 1..6"
      elsif @user_code.count != 4
          raise ArgumentError, "Code length must be 4"
      else
          @user_code
      end
    end

    def compare   
    end
  end
end