import 'package:contador/repositories/todo_repository.dart';
import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../widgets/todo_list_item.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  List<Todo> todos = [];
  Todo? deletedTodo;
  int? deletedTodoPos;

  String? errorText;

  final TextEditingController todoController = TextEditingController();
  final TodoRepository todoRepository = TodoRepository();

  @override
  void initState(){
    super.initState();

    todoRepository.getTodoList().then((value) {
      setState(() {
        todos = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: todoController,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.pinkAccent,
                            )
                          ),
                          labelStyle: TextStyle(
                            color: Colors.pink,
                          ),
                          border: OutlineInputBorder(),
                          labelText: 'O que precisa comprar?',
                          hintText: 'Ovo',
                          errorText: errorText,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        String text = todoController.text;

                        if(text.isEmpty){
                          setState(() {
                            errorText = 'O campo não pode estar vazio';
                          });
                          return;
                        }

                        setState(() {
                          Todo newTodo = Todo(
                            title: text,
                            dateTime: DateTime.now(),
                          );
                          todos.add(newTodo);
                          errorText = null;
                        });
                        todoController.clear();
                        todoRepository.saveTodoList(todos);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        padding: EdgeInsets.all(14),
                      ),
                      child: Icon(
                        Icons.add,
                        size: 30,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (Todo todo in todos)
                        TodoListItem(
                          todo: todo,
                          onDelete: onDelete,
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Você precisa comprar ${todos.length} itens',
                      ),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: showDeleteTodosConfirmationDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        padding: EdgeInsets.all(14),
                      ),
                      child: Text('Limpar tudo'),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onDelete(Todo todo) {
    deletedTodo = todo;
    deletedTodoPos = todos.indexOf(todo);

    setState(() {
      todos.remove(todo);
    });
    todoRepository.saveTodoList(todos);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Item ${todo.title} foi removida com sucesso!',
          style: TextStyle(color: Colors.grey[700]),
        ),
        backgroundColor: Colors.grey[200],
        action: SnackBarAction(
          label: 'Desfazer',
          textColor: Colors.pink[400],
          onPressed: () {
            setState(() {
              todos.insert(deletedTodoPos!, deletedTodo!);
            });
            todoRepository.saveTodoList(todos);
          },
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void showDeleteTodosConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Limpar Tudo'),
        content: Text('Você tem certeza que deseja apagar todos os itens?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.grey),
            child: Text(
              'Cancelar',
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              deleteAllTodos();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Confirmar',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void deleteAllTodos(){
    setState(() {
      todos.clear();
    });
    todoRepository.saveTodoList(todos);
  }
}
