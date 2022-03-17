class Client {
  Client({
    required this.ip,
    required this.login,
    required this.password,
  });

  String ip;
  String login;
  String password;

  @override
  String toString() {
    return '''
          **************************************************
          *  Client
          *   IP = $ip 
          *   LOGIN = $login 
          *   PASSWORD = $password
          **************************************************
    ''';
  }
}
