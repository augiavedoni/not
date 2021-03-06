import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:implicitly_animated_reorderable_list_2/implicitly_animated_reorderable_list_2.dart';
import 'package:kt_dart/kt.dart';

import '../misc/build_context_extension.dart';
import '../misc/todo_item_presentation_classes.dart';
import '../../../../application/notes/note_form/note_form_bloc.dart';
import '../../../../domain/notes/value_objects/todo_name.dart';

class TodoTile extends HookWidget {
  final int index;
  final double elevation;

  const TodoTile({
    Key? key,
    required this.index,
    this.elevation = 0.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double iconSize = Theme.of(context).iconTheme.size ?? 24;
    final TodoItemPrimitive todo = context.todos.getOrElse(
      index,
      (_) => TodoItemPrimitive.empty(),
    );
    final TextEditingController textEditingController =
        useTextEditingController(
      text: todo.name,
    );

    return Slidable(
      endActionPane: ActionPane(
        extentRatio: 0.25,
        motion: const ScrollMotion(),
        children: <Widget>[
          SlidableAction(
            flex: 1,
            borderRadius: BorderRadius.circular(15),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
            onPressed: (_) {
              context.todos = context.todos.minusElement(todo);

              context.read<NoteFormBloc>().add(
                    NoteFormEvent.todosChanged(context.todos),
                  );
            },
          ),
          const SizedBox(
            width: 10,
          ),
        ],
      ),
      child: Material(
        elevation: elevation,
        animationDuration: const Duration(milliseconds: 50),
        child: ListTile(
          visualDensity: const VisualDensity(horizontal: 0),
          leading: SizedBox(
            width: iconSize,
            height: iconSize,
            child: Checkbox(
              shape: const CircleBorder(),
              fillColor: MaterialStateColor.resolveWith(
                (_) => Colors.blue,
              ),
              side: BorderSide(
                width: 1.5,
                color: Colors.grey[500]!,
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              value: todo.completed,
              onChanged: (value) {
                context.todos = context.todos.map(
                  (listTodo) => listTodo == todo
                      ? todo.copyWith(completed: value!)
                      : listTodo,
                );

                context.read<NoteFormBloc>().add(
                      NoteFormEvent.todosChanged(context.todos),
                    );
              },
            ),
          ),
          trailing: const Handle(
            child: Icon(Icons.menu_rounded),
          ),
          title: TextFormField(
            enabled: !todo.completed,
            controller: textEditingController,
            style: todo.completed
                ? const TextStyle(
                    decoration: TextDecoration.lineThrough,
                  )
                : null,
            decoration: const InputDecoration(
              hintText: "To-Do",
              border: InputBorder.none,
              counterText: "",
            ),
            maxLength: TodoName.maxLength,
            onChanged: (value) {
              context.todos = context.todos.map(
                (listTodo) =>
                    listTodo == todo ? todo.copyWith(name: value) : listTodo,
              );

              context.read<NoteFormBloc>().add(
                    NoteFormEvent.todosChanged(context.todos),
                  );
            },
            validator: (_) =>
                context.read<NoteFormBloc>().state.note.todos.value.fold(
                      // Failure streaming from the TodoList length should NOT be displayed by the individual TextFormFields
                      (_) => null,
                      (todoList) => todoList[index].name.value.fold(
                            (failure) => failure.maybeMap(
                              empty: (_) => 'Cannot be empty',
                              exceedingLength: (_) => 'Too long',
                              multiLine: (_) => 'Has to be in a single line',
                              orElse: () => null,
                            ),
                            (_) => null,
                          ),
                    ),
          ),
        ),
      ),
    );
  }
}
