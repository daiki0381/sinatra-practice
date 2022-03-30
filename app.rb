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

  def read_memos
    memos = Dir.glob('*.json', base: 'data').map do |file_name|
      read_memo(file_name.delete('.json'))
    end
    memos.sort_by { |memo| memo[:time] }.reverse
  end

  def read_memo(id)
    JSON.parse(File.open("data/#{id}.json").read, symbolize_names: true)
  end

  def save_memo(id, memo)
    File.open("data/#{id}.json", 'w') do |file|
      JSON.dump(memo, file)
    end
  end

  def delete_memo(id)
    File.delete("data/#{id}.json")
  end
end

get '/memos' do
  @memos = read_memos
  erb :top
end

get '/new' do
  erb :new
end

post '/memos' do
  memo = { id: SecureRandom.uuid, time: Time.now, title: params[:title], content: params[:content] }
  save_memo(memo[:id], memo)
  redirect to('/memos')
end

get '/memos/:id' do |id|
  @memo = read_memo(id)
  erb :details
end

delete '/memos/:id' do |id|
  delete_memo(id)
  redirect to('/memos')
end

get '/memos/:id/edit' do |id|
  @memo = read_memo(id)
  erb :edit
end

patch '/memos/:id' do |id|
  memo = read_memo(id)
  memo[:title] = params[:title]
  memo[:content] = params[:content]
  save_memo(id, memo)
  redirect to("memos/#{id}")
end
