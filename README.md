#	TWiOSReverseAuthExample

##	Summary

This project illustrates how to use the Twitter API's reverse\_auth endpoint to obtain a user's access token and secret for your application's consumer key and secret.

The project is configured for building with the iOS7 SDK with a deployment target of iOS6.

The latest version of this project can be found at [github](https://github.com/seancook/TWReverseAuthExample).

### To use the demo:

1. First, take a look at ["Using Reverse Auth"](https://dev.twitter.com/docs/ios/using-reverse-auth) to understand how the process works.
2. Add your application's consumer key and secret to TWiOSReverseAuthExample-Info.plist under the `TWITTER_CONSUMER_KEY` and `TWITTER_CONSUMER_SECRET` keys, respectively.
3. Build and run. Click the button labeled "Perform Token Exchange" to execute the token exchange.

## Author

This example was created by Sean Cook ([@theSeanCook](http://twitter.com/theSeanCook)).

###  License

Copyright (c) 2013 Sean Cook

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

### Twitter Marks

The use of the Twitter logos is governed by the [Guidelines for Use of the Twitter Trademark](https://support.twitter.com/articles/77641-guidelines-for-use-of-the-twitter-trademark)

### Memory Management Style

Main application:  Automatic Reference Counting (ARC)

Third party libraries: Manual reference counting

### Library Credits
Loren Brichter's ([@atebits](http://twitter.com/lorenb)) ABOAuthCore is available for download at [https://bitbucket.org/atebits/oauthcore](https://bitbucket.org/atebits/oauthcore) (see source files for license information).
