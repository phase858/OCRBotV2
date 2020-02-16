class Commands
  def test1(input)
    return "input was #{input}"
  end

  def test2
    return "nope"
  end

  def initialize(prefix = "!")
    @prefix = prefix
    @commands = {
      "test1" => [true, method(:test1)],
      "test2" => [false, method(:test2)],
    }
  end

  def strip_prefix(message)
    return message[@prefix.length..message.length]
  end

  def parts(message)
    return message.split(" ", 2)
  end

  #test
  def parse(author, message)
    puts @commands.class
    parts = parts(strip_prefix(message))
    command = parts[0].chomp
    args = parts[1]
    puts command
    if @commands.has_key? command
      unless @commands[command][0]
        return @commands[command][1].()
      else
        if args && !args.chomp.empty?
          return @commands[command][1].(args)
        else
          return "Command \"#{command}\" requires arguments."
        end
      end
    else
      return "Command \"#{command}\" not found."
    end
  end
end
