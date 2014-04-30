# MC Trevor

CMS based on [Sir Trevor JS](http://madebymany.github.io/sir-trevor-js/).

The main goal is to create a CMS that stores its data in flat JSON files and renders to static HTML.

See this [screenshot] for an illustration.

[screenshot]: https://cloud.githubusercontent.com/assets/20063/2839657/0b4eedcc-d04a-11e3-9bc5-7d195da550f8.png

## Get started

The only global dependency is `npm`, the rest is managed locally.

```sh
$ npm install
$ npm run bower
```

[Gulp](http://gulpjs.com/) is used to build our application files:

```sh
$ npm run build
```

To continuously watch and rebuild the files, use:

```sh
$ npm run build
```

To start the `node` server and open the management interface in a browser:

```sh
$ npm start
$ open http://localhost:1337/
```

## Roadmap/Ideas

- Add any kind of frontend rendering!
  - Create Handlebar helpers to display arbitrary blocks of Sir Trevor data
- Add security measures when writing files
- Use a version control system to manage content history
  - E.g. by managing `frontend/data/` as git repo using node bindings for libgit2
  - Easily preview a set of content changes, generate a staging system from any revision
- Separate `frontend/` from the other parts of this repo (and add config file) to handle multiple frontends/sites by just specifying a path to the frontend directory

## License

MIT
