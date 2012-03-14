#	TWiOS5ReverseAuthExample #
##	Summary ##
This demo application illustrates how to use the reverse_auth endpoint to generate a user's access token and secret if you are granted access to his ACAccount instance.

The latest version of this project can be found at [github](https://github.com/seancook/TWiOS5ReverseAuthExample).

To use the demo:

1. Follow the directions on ["Using Reverse Auth"](https://dev.twitter.com/docs/ios/using-reverse-auth) to obtain reverse auth access for your application.
2. Add your application's consumer key and secret to TWSignedRequest.m.
3. Build and run.  Click the button labeled "Perform Reverse Authorization" to execute the token exchange.

###  Author ###
This example was created by Sean Cook ([@theSeanCook](http://twitter.com/theSeanCook)).

###  License ###
Copyright (c) 2012 Sean Cook

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

### Twitter Marks ###
The use of the Twitter logos is governed by the [Guidelines for Use of the Twitter Trademark](https://support.twitter.com/articles/77641-guidelines-for-use-of-the-twitter-trademark)
### Memory Management Style ###
Main application:  Automatic Reference Counting (ARC) / Third party libraries: Manual reference counting
### Library Credits ###
Loren Brichter's ([@atebits](http://twitter.com/lorenb)) ABOAuthCore is available for download at [https://bitbucket.org/atebits/oauthcore](https://bitbucket.org/atebits/oauthcore) (see source files for license information).