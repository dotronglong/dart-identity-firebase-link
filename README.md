# dart-identity-firebase-link
Authenticate using Email Link by Firebase for Identity package

## Getting Started

1. Enable `Sign In With Link` in Authentication settings of Firebase's project
2. Create a dynamic link domain and add it to authorised domains in Authentication settings
3. Add below package

```yaml
identity_firebase_link: ^0.1.0
```

4. Add following code to initState of main page

```dart
import 'package:identity/identity.dart';
import 'package:identity_firebase/identity_firebase.dart';
import 'package:identity_firebase_link/identity_firebase_link.dart';

// ...

@override
  void initState() {
    super.initState();
    Identity.of(context).init(
        FirebaseProvider([
          FirebaseEmailLinkAuthenticator(
              url: 'https://dotronglong.page.link',
              iOSBundleID: "com.example.app.my_app",
              androidPackageName: "com.example.app.my_app")
        ]),
        (context) => HomePage());
  }
```

5. Run the app

![Screenshot_1578638981](https://user-images.githubusercontent.com/6072939/72131998-d3490b00-33b8-11ea-8909-ae7f715178d9.png)
![Screenshot_1578639120](https://user-images.githubusercontent.com/6072939/72131997-d3490b00-33b8-11ea-8833-ee7abe2a9325.png)
