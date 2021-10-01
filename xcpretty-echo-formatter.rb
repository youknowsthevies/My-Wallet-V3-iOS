# Custom xcpretty formatter

# Allows echo commands executed as part of run script build phases to have their message printed in the final output
# In order to tell apart echo command messages, each line must start with the following prefix: §
# Lines without this prefix will be ignored in the final output

class EchoFormatter < XCPretty::Simple

  SCRIPT_ECHO_MATCHER = /^\s*§ (.*)\s/

  def pretty_format(text)
    case text
    when SCRIPT_ECHO_MATCHER
      format_script_echo($1)
    else
      super(text)
    end
  end

  def format_script_echo(message)
    format("Echo", message)
  end

end

EchoFormatter
