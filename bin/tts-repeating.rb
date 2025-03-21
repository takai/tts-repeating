require 'dotenv/load'
require 'fileutils'
require 'openai'
require 'optparse'
require 'pragmatic_segmenter'
require 'progressbar'

VOICES = %w[alloy echo fable onyx nova shimmer].freeze
MODELS = %w[tts-1 tts-1-hd gpt-4o-mini-tts].freeze

params = {
  file: $stdin,
  model: MODELS.first,
  no_segmentation: false,
  output: Dir.pwd,
  prefix: Time.now.strftime('%Y%m%d%H%M'),
  progress: false,
  voice: VOICES.first,
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

  parser.on('-o OUTPUT', '--output OUTPUT') do |output|
    FileUtils.mkdir_p(output) unless File.exist?(output)

    unless File.directory?(output) && File.writable?(output)
      warn 'Invalid output. Please provide a valid output path.'
      puts parser.help
      exit
    end
    params[:output] = output
  end

  parser.on('-p PREFIX', '--prefix PREFIX') do |prefix|
    params[:prefix] = prefix
  end

  parser.on('--progress') do
    params[:progress] = true
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

  parser.on('-m MODEL', '--model MODEL') do |model|
    params[:model] = model || MODELS.first
    params[:model] = params[:model].downcase.strip

    unless MODELS.include?(params[:model])
      warn "Invalid model. Please use one of the following: #{MODELS.join(', ')}"
      puts parser.help
      exit
    end
  end

  parser.on('--no-segmentation') do
    params[:no_segmentation] = true
  end

  parser.on('-h', '--help') do
    puts parser.help
    exit
  end
end.parse!

text = params[:file].read
if params[:no_segmentation]
  sentences = [text]
else
  ps = PragmaticSegmenter::Segmenter.new(text: text)
  sentences = ps.segment
end
digits = sentences.size.to_s.length

OpenAI.configure do |config|
  config.access_token = ENV.fetch('OPENAI_API_KEY')
  config.log_errors = ENV.fetch('OPENAI_LOG_ERRORS', false) # Optional
end

client = OpenAI::Client.new

bar = ProgressBar.create(total: sentences.size) if params[:progress]
sentences.each.with_index(1) do |sentence, index|
  response = client.audio.speech(
    parameters: {
      model: params[:model],
      input: sentence,
      voice: params[:voice]
    }
  )

  file = File.join(params[:output], "#{params[:prefix]}-#{index.to_s.rjust(digits, '0')}.mp3")
  File.binwrite(file, response)

  bar.progress += 1 if params[:progress]
end
