#  TWReverseAuthSubmodule

##	Summary

This code is intended to be used as a subproject of your own git/github project that requires Twitter Reverse Authentication for OAuth, primarily to be used to "Login using Twitter" to a separate service using OAuth.

This subproject is a subset of [TWReverseAuthExample](https://github.com/seancook/TWReverseAuthExample), stripped down to include only those files necessary to make it work as a submodule of another project and be inserted as such as a single folder into another project.

The latest version of this project can be found at [github](https://github.com/johnkdoe/TWReverseAuthSubmodule).  The default branch is submodule.  The master branch is meant to be left in tact to track the project from which this was originally forked.

### To use this submodule

1. First, take a look at ["Using Reverse Auth"](https://dev.twitter.com/docs/ios/using-reverse-auth) to understand how the process works.
1. Try using [Sean Cook's example on github](https://github.com/seancook/TWReverseAuthExample) to understand how to integrate this into your own projecct.
1. Add the folder containing this subproject to your own Xcode project.
1. Add your application's consumer key and secret in Build Settings under the User-Defined flags `TWITTER_CONSUMER_KEY` and `TWITTER_CONSUMER_SECRET`.
1. In the Xcode project's target Build Phases Tab, under Compile Sources, for the TWSignedRequest.m file, establish the following command line setting:  -D'TWITTER_CONSUMER_KEY=@"$(TWITTER_CONSUMER_KEY)"' -D'TWITTER_CONSUMER_SECRET=@"$(TWITTER_CONSUMER_SECRET)"'

## Revision History

2012 November 9




## Author

This submodule was created xolaware, derived from the [Example](https://github.com/seancook/TWReverseAuthExample) by Sean Cook ([@theSeanCook](http://twitter.com/theSeanCook)).

###  License

Copyright (c) 2012 xolaware llc

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

### Twitter Marks

The use of the Twitter logos is governed by the [Guidelines for Use of the Twitter Trademark](https://support.twitter.com/articles/77641-guidelines-for-use-of-the-twitter-trademark)

### Memory Management Style

Main application:  Automatic Reference Counting (ARC)

### Library Credits
Loren Brichter's ([@atebits](http://twitter.com/lorenb)) ABOAuthCore is available for download at [https://bitbucket.org/atebits/oauthcore](https://bitbucket.org/atebits/oauthcore) (see source files for license information).
