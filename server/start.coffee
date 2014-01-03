express = require 'express'

fs = require 'fs'
path = require 'path'
gs = require 'glob-stream'

PUBLIC_PATH = path.normalize "#{__dirname}/../public"
FRONTEND_PATH = path.normalize "#{__dirname}/../frontend"

module.exports = (port=1337) ->
  app = express()

  app.use express.logger('dev')
  app.use express.json()

  app.use express.static PUBLIC_PATH

  app.get '/pages', (req, res) ->
    dataPath = "#{FRONTEND_PATH}/data"
    pages = []

    pagesStream = gs.create("**/*.json", cwd: dataPath)
    .on 'data', (file) ->
      pages.push file.path.replace file.cwd, ""
    .on 'end', ->
      res.send 200, {pages: pages}

  app.use '/pages', express.static "#{FRONTEND_PATH}/data"

  app.post '/pages/:page', (req, res) ->
    page = req.param 'page'
    try
      throw new Error() unless req.body?
      throw new Error("Title missing") unless req.body.title?
      throw new Error("Content missing") unless req.body.content?
      body = JSON.stringify(req.body, null, 2)
    catch e
      res.send 400, {status: 400, msg: e.message or "Submit JSON you freak!"}

    fs.writeFile "#{FRONTEND_PATH}/data/#{page}", body, (err) ->
      if err
        return res.send 500, {status: 500, msg: "Error writing file."}

      res.send 200, {status: 200, msg: "thx"}

  # app.use (err, req, res, next) ->
  #   throw err
  #   if req.accepts 'json' then res.send 500, {msg: 'oh noes'}
  #   else res.send 500, "500"

  # app.on 'error', (err) -> console.error err


  app.listen(port, '127.0.0.1')
  console.log "Started app on http://localhost:#{port}/"
