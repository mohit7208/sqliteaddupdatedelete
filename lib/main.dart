import 'package:flutter/material.dart';
import 'dbmanager.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final DbStudentManager dbmanager = new DbStudentManager();

  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _formKey = new GlobalKey<FormState>();
  Student student;
  List<Student> studlist; 
  int updateIndex;
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('Sqlite Demo'),
      ),
      body: ListView(
        children: <Widget>[
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  TextFormField(
                    decoration: new InputDecoration(labelText: 'FirstName'),
                    controller: _firstnameController,
                    validator: (val) =>
                        val.isNotEmpty ? null : 'FirstName Should Not Be empty',
                  ),
                  TextFormField(
                    decoration: new InputDecoration(labelText: 'LastName'),
                    controller: _lastnameController,
                    validator: (val) =>
                        val.isNotEmpty ? null : 'LastName Should Not Be empty',
                  ),
                  RaisedButton(
                    textColor: Colors.white,
                    color: Colors.blueAccent,
                    child: Container(
                        width: width * 0.9,
                        child: Text(
                          'Submit',
                          textAlign: TextAlign.center,
                        )),
                    onPressed: () {
                      _submitName(context);
                    },
                  ),
                  FutureBuilder(
                    future: dbmanager.getNameList(),
                    builder: (context,snapshot){
                      if(snapshot.hasData) {
                        studlist = snapshot.data;
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: studlist == null ?0 : studlist.length,
                          itemBuilder: (BuildContext context, int index) {
                           Student st = studlist[index];
                           return Card(
                             child: Row(
                               children: <Widget>[
                                 Container(
                                   width: width*0.6,
                                   child: Column(
                                     crossAxisAlignment: CrossAxisAlignment.start,
                                     children: <Widget>[
                                       Text('FirstName: ${st.firstname}',style: TextStyle(fontSize: 15),),
                                       Text('LastName: ${st.lastname}', style: TextStyle(fontSize: 15),),
                                     ],
                                   ),
                                 ),

                                 IconButton(onPressed: (){
                                   _firstnameController.text=st.firstname;
                                   _lastnameController.text=st.lastname;
                                   student=st;
                                   updateIndex = index;
                                 }, icon: Icon(Icons.edit, color: Colors.blueAccent,),
                                 alignment: Alignment.centerRight,),
                                IconButton(onPressed: (){
                                  dbmanager.deleteName(st.id);
                                  setState(() {
                                   studlist.removeAt(index); 
                                  });
                                }, icon: Icon(Icons.delete, color: Colors.red,),
                                alignment: Alignment.centerRight,
                                )
                               
                               ],
                             ),
                           );
                          },

                        );
                      }
                      return new CircularProgressIndicator();
                    },                   
                  )

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submitName(BuildContext context) {
    if(_formKey.currentState.validate()){
      if(student==null) {
        Student st = new Student(firstname: _firstnameController.text, lastname: _lastnameController.text);
        dbmanager.insertStudent(st).then((id)=>{
          _firstnameController.clear(),
          _lastnameController.clear(),
          print('Student Added to Db $id')
        });
      } else {
        student.firstname = _firstnameController.text;
        student.lastname = _lastnameController.text;

        dbmanager.updateName(student).then((id) =>{
          setState((){
            studlist[updateIndex].firstname = _firstnameController.text;
            studlist[updateIndex].lastname= _lastnameController.text;
          }),
          _firstnameController.clear(),
          _lastnameController.clear(),
          student=null
        });
      }
    }
  }
}
