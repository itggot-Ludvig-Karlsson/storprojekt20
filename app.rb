require "sinatra"
require "slim"
require "sqlite3"
require "bcrypt"

enable :sessions

get("/") do 
    if session[:user_id].nil?
        session[:user_id] = [0, "user"]
    end  
    slim(:start)
end

get("/users/new") do
    slim(:"users/new")
end

post("/create") do
    username = params["username"]
    password = params["password"]

    db = SQLite3::Database.new("db/slutprojekt.db")
    password_digest = BCrypt::Password.create(password)
    db.execute("SELECT username FROM users")

    db.execute("INSERT INTO users(username, password) VALUES (?,?)", [username, password_digest])

    redirect("/")
end

post("/login") do
    username = params["username"]
    password = params["password"]

    user_id =[]

    db = SQLite3::Database.new("db/slutprojekt.db")
    result = db.execute("SELECT userid, password FROM users WHERE username=?", [username])

    if username != 

    user_id << result[0][0] 
    user_id << username
    password_digest = result[0][1]
    if BCrypt::Password.new(password_digest) == password
        session[:user_id] = user_id
        redirect("/")
    else
        redirect("/passworderror")
    end
end

get("/passworderror") do
    slim(:"/passworderror")
end

get("/usernameerror") do
    slim(:"/usernameerror")
end

get("/users/home") do
    slim(:"users/home")
end

get("/myhighscore/userhighscore") do
    inloggad = session[:user_id][0]
    db = SQLite3::Database.new("db/slutprojekt.db")
    db.results_as_hash = true
    result = db.execute("SELECT * FROM highscore WHERE userid=?", [inloggad])
    slim(:"myhighscore/userhighscore", locals:{myhighscore:result})
end

post("/myhighscore/new") do
    game = params["game"]
    score = params["score"]
    db = SQLite3::Database.new("db/slutprojekt.db")
    db.execute("INSERT INTO highscore (userid, game, score) VALUES (?,?,?)",session[:user_id][0], game, score)
    redirect("/myhighscore/userhighscore")
end

post("/userhighscore/:id/delete") do
    h1 "Hello new world"
    userid = params[:userid]
    db = SQLite3::Database.new("db/slutprojekt.db")
    db.execute("DELETE FROM highscore WHERE game = ?", userid) # item funkar inte gör något bra istället
    redirect("/myhighscore/userhighscore")
end

post("/myhighscore/:id/edit") do
    userid = params[:userid]
    text = params["content"]
    db = SQLite3::Database.new("db/slutprojekt.db")
    db.execute("UPDATE highscore SET game = ? WHERE game = ?", text, userid) # item funkar inte gör något bra istället
    redirect("/myhighscore/userhighscore")
end