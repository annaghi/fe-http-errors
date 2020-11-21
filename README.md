# FE HTTP Errors

![](page-flows.gif)

### Development

If you do not have `elm-live` globally then run

```bash
npm install
```

Now you can watch and hot-reload the project with:

```bash
npm run watch
```

### Notes

The goal of this prototype is to show a possible flow of pages on FE-HTTP errors.

There is one TODO in the code, which is crucial:
log and monitor FE-HTTP errors. We can shortcut the personal contact with the user when fixing bugs.
We can leave this conversation when the things are going well :)

The prototype is not full:
- the Projects page is just a view, not a full MVU
