import 'dart:io';

import 'package:agenda_contatos/helpers/contact_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';



class ContactPage extends StatefulWidget {

  final Contact contact;
  ContactPage ({this.contact});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final _nameFocus=FocusNode();
  Contact _editedContact;
  bool _userEdited=false;


  @override
  void initState() {
    super.initState();

    if(widget.contact ==null){
      _editedContact = Contact();
      }else{
      _editedContact = Contact.fromMap(widget.contact.toMap());

      _nameController.text=_editedContact.name;
      _emailController.text=_editedContact.email;
      _phoneController.text=_editedContact.phone;
    }

  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop:
        _requestPop
      ,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_editedContact.name ??"Novo Contato"),
          centerTitle: true,

          backgroundColor: Colors.red,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: (){
            if(_editedContact.name !=null && _editedContact.name.isNotEmpty) {
              Navigator.pop(context, _editedContact);
            }else{
              FocusScope.of(context).requestFocus(_nameFocus);
            }
          },
          backgroundColor: Colors.red,
          child: Icon(Icons.save),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              GestureDetector(
                child:  Container(
                  width: 140,
                  height:140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image:_editedContact.img !=null?
                      FileImage(File(_editedContact.img)):
                      AssetImage("images/person.png"),
                    ),
                  ),
                ),
                onTap: (){
                  _requestCanOrGallery();
                },
              ),
              TextField(
                controller: _nameController,
                focusNode: _nameFocus,
                decoration: InputDecoration(labelText: "Nome"),
                onChanged: (text){
                  _userEdited=true;
                  setState(() {
                    _editedContact.name=text;
                  });
                },
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: "Email"),
                onChanged: (text){
                  _userEdited=true;
                  _editedContact.email=text;
                },
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: "Phone"),
                onChanged: (text){
                  _userEdited=true;
                  _editedContact.phone=text;
                },
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
      ),
    );
  }


  _requestCanOrGallery(){
    showModalBottomSheet(context: context,
        builder: (context){
      return BottomSheet(onClosing: (){},
          builder: (context){
              return Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(10),
                      child:  FlatButton(
                        child: Text("Gallery",
                          style: TextStyle(color: Colors.red, fontSize: 20),),
                        onPressed: (){
                          setState(() {
                            ImagePicker.pickImage(source: ImageSource.gallery).then((file){
                              if(file==null)return;
                              setState(() {
                                _editedContact.img = file.path;
                              });
                            });
                          });

                          Navigator.pop(context);
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child:  FlatButton(
                        child: Text("Camera",
                          style: TextStyle(color: Colors.red, fontSize: 20),),
                        onPressed: (){
                          Navigator.pop(context);
                          ImagePicker.pickImage(source: ImageSource.camera).then((file){
                            if(file==null)return;
                            setState(() {
                              _editedContact.img = file.path;
                              });

                          });
                        },
                      ),
                    ),
                  ],
                ),
              );
          });
        });
  }
  Future<Null> _cropImage(File imageFile) async {
    File croppedFile = await ImageCropper.cropImage(
      sourcePath: imageFile.path,
      ratioX: 1.0,
      ratioY: 1.0,
      maxWidth: 512,
      maxHeight: 512,
    );
    return croppedFile;
  }
  Future<bool> _requestPop(){
    if(_userEdited){
      showDialog(context: context,
      builder: (context)
      {
        return AlertDialog(
          title: Text("Descartar alterações?"),
          content: Text("Se sair os dados serão perdidos!"),
          actions: <Widget>[
            FlatButton(
              child: Text("Cancelar"),
              onPressed: (){
              Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text("Sim"),
              onPressed: (){
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ],
        );

      }
      );
      return Future.value(false);
    }else{
      return Future.value(true);
    }
  }
}
