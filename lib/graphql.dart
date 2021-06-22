import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

const String host = String.fromEnvironment("GraphQL_Host", defaultValue: "staging.habits.jamduo.org/v1/graphql");
final String wssURI = "wss://" + host;
final String httpURI = "https://" + host;
final String adminPassphrase = "";


class GraphQL {
  static final HttpLink httpLink = HttpLink(httpURI);
  static User? _user;
  static final AuthLink authLink = AuthLink(headerKey: "X-Google-Auth-Token", getToken: () => _user?.getIdToken());
  // static final AuthLink admin_authLink = AuthLink(headerKey: "x-hasura-admin-secret", getToken: () => admin_passphrase);
  
  static final WebSocketLink websocketLink =
  WebSocketLink(
    wssURI,
    config: SocketClientConfig(
      autoReconnect: true,
      inactivityTimeout: Duration(seconds: 30),
      initialPayload: () async {
        return {
          'headers': {
            // 'x-hasura-admin-secret': admin_passphrase,
            'X-Google-Auth-Token': await _user?.getIdToken(),
          },
        };
      },
    ),
  );

  static final Link link = authLink.concat(httpLink).concat(websocketLink);
  //  static final Link link = authLink.concat(admin_authLink).concat(httpLink).concat(websocketLink);
  static ValueNotifier<GraphQLClient> initailizeClient(User user) {
    _user = user;
    GraphQLClient client = GraphQLClient( cache: GraphQLCache(), link: link );
    return ValueNotifier(client);
  }
}