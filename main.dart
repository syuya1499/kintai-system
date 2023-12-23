import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:myapp/login.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp( 
    options: DefaultFirebaseOptions.android,
  );  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '勤怠管理',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String _searchQuery = '';
  TextEditingController _searchQueryController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _listItemKeys = {};

   _MyHomePageState() {
    _searchQueryController.addListener(() {
      if (_searchQueryController.text.isEmpty) {
        setState(() {
          _searchQuery = "";
        });
      }else {
        setState(() {
          _searchQuery = _searchQueryController.text;
        });
      }
    });
  }
 


  String selectedGender = '男';
  String selectDepartment = '営業部';
  // 年齢選択用のリスト
  List<int> ageOptions = List<int>.generate(100, (i) => i + 1); 
  int selectedAge = 20; 

  Future<void> selectTime(BuildContext context, Function(String) onSelected) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      onSelected(picked.format(context));
    }
  }

//登録メソッド
void _showRegisterDialog() async {
  String name = '';
  String tempSelectedAge = selectedAge.toString();
  String selectedGender = '男';
  String selectedDepartment = '営業部';
  String tempSelectedGender = selectedGender; 
  String tempSelectedDepartment = selectedDepartment;

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(  // StatefulBuilderを使用
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Text('新しい従業員の登録'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(labelText: '名前'),
                    onChanged: (value) {
                      name = value;
                    },
                  ),
                  DropdownButton<String>(
                    value: tempSelectedAge,
                    onChanged: (String? newValue) {
                      setState(() {
                        tempSelectedAge = newValue!;
                      });
                    },
                    items: ageOptions.map<DropdownMenuItem<String>>((int value) {
                      return DropdownMenuItem<String>(
                        value: value.toString(),
                        child: Text(value.toString()),
                      );
                    }).toList(),
                  ),
                  DropdownButton<String>(
                    value: tempSelectedDepartment,
                    onChanged: (String? newValue) {
                      setState(() { 
                        tempSelectedDepartment = newValue!;
                      });
                    },
                    items: ['営業部', 'エンジニア部','総務部','経理部','人事部'].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                
                  DropdownButton<String>(
                    value: tempSelectedGender,
                    onChanged: (String? newValue) {
                      setState(() {  
                        tempSelectedGender = newValue!;
                      });
                    },
                    items: ['男', '女'].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text('キャンセル'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('登録'),
                  onPressed: () async {
                    await firestore.collection('employees').add({
                      '名前': name,
                      '年齢': tempSelectedAge,
                      '性別': tempSelectedGender,
                      '事業部': tempSelectedDepartment,
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
        }
      );
        setState(() {
          selectedGender = tempSelectedGender; 
          selectDepartment = tempSelectedDepartment;
          selectedAge = int.parse(tempSelectedAge);
        });
      }
    //編集メソッド
    void _showEditDialog(Map<String, dynamic> employee, String employeeId) async {
        
      TextEditingController attendanceController = TextEditingController(text: employee['出勤'] ?? '');
      TextEditingController breakStartController = TextEditingController(text: employee['休始'] ?? '');
      TextEditingController breakEndController = TextEditingController(text: employee['休終'] ?? '');
      TextEditingController leavingController = TextEditingController(text: employee['退勤'] ?? '');
    Future<void> _selectTime(BuildContext context, TextEditingController controller) async {
      final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      controller.text = picked.format(context);
    }
  }

      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('従業員データの編集'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                TextFormField(
                controller: attendanceController,
                decoration: InputDecoration(labelText: '出勤'),
                readOnly: true,
                onTap: () => _selectTime(context, attendanceController),
              ),
                TextFormField(
                controller: breakStartController,
                decoration: InputDecoration(labelText: '休始'),
                readOnly: true,
                onTap: () => _selectTime(context, breakStartController),
              ),
               TextFormField(
                controller: breakEndController,
                decoration: InputDecoration(labelText: '休終'),
                readOnly: true,
                onTap: () => _selectTime(context, breakEndController),
              ),
               TextFormField(
                controller: leavingController,
                decoration: InputDecoration(labelText: '退勤'),
                readOnly: true,
                onTap: () => _selectTime(context, leavingController),
              ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text('キャンセル'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: Text('保存'),
                  onPressed: () {
                    _updateEmployeeData(employeeId, {
                      '出勤': attendanceController.text,
                      '退勤': leavingController.text,
                      '休始': breakStartController.text,
                      '休終': breakEndController.text,          
                      }
                    );
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }


    void _updateEmployeeData(String employeeId, Map<String, dynamic> newData) {
      firestore.collection('employees').doc(employeeId).update(newData);
    }

    //削除メソッド
    void _deleteEmployee(String employeeId) async {
      await firestore.collection('employees').doc(employeeId).delete();
    }
    // スクロールメソッド
    void _scrollToIndex(int index) {
      Future.delayed(Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            index * 80.0, 
            duration: Duration(seconds: 1),
            curve: Curves.easeInOut,
          );
        }
      });
    }


@override
void initState() {
  super.initState();
  _searchQueryController.addListener(() {
    if (_searchQueryController.text.isEmpty) {
      setState(() => _searchQuery = "");
    } else {
      setState(() {
        _searchQuery = _searchQueryController.text.toLowerCase();
      });
    }
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: TextField(
          controller: _searchQueryController,
          decoration: InputDecoration(
            hintText: "名前で検索...",
            hintStyle: TextStyle(color: Colors.white),
          ),
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: () {
                _showRegisterDialog();
              },
              child: Icon(Icons.add),
            ),  
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
      stream: firestore.collection('employees').orderBy('事業部', descending: false).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("エラーが発生しました");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        final documents = snapshot.data!.docs;
          var filteredIndexes = Iterable<int>.generate(documents.length).where(
            (index) => (documents[index].data() as Map<String, dynamic>)['名前'].toString().toLowerCase().contains(_searchQuery.toLowerCase()),
          ).toList();
          if (_searchQuery.isNotEmpty && filteredIndexes.isNotEmpty) {
            _scrollToIndex(filteredIndexes.first);
          }
        return ListView.builder(
          controller: _scrollController,
          itemCount: documents.length,
          itemBuilder: (context, index) {
            var employee = documents[index].data() as Map<String, dynamic>;
            var employeeId = documents[index].id; 
            return Card(
              child: ExpansionTile(
                title: Column(
                  children: [
                    Container(
                      child: Column(
                        children: [
                          if(employee['出勤'] == null || employee['出勤'].isEmpty || employee['退勤'] == null || employee['退勤'].isEmpty || employee['休始'] == null || employee['休始'].isEmpty || employee['休終'] == null || employee['休終'].isEmpty )
                            Text('*登録内容に不備があります*',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.red
                              ),
                            ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                flex: 1,
                                child: Text(employee['名前'] ?? ''),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(employee['性別'] ?? ''),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text('${employee['年齢']}歳'),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(employee['事業部'] ?? ''),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: (){
                    _showEditDialog(employee,employeeId);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _deleteEmployee(employeeId);
                  },
                ),
              ],
            ),
              children: <Widget>[
                DataTable(
                  columns: const <DataColumn>[
                    DataColumn(label: Text('出勤')),
                    DataColumn(label: Text('休始')),
                    DataColumn(label: Text('休終')),
                    DataColumn(label: Text('退勤')),
                  ],
                  rows: [
                    DataRow(
                      cells: <DataCell>[
                        DataCell(Text(employee['出勤'] ?? '')),
                        DataCell(Text(employee['休始'] ?? '')),
                        DataCell(Text(employee['休終'] ?? '')),
                        DataCell(Text(employee['退勤'] ?? '')),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );},
      );}
    )
  );}
   
@override
  void dispose() {
    _searchQueryController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}