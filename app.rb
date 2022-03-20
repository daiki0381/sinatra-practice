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
    Dir.glob('*', base: 'data').map do |file_name|
      File.open("data/#{file_name}") do |file|
        JSON.parse(file.read, symbolize_names: true)
      end
    end
  end

  def sort_files(files)
    files.sort do |a, b|
      [b[:time]] <=> [a[:time]]
    end
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
  json_file = JSON.parse(File.open("data/#{id}.json").read, symbolize_names: true)
  @title = json_file[:title]
  @content = json_file[:content]
  erb :details
end

delete '/memos/:id' do |id|
  File.delete("data/#{id}.json")
  redirect to('/memos')
end

get '/memos/:id/edit' do |id|
  json_file = JSON.parse(File.open("data/#{id}.json").read, symbolize_names: true)
  @title = json_file[:title]
  @content = json_file[:content]
  erb :edit
end

patch '/memos/:id' do |id|
  json_file = JSON.parse(File.open("data/#{id}.json").read, symbolize_names: true)
  time = json_file[:time]
  hash = { id: id, time: time, title: params[:title], content: params[:content] }
  File.open("data/#{id}.json", 'w') do |file|
    JSON.dump(hash, file)
  end
  redirect to("memos/#{id}")
end
