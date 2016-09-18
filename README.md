[![Build Status](https://travis-ci.org/mbrukman/autogen.svg?branch=master)](https://travis-ci.org/mbrukman/autogen)

autogen
=======

Automatically generate boilerplate comments and code for new files with a single
command.

Usage:

```bash
autogen.sh -c [copyright holder] -l [license] [filename]
```

Modify an existing file in-place:

```bash
autogen.sh -i [...other params as above...]
```

To get a list of supported licenses, or to see the full set of flags, run
`autogen.sh` with no parameters.

File type or language is determined based on the full filename or extension, as
appropriate. See [`autogen.sh`](autogen.sh) for a list of recognized file types.

Sample outputs:

* [Apache 2.0, Haskell](testdata/apache-acme-hs.out)
* [3-clause BSD, Erlang](testdata/bsd3-acme-erl.out)
* [GPL 2, Ruby](testdata/gpl2-acme-rb.out)
* [LGPL 2.1, C++](testdata/lgpl2.1-acme-cpp.out)
* [MIT, Makefile](testdata/mit-acme-makefile.out)

Developing
----------

To add a few file type or feature, change `autogen.sh` and add several files to
the `testdata/` directory, namely:

* `testdata/<feature>.in` - the input file containing command-line args to pass
  to `autogen.sh`
* `testdata/<feature>.out` - expected stdout for the test
* `testdata/<feature>.err` - expected stderr for the test

To generate the `*.out` and `*.err` files automatically, just add the `*.in`
files and run `make regen`. Then, examine the resulting `*.out` and `*.err`
files.

Testing
-------

You have two options:

* via [Bazel](http://bazel.io/): `bazel test //:all`
* via Make: `make test`

Either way, the test will process all files in [`testdata/`](testdata) and tell
you which passed or failed. Bazel is typically faster, especially when rerunning
tests, due to built-in caching.

License
-------

Apache 2.0; see [LICENSE.txt](LICENSE.txt) for details.
