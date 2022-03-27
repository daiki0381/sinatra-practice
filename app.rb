# frozen_string_literal: true

# !/usr/bin/env ruby
require 'sinatra'
require 'sinatra/reloader'
require 'erb'
require 'json'

helpers do
  include ERB::Util

  def sanitize(text)
    escape_html(text)
  end

  def parse_json
    Dir.glob('*.json', base: 'data').map do |file_name|
      File.open("data/#{file_name}") do |file|
        JSON.parse(file.read, symbolize_names: true)
      end
    end
  end

  def return_specific_file(id)
    JSON.parse(File.open("data/#{id}.json").read, symbolize_names: true)
  end

  def sort_files(files)
    files.sort_by { |file| file[:time] }.reverse
  end
end

get '/memos' do
  @memos = sort_files(parse_json)
  erb :top
end

get '/new' do
  erb :new
end

post '/memos' do
  hash = { id: SecureRandom.uuid, time: Time.now, title: params[:title], content: params[:content] }
  File.open("data/#{hash[:id]}.json", 'w') do |file|
    JSON.dump(hash, file)
  end
  redirect to('/memos')
end

get '/memos/:id' do |id|
  if File.exist?("data/#{id}.json")
    @memo = return_specific_file(id)
    erb :details
  else
    erb :not_found
  end
end

delete '/memos/:id' do |id|
  if File.exist?("data/#{id}.json")
    File.delete("data/#{id}.json")
    redirect to('/memos')
  else
    erb :not_found
  end
end

get '/memos/:id/edit' do |id|
  if File.exist?("data/#{id}.json")
    @memo = return_specific_file(id)
    erb :edit
  else
    erb :not_found
  end
end

patch '/memos/:id' do |id|
  if File.exist?("data/#{id}.json")
    time = return_specific_file(id)[:time]
    hash = { id: id, time: time, title: params[:title], content: params[:content] }
    File.open("data/#{id}.json", 'w') do |file|
      JSON.dump(hash, file)
    end
    redirect to("memos/#{id}")
  else
    erb :not_found
  end
end

not_found do
  erb :not_found
end
