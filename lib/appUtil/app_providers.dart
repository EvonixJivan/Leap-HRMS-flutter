import 'package:flutter/foundation.dart';

class Search with ChangeNotifier, DiagnosticableTreeMixin {
  var _search = false;
  var _searchIcon = false;
  var _searchText = '';

  bool get search => _search;

  bool get searchIcon => _searchIcon;

  String get searchText => _searchText;

  void searchChange() {
    _search = (_search) ? false : true;
    _searchText = '';
    notifyListeners();
  }

  void setSearchData(String strSearchData) {
    _searchText = strSearchData;
    notifyListeners();
  }

  void searchIconChange() {
    _searchIcon = (_searchIcon) ? false : true;

    notifyListeners();
  }
}

class ApiLoader with ChangeNotifier, DiagnosticableTreeMixin {
  var _load = false;
  var _reload = false;
  var _auth_token = '';

  bool get load => _load;

  bool get reload => _reload;

  void show() {
    _load = true;
  }

  void hide() {
    _load = false;
  }

  void loaderChange() {
    (_load) ?  hide() : show();
    notifyListeners();
  }

  void refreshList() {
    _reload = (_reload) ? false : true;
    notifyListeners();
  }

  void reloadActive() {
    _reload = true;
    notifyListeners();
  }

   void reloadDeactive() {
    _reload = false;
    notifyListeners();
  }


  void set_auth_token(auth_token) {
    _auth_token = auth_token;
  }

  String get_auth_token() {
    return _auth_token;
  }
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
//    properties.add(IntProperty('count', count));
  }

}
