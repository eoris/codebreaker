module Codebreaker
  class Game
    def initialize
      @secret_code = ''
    end

    def start
      @secret_code = secret_code
    end

    def secret_code
      (1..6).to_a.sample(4)
    end
  end
end