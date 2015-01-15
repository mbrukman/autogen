autogen
=======

Automatically generate boilerplate comments for new files with a single command.

Usage:

```bash
autogen.sh -c [copyright holder] -l [license] [filename]
```

To get a list of supported licenses, run `autogen.sh` with no parameters.

Developing
----------

To add a few file type or feature, change `autogen.sh` and add several files to
the `testdata/` directory, namely:

* `testdata/<feature>.in` - the input file containing command-line args to pass
  to `autogen.sh`
* `testdata/<feature>.out` - expected stdout for the test
* `testdata/<feature>.err` - expected stderr for the test

Testing
-------

`make test` will process all files in `testdata/` and tell you which
passed/failed.

License
-------

Apache 2.0; see [LICENSE.txt](LICENSE.txt) for details.
