require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'
require 'yaml'

configure do
  enable :sessions
  set :session_secret, 'secret'
  set :erb, :escape_html => true
end

before do
  session[:slips] ||= []
end

def exceeds_length_validation?(*form_input)
  form_input.any? { |input| input.length > 10 }
end

def find_last_id(data_type)
  data_type.empty? ? 0 : data_type.last[:id]
end

def file_path
  File.expand_path("../data/time_slips.yml", __FILE__)
end

get '/' do
  redirect '/slips'
end

get '/slips' do
  @time_slips = Psych.load_stream(open("#{file_path}"))
  erb :slips
end

get '/slip/new' do
  erb :new_slip
end

post '/slips' do
  teacher_name = params[:teacher_name]
  slip_name = params[:slip_name]

  if exceeds_length_validation?(slip_name, teacher_name)
    session[:error] = "Please use a shorter name."
    erb :new_slip
  else
    id = find_last_id(session[:slips]) + 1
    file = { id: id, teacher_name: teacher_name, title: slip_name, time_blocks: [] }
    File.open("#{file_path}", 'a') { |f| f.puts file.to_yaml }

    redirect "/slips/#{id}"
  end
end
