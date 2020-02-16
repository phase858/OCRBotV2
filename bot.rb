require "discordrb"
require "open-uri"
require "rtesseract"
require_relative "commands.rb"

@location = File.expand_path(File.dirname(__FILE__))
puts @location
@token = File.open(File.join(@location, "token.txt"), "r").read
@prefix = "!"

images_folder = File.join(@location, "images")
unless File.directory?(images_folder)
  FileUtils.mkdir_p(images_folder)
end

def logger(text, error = false)
  log = File.open(File.join(@location, "bot.log"), "a+")
  time = "[#{Time.now.strftime("%Y-%m-%d %HH:%M:%SZ%z")}] "
  type = ""
  if error
    type = "error: "
  else
    type = "info: "
  end
  info = "#{time}#{type}#{text}"
  puts info
  log.puts info
  log.close
end

def do_ocr(url, name, sender)
  file = File.join(@location, "images", name)
  logger file
  logger name
  begin
    File.open(file, "wb") do |file|
      file.write URI.open(url).read
    end
    tes = RTesseract.new(file)
    text = tes.to_s
    return "#{sender} **I found the following text:** ```\n#{text}```"
    File.delete file
    logger text
  rescue => error
    logger(error, error = true)
    return("Error processing image.")
  end
end

bot = Discordrb::Bot.new token: @token

commands = Commands.new prefix: @prefix

bot.message() do |event|
  text = event.message.content
  sender = event.user.mention
  logger "#{sender}: #{text}"
  unless event.from_bot?
    if text.downcase == "ocr this!"
      url = event.message.attachments[0].url
      name = event.message.attachments[0].filename
      event.respond(do_ocr(url, name, sender))
    elsif text[0..@prefix.length - 1] == @prefix
      event.respond(commands.parse(sender, text))
    end
  end
end

bot.run
bot.playing = "Now with more then OCR!"
