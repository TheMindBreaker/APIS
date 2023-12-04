import 'graphql_client.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<bool> login(String username, String password) async {
  final GraphQLClient client = getClient();
  final MutationOptions options = MutationOptions(
    document: gql("""
      mutation TokenAuth(\$username: String!, \$password: String!) {
        tokenAuth(username: \$username, password: \$password) {
          payload
          token
        }
      }
    """),
    variables: {
      'username': username,
      'password': password,
    },
  );

  final QueryResult result = await client.mutate(options);

  if (result.hasException) {
    print(result.exception.toString());
    return false;
  }

  String? token = result.data?['tokenAuth']['token'];
  String? jwtName = result.data?['tokenAuth']['payload']['username'];
  if (token != null) {
    // Store the token
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
    await prefs.setString("jwt_name", jwtName!);
    return true;
  }
  return false;
}
