import 'dart:io';

// it is not app with Adaptive UI

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sqlite_camera/fullImage.dart';
import 'package:sqlite_camera/models/picture_taker.dart';
import 'package:sqlite_camera/widgets/add_picture.dart';

import 'models/provider_cam.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PictureProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(title: 'Take and Save Pictures'),
      ),
    );
  }
}
class MyHomePage extends StatefulWidget {
  final String title;
  MyHomePage({required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _titleController = TextEditingController();
  late File _pickedImage;

  void _selectImage(File pickedImage){
    _pickedImage = pickedImage;
  }

  void _save(BuildContext context) async{
    await Provider.of<PictureProvider>(context, listen: false).addPicture(_titleController.text, _pickedImage);
    Navigator.of(context).pop();
  }
  void _startAddNewTransaction(BuildContext ctx){
    showModalBottomSheet(context: ctx, builder: (_) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: Column(
           children: [
             Padding(
               padding: const EdgeInsets.all(10.0),
               child: TextField(
                 maxLength: 16,
                 decoration: const InputDecoration(label: Text('Title')),
                 controller: _titleController,
               ),
             ),
             AddPicture(selectedImage: _selectImage),
             Center(
               child: ElevatedButton(
                 onPressed: () => _save(context),
                 child: Text('Done'),
               ),
             )
           ],
        )
      );
    });
  }
  _deleteMethod({
    required BuildContext context,
    required int i,
    required PictureProvider pictureTaker,
  }) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          elevation: 5,
          title: Text(
            'Warning',
            style: TextStyle(
                fontWeight: FontWeight.w400,
                color: Theme.of(context).errorColor),
          ),
          content: const Text(
            'Are you sure to delete?',
            style:
            TextStyle(fontWeight: FontWeight.w400, color: Colors.black87),
          ),
          actions: [
            TextButton(
              child: const Text('NO'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('YES'),
              onPressed: ()  async {
                Provider.of<PictureProvider>(context, listen: false).deleteById(pictureTaker.items[i].id.toString());
                Provider.of<PictureProvider>(context, listen: false).getData();
                Navigator.of(context).pop();
                print('here');
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          foregroundColor: Colors.black54,
          backgroundColor: Colors.white,
          centerTitle: true,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton.large(
          backgroundColor: Colors.white,
          elevation: 12,
          onPressed: () => _startAddNewTransaction(context),
          child: const Icon(Icons.add_rounded, size: 70, color: Colors.black54,),
        ),
        body: SizedBox(
          height: 620,
          child: FutureBuilder(
            future: Provider.of<PictureProvider>(context, listen: false).getData(),
            builder: (ctx, snapshot)
            => snapshot.connectionState == ConnectionState.waiting
                ? const Center(child: CircularProgressIndicator(),) :
            Consumer<PictureProvider>(
              child: const Center(child: Text('You have not any pictures yet!'),),
              builder: (ctx, pictureTaker, ch) { // ch did not work
                return pictureTaker.items.isEmpty ? const Center(child: Text('You have not any pictures yet!'),) : GridView.builder(
                  itemCount: pictureTaker.items.length,
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 300,
                    childAspectRatio: 1,
                    crossAxisSpacing: 1,
                    mainAxisSpacing: 1,
                  ),
                  itemBuilder: (ctx, i) {
                    return InkWell(
                      onLongPress: () => _deleteMethod(context: ctx, i: i, pictureTaker: pictureTaker),
                      onTap: () {
                        Navigator.of(context).push(
                            MaterialPageRoute(fullscreenDialog: true, builder: (context) => FullImage(title: pictureTaker.items[i].title, image: pictureTaker.items[i].image,)
                        ));
                      },
                      child: Container(
                        margin: EdgeInsets.all(10),
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.grey,
                              blurRadius: 10,
                              offset: Offset(3,2),
                              spreadRadius: 1,
                            )
                          ],
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image(
                                fit: BoxFit.cover,
                                height: double.infinity,
                                width: double.infinity,
                                alignment: Alignment.center,
                                image: FileImage(pictureTaker.items[i].image),
                              ),
                            ),
                            Positioned(
                              bottom: 8,
                              right: 0,
                              child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xC7031113),
                                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5) , topLeft: Radius.circular(5))
                              ),
                              child: Center(
                                child: Text(pictureTaker.items[i].title.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            ),
          ),
        )
      );
  }
}
