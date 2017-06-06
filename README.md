#	ReverseAuthExample

### iOS 11 ###
![Back to the future](./back-to-the-future.jpg)

It appears that [Twitter accounts will not be available via Accounts.framework in iOS 11](https://developer.apple.com/documentation/accounts/acaccounttype/account_type_identifiers?changes=latest_minor). If you need reverse auth, start migrating your apps to [Twitter Kit](https://dev.twitter.com/twitterkit/ios/overview) _today_. Seriously, just do it.

##    Summary

This project illustrates how to use the Twitter API's reverse\_auth endpoint to obtain a user's access token and secret for your application's consumer key and secret.

__Note:__ I created this project prior to the launch of [Twitter Fabric](https://www.fabric.io). I ~~am~~ was previously a Product Manager for Fabric, and that product includes reverse auth as well as many other useful features that I've helped developers with over the years. If you're looking for a full-featured Twitter SDK, I highly recommend taking a look at that project.

The latest version of this project can be found at [github](https://github.com/seancook/TWReverseAuthExample).

### To see the demo in action:

This project uses [cocoapods](https://www.cocoapods.org) to manage its dependencies.

1. Get the code:
```sh
git clone https://github.com/seancook/TWReverseAuthExample.git
cd TWReverseAuthExample
pod install
open ReverseAuthExample.xcworkspace
```

2. Add your application's consumer key and secret to TWiOSReverseAuthExample-Info.plist under the `TWITTER_CONSUMER_KEY` and `TWITTER_CONSUMER_SECRET` keys, respectively.

  **Note: Including your consumer secret in a mobile app is a bad idea.**

3. Build and run. Click the button labeled "Perform Token Exchange" to execute the token exchange.

## Author

This example was created by Sean Cook ([@theSeanCook](http://twitter.com/theSeanCook)).

###  License

Copyright (c) 2011-2017 Sean Cook

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

### Twitter Marks

The use of the Twitter logos is governed by the [Guidelines for Use of the Twitter Trademark](https://support.twitter.com/articles/77641-guidelines-for-use-of-the-twitter-trademark)

### Memory Management Style

Automatic Reference Counting (ARC)
