import 'package:flutter/material.dart';

import 'firebase_email_link_authenticator.dart';

class EmailLinkPage extends StatefulWidget {
  final FirebaseEmailLinkAuthenticator authenticator;

  const EmailLinkPage(this.authenticator, {Key key}) : super(key: key);

  @override
  State createState() => _EmailLinkPageState();
}

class _EmailLinkPageState extends State<EmailLinkPage>
    with WidgetsBindingObserver {
  TextEditingController _controllerEmail = TextEditingController();
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  bool _isLoading = false;

  get label => "Sign In With Link";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _controllerEmail.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      final Uri link = await widget.authenticator.retrieveDynamicLink();

      if (link != null) {
        await widget.authenticator
            .authenticate(context, {"link": link.toString()});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(label)),
      body: Builder(builder: (context) {
        return Container(
          color: Theme.of(context).primaryColorDark,
          padding: EdgeInsets.all(16),
          child: Center(
            child: Card(
              child: Container(
                padding: EdgeInsets.all(16),
                width: double.infinity,
                child: SingleChildScrollView(
                  child: Form(
                    key: _form,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(labelText: 'Email'),
                          controller: _controllerEmail,
                          validator: (String value) {
                            if (value.isEmpty) {
                              return 'Please enter your email.';
                            }
                            return null;
                          },
                        ),
                        _getSubmitButton(context),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _getSubmitButton(BuildContext context) {
    return _isLoading
        ? Container(
            margin: EdgeInsets.only(top: 16),
            padding: EdgeInsets.only(top: 8, bottom: 8),
            child: CircularProgressIndicator(),
          )
        : Container(
            margin: EdgeInsets.only(top: 16),
            child: Container(
                width: double.infinity,
                child: RaisedButton(
                  onPressed: () async {
                    if (_form.currentState.validate()) {
                      FocusScope.of(context).requestFocus(FocusNode());
                      setState(() {
                        _isLoading = true;
                      });
                      await widget.authenticator
                          .sendEmailLink(_controllerEmail.text);
                      widget.authenticator.notify(
                          context, "Please check email for activation link.");
                      if (this.mounted) {
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    }
                  },
                  child: Text(label),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                )),
          );
  }
}
