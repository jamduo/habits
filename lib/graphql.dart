import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

const String host = String.fromEnvironment("GraphQL_Host", defaultValue: "staging.habits.jamduo.org/hasura/v1/graphql");
const bool useSSL = bool.fromEnvironment("GraphQL_Host_Secure", defaultValue: false);
final String wssURI = (useSSL ? "wss://" : "ws://") + host;
final String httpURI = (useSSL ? "https://" : "http://") + host;

class DatabaseProvider extends ChangeNotifier {
  User? _user;
  GraphQLClient? client;
  late final Link link;

  DatabaseProvider() {
    HttpLink httpLink = HttpLink(httpURI);
    AuthLink authLink = AuthLink(headerKey: "X-Google-Auth-Token", getToken: () => _user?.getIdToken());
    WebSocketLink websocketLink = WebSocketLink(wssURI,
      config: SocketClientConfig(
        autoReconnect: true,
        inactivityTimeout: Duration(seconds: 30),
        initialPayload: () async {
          return {
            'headers': {
              'X-Google-Auth-Token': await this._user?.getIdToken(),
            },
          };
        },
      ),
    );
    this.link = authLink.concat(websocketLink).concat(httpLink);
  }

  set user(User? user) {
    _user = user;
    client = (user == null) ? null : GraphQLClient( cache: GraphQLCache(), link: link );
    notifyListeners();
  }
}