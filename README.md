Instructions:

    You can run this on simulator using xcode version 7.2.1 or later or on an iphone running iOS 9.1 or later.

    Before you run this, 
    1.Please define the following parameter's in Defines.h
        GITHUB_CALLBACK_URL
        GITHUB_CLIENT_ID
        GITHUB_CLIENT_SECRET
    
    2. Install all Pod dependencies 'Pod install'
    

Implementation Details:

    Supports both iPhone and iPad.

    Supports OAuth authentication with Github

    using SVProgressHud for showing progress on Network requests. 

    using UICKeyChainStore for storing authentication access token instead of NSUserDefaults, 
    which is not very secure as there is no encryption.
    
    
    
    
