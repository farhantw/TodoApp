import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:todoapp/utils/todo_tile.dart';

import '../constants/todo_style.dart';
import '../data/database.dart';
import '../utils/dialog_box.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // reference the hive box
  final _myBox = Hive.box('mybox');
  ToDoDataBase db = ToDoDataBase();
  var date = DateTime.now();

  @override
  void initState() {
    // if this is the 1st time ever openin the app, then create default data
    if (_myBox.get("TODOLIST") == null) {
      db.createInitialData();
    } else {
      // there already exists data
      db.loadData();
    }

    super.initState();
  }

  // text controller
  final _todocontroller = TextEditingController();
  final _titlecontroller = TextEditingController();

  // save new task
  void saveNewTask() {
    setState(() {
      print(db.toDoList);
      db.toDoList.add([
        _titlecontroller.text,
        _todocontroller.text,
        "${date.day}/${date.month}/${date.year}"
      ]);
      _todocontroller.clear();
      _titlecontroller.clear();
    });
    Navigator.of(context).pop();
    db.updateDataBase();
  }

  // create a new task
  createNewTask() {
    return Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DialogBox(
                  titlecontroller: _titlecontroller,
                  todocontroller: _todocontroller,
                  onSave: saveNewTask,
                )));
  }

  // delete task
  void deleteTask(int index) {
    setState(() {
      db.toDoList.removeAt(index);
    });
    db.updateDataBase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: createNewTask,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 40.0,
            ),
            Text(
              "All Notes",
              style: ToDoStyle.fontWeight400FontSize36,
            ),
            SizedBox(
              height: 3.0,
            ),
            Text(
              "${db.toDoList.length} Notes",
              style: ToDoStyle.fontWeight100FontSize14,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: db.toDoList.length,
                itemBuilder: (context, index) {
                  return ToDoTile(
                    taskName: db.toDoList[index][0],
                    taskCompleted: db.toDoList[index][1],
                    date: db.toDoList[index][2],
                    index: index,
                    deleteFunction: (context) => deleteTask(index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
