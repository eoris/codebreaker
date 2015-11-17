module Codebreaker
  class Warning < StandardError
  end

  class AttemptsError < Warning
  end

  class SecretCodeError < Warning
  end

  class HintCountError < Warning
  end
end
