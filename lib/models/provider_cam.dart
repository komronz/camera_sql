import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sqlite_camera/models/picture_taker.dart';
import '../helpers/db_helper.dart';

class PictureProvider extends ChangeNotifier{
  List<PictureTaker> _items = [];
  List<PictureTaker> get items {
    return [..._items];
  }
  Future<void> addPicture(String title, File image,) async {
    final newPlace = PictureTaker(id: DateTime.now().toString(), title: title, image: image);

    _items.add(newPlace);
    notifyListeners();
    DBHelper.insert('user_pic', {
      'id': newPlace.id,
      'title': newPlace.title,
      'image': newPlace.image.path,
    });
    print('added');
    notifyListeners();
  }
  Future<void> getData() async {
    final dataList = await DBHelper.getData('user_pic');
    _items = dataList.map((item) => PictureTaker(
      id: item['id'],
      title: item['title'],
      image: File(
        item['image'],
      ),
    ),).toList();
    notifyListeners();
  }
  void deleteById(String id){
    DBHelper.deleteById(id);
    notifyListeners();
  }

}
