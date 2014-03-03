#Purpose
##To replace this:

![reverse_auth](http://johngazzini.com/assets/images/fini_oauth.jpeg "Webview Oauth")

##With this:

![reverse_auth](http://johngazzini.com/assets/images/fini_reverse.jpeg "Reverse Auth")


#Usage
1. Create a Parse app that successfully authenticates with Twitter by following [Parse's instructions](https://parse.com/docs/ios_guide#twitterusers/iOS).

2. Download this project, and drag the "SuperParseTwitter" folder into your project (make sure to check the "copy" box when prompted).

3. In your ViewController that contains the Parse login block, make 2 replacements:
  1. Change 
    #import <Parse/Parse.h>
to
    #import "SuperParseTwitter"
  
  2. Change
    [PFTwitterUtils logInWithBlock:
to
    [SuperParseTwitter logInWithBlock:'''

4. Configure your Twitter app keys in SuperParseTwitter.m (the app will throw warnings and log errors if you don't).

##Known Issues
- Memory Management: The app never actually releases the SuperParseTwitter singleton that gets created... oops.
- Untested: I'm sure there's a few ways to make this crash.
- [issue #249](http://www.youtube.com/watch?v=oHg5SJYRHA0)

##Suggested Updates
- Come up with a clever way to pull obfuscated keys from the same spot in both SuperParseTwitter.m and AppDelegate.m
- General code clean-up. Any help is appreciated; just initiate a pull-request!
