RSpec::Matchers.define :exit_with do |expected|
  actual = nil
  match do |block|
    begin
      block.call
    rescue SystemExit => e
      actual = e.status
    end
    actual and actual == expected
  end

  supports_block_expectations

  failure_message do |block|
    "expected exit with code #{expected} but " +
      (actual.nil? ? " exit was not called" : "we exited with #{actual} instead")
  end

  failure_message_when_negated do |block|
    "expected that exit would not be called with #{expected}"
  end

  description do
    "expect exit with #{expected}"
  end
end

RSpec::Matchers.define :have_printed do |expected|
  case expected
  when String, Regexp, Proc
    expected = expected
  else
    expected = expected.to_s
  end

  chain :and_exit_with do |code|
    @expected_exit_code = code
  end

  define_method :matches_exit_code? do |actual|
    @expected_exit_code.nil? || @expected_exit_code == actual
  end

  define_method :matches_output? do |actual|
    return false unless actual
    case expected
      when String
        actual.include?(expected)
      when Regexp
        expected.match(actual)
      when Proc
        expected.call(actual)
      else
        raise ArgumentError, "No idea how to match a #{actual.class.name}"
    end
  end

  match do |block|
    $stderr = $stdout = StringIO.new
    $stdout.set_encoding('UTF-8') if $stdout.respond_to?(:set_encoding)

    begin
      block.call
    rescue SystemExit => e
      raise unless @expected_exit_code
      @actual_exit_code = e.status
    ensure
      $stdout.rewind
      @actual = $stdout.read

      $stdout = STDOUT
      $stderr = STDERR
    end

    matches_output?(@actual) && matches_exit_code?(@actual_exit_code)
  end

  supports_block_expectations

  failure_message do |actual|
    if actual.nil? then
      "expected #{expected.inspect}, but nothing was printed"
    else
      if !@expected_exit_code.nil? && matches_output?(actual)
        "expected exit with code #{@expected_exit_code} but " +
          (@actual_exit_code.nil? ? " exit was not called" : "exited with #{@actual_exit_code} instead")
      else
        "expected #{expected.inspect} to be printed; got:\n#{actual}"
      end
    end
  end

  failure_message_when_negated do |actual|
    if @expected_exit_code && matches_exit_code?(@actual_exit_code)
      "expected exit code to not be #{@actual_exit_code}"
    else
      "expected #{expected.inspect} to not be printed; got:\n#{actual}"
    end
  end

  description do
    "expect #{expected.inspect} to be printed" + (@expected_exit_code.nil ? '' : " with exit code #{@expected_exit_code}")
  end
end
