# credentials.R

require(dotenv)
load_dot_env(file = ".env")

API_KEY <- Sys.getenv("API_KEY")
API_SECRET <- Sys.getenv("API_SECRET")
ACCESS_TOKEN <- Sys.getenv("ACCESS_TOKEN")
ACCESS_TOKEN_SECRET <- Sys.getenv("ACCESS_TOKEN_SECRET")
