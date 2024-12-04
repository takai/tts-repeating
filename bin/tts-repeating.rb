require 'dotenv/load'
require 'openai'
require 'optparse'
require 'pragmatic_segmenter'

VOICES = %w[alloy echo fable onyx nova shimmer].freeze

params = {
  file: $stdin,
  prefix: Time.now.strftime('%Y%m%d%H%M'),
  voice: VOICES.first
}

OptionParser.new do |parser|
  parser.banner = 'Usage: tts-repeating.rb [options]'

  parser.on('-f FILE', '--file FILE') do |file|
    unless File.readable?(file) && File.file?(file)
      warn 'Invalid file. Please provide a valid file path.'
      puts parser.help
      exit
    end
    params[:file] = File.open(file)
  end

  parser.on('-p PREFIX', '--prefix PREFIX') do |prefix|
    params[:prefix] = prefix
  end

  parser.on('-v VOICE', '--voice VOICE') do |voice|
    params[:voice] = voice || VOICES.first
    params[:voice] = params[:voice].downcase.strip

    unless VOICES.include?(params[:voice])
      warn "Invalid voice. Please use one of the following: #{VOICES.join(', ')}"
      puts parser.help
      exit
    end
  end
  parser.on('-h', '--help') do
    puts parser.help
    exit
  end
end.parse!

text = params[:file].read
ps = PragmaticSegmenter::Segmenter.new(text: text)
sentences = ps.segment
digits = sentences.size.to_s.length

OpenAI.configure do |config|
  config.access_token = ENV.fetch('OPENAI_API_KEY')
  config.log_errors = ENV.fetch('OPENAI_LOG_ERRORS', false) # Optional
end

client = OpenAI::Client.new

sentences.each.with_index(1) do |sentence, index|
  response = client.audio.speech(
    parameters: {
      model: 'tts-1',
      input: sentence,
      voice: params[:voice]
    }
  )
  file = "#{params[:prefix]}-#{index.to_s.rjust(digits, '0')}.mp3"
  File.binwrite(file, response)
end
