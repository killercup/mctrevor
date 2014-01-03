###
# # MC Trevor Server
#
# Currently implements the following features:
#
# - Serve static assets
# - List JSON files
# - Send JSON files
# - Create/Overwrite JSON file
###

express = require 'express'

fs = require 'fs-extra'
path = require 'path'
gs = require 'glob-stream'

# ## Paths
PUBLIC_PATH = path.normalize "#{__dirname}/../public"
FRONTEND_PATH = path.normalize "#{__dirname}/../frontend"

module.exports = (port=1337) ->
  app = express()

  app.use express.logger('dev')
  app.use express.json()

  # Serve assets
  app.use express.static PUBLIC_PATH

  # ## Index of JSON files
  app.get '/pages', (req, res) ->
    dataPath = "#{FRONTEND_PATH}/data"
    pages = []

    pagesStream = gs.create("**/*.json", cwd: dataPath)
    .on 'data', (file) ->
      pages.push file.path.replace file.cwd, ""
    .on 'end', ->
      res.send 200, {pages: pages}

  # ## GET JSON files
  app.use '/pages', express.static "#{FRONTEND_PATH}/data"

  # ## Write JSON files
  app.post /^\/pages\/(.*)$/, (req, res) ->
    page = req.params[0]
    try
      throw new Error() unless req.body?
      throw new Error("Title missing") unless req.body.title?
      throw new Error("Content missing") unless req.body.content?
      body = JSON.stringify(req.body, null, 2)
    catch e
      res.send 406, {status: 406, msg: e.message or "Submit JSON you freak!"}

    fs.outputFile "#{FRONTEND_PATH}/data/#{page}", body, (err) ->
      if err
        console.error page
        return res.send 500, {status: 500, msg: "Error writing file."}

      res.send 204


  app.listen(port, '127.0.0.1')
  console.log "Started app on http://localhost:#{port}/"
