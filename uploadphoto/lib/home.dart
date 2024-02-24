import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //To represent the pixel data of images
  Uint8List? image;
  File? myfile;
  String? note;

  // ignore: non_constant_identifier_names
  void ShowUploadDialog( BuildContext context){
    showDialog(context: context, builder: (context){return AlertDialog(
   title: const Text('Are you sure?' , style: TextStyle(color:Color(0xff2F5879) , fontSize: 25 , fontWeight: FontWeight.bold )),
          //content: Text('Do you want to upload the selected image?'),
   actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel' , style: TextStyle(color:Color(0xff2F5879)  ),),
            ),
            TextButton(
              onPressed: () {
                Snaak(context);
               // UploadImage(context, note!, myfile!);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Upload' , style: TextStyle(color:Color(0xff2F5879)  )),
            ),
          ],

    );});

  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Color(0xffC2D2CC),
      backgroundColor: const Color(0xffD0DBE1),
      body: Center(
        child: image!=null  ? 
                  Column( mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 120,
               backgroundImage: MemoryImage(image!),
               // child: Icon(Icons.person , color: Colors.amber,),
                ),
                Positioned( left: 170 , bottom: -9
          ,child: IconButton(onPressed: (){ShowOptions(context);}, icon: const Icon(Icons.add_a_photo , size: 35,color:Color(0xff2F5879) ),))
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal:75 , vertical: 10 ),
            child: TextField(
              onSubmitted: (value)async{ 
                note=value;
                note ??= '';},
                decoration: const InputDecoration(
                  labelText: 'Do you want to add a note? ',
                  labelStyle: TextStyle(color: Color(0xff2F5879) , fontWeight: FontWeight.bold),
                  focusedBorder: UnderlineInputBorder(
                 borderSide: BorderSide(color: Color(0xff2F5879)), ),
                 focusColor:Color(0xff2F5879), 
                  
                  ),
              
            ),
          ),


            MaterialButton(onPressed: (){ ShowUploadDialog(context);} , 
            child: const Text('Upload' , style: TextStyle(color:Color(0xff2F5879) , fontSize: 30 , fontWeight: FontWeight.bold ),),)
        ],
                  )
         : 
         Stack(
           children: [
             const CircleAvatar(
                         // ignore: sort_child_properties_last
                         backgroundColor: Colors.white,child: Icon(Icons.person , size: 200, color: Color(0xffD0DBE1),),
                         radius: 120,),
                         Positioned( left: 170 , bottom: -9
          ,child: IconButton(onPressed: (){ShowOptions(context);}, icon: const Icon(Icons.add_a_photo , size: 35, color:Color(0xff2F5879) ,),
        
        ))
        
           ],
         ),
      ),
    );
  }
// ignore: non_constant_identifier_names
void ShowOptions(BuildContext context){
    showModalBottomSheet(context: context, builder: (builder){
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox( 
          width: MediaQuery.of(context).size.width,
          height:MediaQuery.of(context).size.height/4 , 
          child: Column(crossAxisAlignment : CrossAxisAlignment.start,
            children: [
               const Padding(
                 padding: EdgeInsets.all(10.0),
                 child: Text('Choose:' , style: TextStyle(fontSize: 30 , fontWeight:FontWeight.w500 , color:Color(0xff2F5879)  ),),
               ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left:20 ),
                  child: MaterialButton(onPressed: ()async{
                      XFile? xfile= await ImagePicker().pickImage(source: ImageSource.gallery );
                      if (xfile==null) return;
                       setState(() {
                        myfile = File(xfile!.path);
                        image=File(xfile.path).readAsBytesSync();
                      }); 
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pop();
                      
                    } , 
                    child: const Column(
                      children: [ 
                        Icon(Icons.image , size: 50, color:Color(0xff2F5879) ),
                        Text('Gallery' , style: TextStyle(fontSize:20 , color:Color(0xff2F5879)  ),),
                      ],
                    ),),
                ),
                  Padding(
                    padding: const EdgeInsets.only(left: 120),
                    child: MaterialButton(onPressed: ()async{
                      XFile? xfile= await ImagePicker().pickImage(source: ImageSource.camera );
                      if (xfile==null) return;
                       setState(() {
                        myfile = File(xfile.path);
                        image=File(xfile.path).readAsBytesSync();
                      }); 
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pop();
                      
                    } , 
                    child: const Column(
                      children: [ 
                        Icon(Icons.camera_alt , size: 50, color:Color(0xff2F5879) ),
                        Text('Camera' , style: TextStyle(fontSize:20  , color:Color(0xff2F5879) ),),
                      ],
                    ),),
                  ),
              ],
            ),
        
          ],),
        ), 
      );} );
      
  }
  
}
// ignore: non_constant_identifier_names
Future<void>  UploadImage( BuildContext context, String data , File file)async{
  Uri url= Uri.parse('YOUR URL');
  var request= http.MultipartRequest('POST' , url);
  var lengthImage= await file.length();
  var stream=http.ByteStream(file.openRead());

  //instead of 'file' write the request name in back-end:
  var uploadedImage=http.MultipartFile('file', stream, lengthImage , filename: basename(file.path));

// to upload the image on server:
request.files.add(uploadedImage);
// to upload the note on server:
request.fields['Note']=data;
// to send the request:
var finalRequest=await request.send();
var response= await http.Response.fromStream(finalRequest);
if(response.statusCode==200){
  print ('success');
  // ignore: use_build_context_synchronously
  ScaffoldMessenger.of(context).showSnackBar(SnackBar (content: Text('Success$jsonDecode(response.body)' , style: TextStyle( color: Color(0xffD0DBE1)),),elevation:MediaQuery.of(context).size.height/5, 
  action:SnackBarAction(label:'Ok', onPressed: (){}) , duration: const Duration(seconds: 4),));

}
else{
  print('Error:${finalRequest.statusCode}');
  // ignore: use_build_context_synchronously
  ScaffoldMessenger.of(context).showSnackBar(SnackBar (content: const Text('Error' , style: TextStyle( color: Color(0xffD0DBE1)),),elevation:MediaQuery.of(context).size.height/5, 
  action:SnackBarAction(label:'Try again', onPressed: (){}) , duration: const Duration(seconds: 4),));
}
}
void Snaak(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        'Success',
        style: TextStyle(color: Colors.white),
      ),
      elevation: MediaQuery.of(context).size.height / 5,
      action: SnackBarAction(label: 'ok', onPressed: () {}),
      duration: Duration(seconds: 4),
      backgroundColor: Color(0xff2F5879),
    ),
  );
}
