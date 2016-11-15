require 'nokogiri'
require 'json'
require 'pry'
require 'httparty'
require 'sinatra'

post '/gateway' do
  all_speakers_list = ["speakers", "all"]
  faq_init = ["faq"] 

  message = params[:text].gsub(params[:trigger_word], '').strip
  
  if (message.split(' ') & faq_init).any?
    respond_message fetch_faq_answer(message)
  elsif (message.split(' ') & all_speakers_list).any?
    respond_message get_speaker_hash
  else
    respond_message "Oops - you just asked a query that is being cooked into the bot-heart. Bad luck Brian!"
  end

  #Pry.start(binding)  
end

def respond_message message
    content_type :json
    {:text => message}.to_json
end

def fetch_faq_answer(message)
  faq_list = ["bathroom", "talks", "location"]
  if message.include? faq_list[0]
    "The bathrooms can be found only in time of urgency. "
  else
    "no match found"
  end
end

def get_speaker_hash
  page = HTTParty.get("http://tconf.io", :verify => false)
  parse_page = Nokogiri::HTML(page)

  speakers, speakers_title = [], []

  parse_page.css('.speaker').css('.name').map do |name|
    speaker_name = name.text
    speakers << speaker_name
  end

  parse_page.css('.speaker').css('.text-alt').map do |title|
    speaker_title = title.text
    speakers_title << speaker_title
  end

  # Map speakers with their title and company as a hash
  speaker_hash = Hash[speakers.zip(speakers_title)]    
end
