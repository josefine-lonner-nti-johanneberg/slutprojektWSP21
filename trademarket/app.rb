require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'


enable :sessions

get('/') do
  slim(:"users/login")
end

post('/login') do
  mail = params[:mail]
  password = params[:password]
  db = SQLite3::Database.new("db/Trademarket.db")
  db.results_as_hash = true
  result = db.execute("SELECT * FROM users WHERE name = ?",name).first
  password = result["password"]
  user_id = result["user_id"]

  if BCrypt::Password.new(password) == password
    session[:user_id] = user_id
    redirect('/ads')
  else
    "Fel lösenord!"
  end
end

get('/register') do
  slim(:"users/register")
end

post('/user/new') do
  name = params[:name]
  mail = params[:mail]
  password = params[:password]
  password_confirm = params[:password_confirm]

  if (password == password_confirm)
   
    password_digest = BCrypt::Password.create(password)
    db = SQLite3::Database.new("db/Trademarket.db")
    db.execute("INSERT INTO users (name,mail,password) VALUES (?,?,?)",name,mail,password_digest)
    redirect('/ads')
  else
    
    "Lösenorden matchade inte!"
  end
end

get('/ads') do
  ad_id = session[:ad_id].to_i
  db = SQLite3::Database.new("db/Trademarket.db")
  db.results_as_hash = true
  result = db.execute("SELECT * FROM ads WHERE ad_id = ?",ad_id)
  slim(:"ads/index",locals:{ads:result})
end

post('/ads/new') do
  item = params[:item]
  user_id = params[:user_id]
  db = SQLite3::Database.new("db/Trademarket.db")
  db.execute("INSERT INTO annonser (item,user_id) VALUES (?,?)",item,user_id)
  redirect('/ads')
end

post('/ads/:id/delete') do
  ad_id = params[:ad_id].to_i
  db = SQLite3::Database.new("db/Trademarket.db")
  db.execute("DELETE FROM ads WHERE ad_id = ?",ad_id)
  redirect('/ads')
end

post('/ads/:id/update') do
  ad_id = params[:ad_id].to_i
  item = params[:item]

  db = SQLite3::Database.new("db/Trademarket.db")
  db.execute("UPDATE ads SET item = ? where ad_id = ?",item,ad_id)
  redirect('/ads')
end

get('/ads/:id/edit') do
  ad_id = params[:ad_id].to_i
  db = SQLite3::Database.new("db/Trademarket.db")
  db.results_as_hash = true
  result = db.execute("SELECT * FROM ads WHERE id = ?",ad_id).first
  p "result är #{result}"
  slim(:"/ads/edit", locals:{result:result})
end

