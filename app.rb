# frozen_string_literal: true

# !/usr/bin/env ruby
require 'sinatra'
require 'sinatra/reloader'
require 'pg'

connection = PG::Connection.new(dbname: 'sinatra')
connection.exec('CREATE TABLE IF NOT EXISTS memo (
  id serial primary key,
  title varchar(20),
  content varchar(200))')

helpers do
  include ERB::Util

  def sanitize(text)
    escape_html(text)
  end

  def read_memo(connection, id)
    connection.exec('SELECT * FROM memo WHERE id = $1', [id]).first
  end
end

get '/memos' do
  @memos = connection.exec('SELECT * FROM memo ORDER BY id DESC')
  erb :top
end

get '/new' do
  erb :new
end

post '/memos' do
  title = params[:title]
  content = params[:content]
  connection.exec('INSERT INTO memo (title, content) VALUES ($1, $2)', [title, content])
  redirect to('/memos')
end

get '/memos/:id' do |id|
  @memo = read_memo(connection, id)
  erb :details
end

delete '/memos/:id' do |id|
  connection.exec('DELETE FROM memo WHERE id = $1', [id])
  redirect to('/memos')
end

get '/memos/:id/edit' do |id|
  @memo = read_memo(connection, id)
  erb :edit
end

patch '/memos/:id' do |id|
  title = params[:title]
  content = params[:content]
  connection.exec('UPDATE memo SET title = $1, content = $2 WHERE id = $3', [title, content, id])
  redirect to("memos/#{id}")
end
