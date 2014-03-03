#Purpose

To replace Parse's OAuth process with deep iOS Twitter integration (pictures included below). This requires minimal changes to your existing code, and it becomes **so much easier** for a user to link their Twitter account and start using your app!

#Usage
1. Create a Parse app that successfully authenticates with Twitter by following [Parse's instructions](https://parse.com/docs/ios_guide#twitterusers/iOS).

2. Drag my "SuperParseTwitter" sub-folder into your project (make sure to check the "copy" box when prompted).

3. Add the following frameworks to your project (Select your project in the navigator, then your target, then the “Build Phases” tab, and look for the “Link Binary with Libraries” section):
  - Accounts.framework
  - Social.framework

4. In your view controller that contains the Parse login block, make 2 replacements:
  1. Change `#import <Parse/Parse.h>` to `#import "SuperParseTwitter.h"`
  
  2. Change `[PFTwitterUtils logInWithBlock:...];` to `[SuperParseTwitter logInWithBlock:...];`

5. Configure your Twitter app keys in SuperParseTwitter.m (the app will throw warnings if you don't).

###You're done! Now you'll see none of this:

![reverse_auth](http://johngazzini.com/assets/images/fini_oauth.jpeg "Webview Oauth")

###And lots of this:

![reverse_auth](http://johngazzini.com/assets/images/fini_reverse.jpeg "Reverse Auth")



#Disclaimer
At the time of writing, I can find no other drop-in libraries that provide this functionality. This library is (obviously) forked from Sean Cook's library, which was suggested by a Parser on [this post](https://parse.com/questions/ios-builtin-twitter-integration).


##Known Issues
- Memory Management: The app never actually releases the SuperParseTwitter singleton that gets created... oops.
- Untested: I'm sure there's a few ways to make this crash.
- [issue #249](http://www.youtube.com/watch?v=oHg5SJYRHA0)

##Suggested Updates
- Come up with a clever way to pull obfuscated keys from the same spot in both SuperParseTwitter.m and AppDelegate.m
- General code clean-up. Any help is appreciated; just initiate a pull-request!
