require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'


enable :sessions

get('/') do
  slim(:login)
end

post('/login') do
  mail = params[:mail]
  password = params[:password]
  db = SQLite3::Database.new("db/Trademarket.db")
  db.results_as_hash = true
  result = db.execute("SELECT * FROM users WHERE name = ?",name).first
  password = result["password"]
  id = result["id"]

  if BCrypt::Password.new(password) == password
    session[:id] = id
    redirect('/annonser')
  else
    "Fel lösenord!"
  end
end

get('/register') do
  slim(:register)
end

post('/user/new') do
  name = params[:name]
  password = params[:password]
  password_confirm = params[:password_confirm]

  if (password == password_confirm)
   
    password_digest = BCrypt::Password.create(password)
    db = SQLite3::Database.new("db/Trademarket.db")
    db.execute("INSERT INTO users (name,mail,password) VALUES (?,?,?)",name,mail,password_digest)
    redirect('/annonser')
  else
    
    "Lösenorden matchade inte!"
  end
end

get('/annonser') do
  id = session[:id].to_i
  db = SQLite3::Database.new("db/Trademarket.db")
  db.results_as_hash = true
  result = db.execute("SELECT * FROM annonser WHERE user_id = ?",user_id)
  slim(:"annonser/index",locals:{annonser:result})
end

post('/annonser/new') do
  item = params[:item]
  user_id = params[:user_id]
  db = SQLite3::Database.new("db/Trademarket.db")
  db.execute("INSERT INTO annonser (item,user_id) VALUES (?,?)",item,user_id)
  redirect('/annonser')
end

post('/annonser/:id/delete') do
  id = params[:id].to_i
  db = SQLite3::Database.new("db/Trademarket.db")
  db.execute("DELETE FROM annonser WHERE annons_id = ?",annons_id)
  redirect('/todos')
end

post('/annonser/:id/update') do
  annons_id = params[:annons_id].to_i
  item = params[:item]

  db = SQLite3::Database.new("db/Trademarket.db")
  db.execute("UPDATE annonser SET item = ? where annons_id = ?",item,annons_id)
  redirect('/annonser')
end

get('/annonser/:id/edit') do
  annons_id = params[:annons_id].to_i
  db = SQLite3::Database.new("db/Trademarket.db")
  db.results_as_hash = true
  result = db.execute("SELECT * FROM annonser WHERE id = ?",annons_id).first
  p "result är #{result}"
  slim(:"/annonser/edit", locals:{result:result})
end

