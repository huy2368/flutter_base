/// Delta time in milliseconds
int deltaT = 0;

DateTime get serverTime => DateTime.now().add(Duration(milliseconds: deltaT));
