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

    if db.execute("SELECT username FROM users") == username
        redirect("/errors/usernameloginerror")
    end

    redirect("/")
end

post("/login") do
    username = params["username"]
    password = params["password"]

    user_id =[]

    db = SQLite3::Database.new("db/slutprojekt.db")
    result = db.execute("SELECT userid, password FROM users WHERE username=?", [username])

    password_digest = result[0][1]
    if BCrypt::Password.new(password_digest) == password
        session[:user_id] = user_id
        redirect("/")
    else
        redirect("/errors/passworderror")
    end
end

get("/errors/passworderror") do
    slim(:"/passworderror")
end

get("/erros/usernameerror") do
    slim(:"/usernameerror")
end

get("/errors/usernameloginerror") do
    slim(:"/usernameloginerror")
end

get("/users/home") do
    slim(:"users/home")
end

get("/myhighscore/leaderboard") do
    db = SQLite3::Database.new("db/slutprojekt.db")
    db.results_as_hash = true
    all = db.execute("SELECT users.username, highscore.game, highscore.score FROM users INNER JOIN highscore ON users.userid=highscore.userid")
    slim(:users,:highscore,locals:{users:all, highscore:all})
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

post("/userhighscore/:userid/delete") do
    h1 "Hello new world"
    userid = params[:userid]
    db = SQLite3::Database.new("db/slutprojekt.db")
    db.execute("DELETE FROM highscore WHERE game = '?'", userid)
    redirect("/myhighscore/userhighscore")
end

post("/myhighscore/:userid/edit") do
    userid = params[:userid]
    text = params["content"]
    db = SQLite3::Database.new("db/slutprojekt.db")
    db.execute("UPDATE highscore SET game = ? WHERE game = ?", text, userid)
    redirect("/myhighscore/userhighscore")
end

