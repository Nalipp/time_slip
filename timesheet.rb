require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'

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

get '/' do
  redirect '/slips'
end

get '/slips' do
  @time_slips = session[:lists]
  erb :slips
end

get '/slip/new' do
  erb :new_slip
end

post '/slips' do
  slip_name = params[:slip_name]
  teacher_name = params[:teacher_name]
  if exceeds_length_validation?(slip_name, teacher_name)
    session[:error] = "Please use a shorter name."
    erb :new_slip
  else
    id = find_last_id(session[:slips]) + 1
    session[:slips] << { id: id, teacher_name: teacher_name, title: slip_name, time_blocks: [] }
    redirect "/slips/#{id}"
  end
end
