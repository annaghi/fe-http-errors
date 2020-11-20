# FE HTTP Errors

If you do not have `elm-live` globally then run

```bash
npm install
```

Now you can watch and hot-reload the project with:

```bash
npm run watch
```

## Notes

The goal of this prototype to show a possible flow of pages on FE-HTTP errors.

There is one TODO in the code, which in my point of view is crucial:
log and monitor FE-HTTP errors. We can shortcut the personal contact with the user when fixing bugs.
We can leave this conversation when the things are going well :)

The prototype is not full, e.g. when you type directly an URL into the browser input, it will not load.
E.g. `http://localhost:8081/project/1`
