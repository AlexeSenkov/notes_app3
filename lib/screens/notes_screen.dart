import 'package:flutter/material.dart';
import '../models/note.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final notes = <Note>[];
  final controller = TextEditingController();
  Note? editing;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void clearInput() {
    editing = null;
    controller.clear();
  }

  void saveNote() {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      final note = editing;
      if (note == null) {
        notes.insert(0, Note(text));
      } else {
        note.text = text;
      }
      clearInput();
    });
  }

  void openNote(Note note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Заметка'),
        content: SingleChildScrollView(child: Text(note.text)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  Widget noteRow(Note note) {
    return Dismissible(
      key: ObjectKey(note),
      direction: note.isImportant
          ? DismissDirection.horizontal
          : DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        color: Colors.grey.shade200,
        child: const Text('Снять звезду'),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        color: Colors.red.shade100,
        child: const Text('Удалить'),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          setState(() => note.isImportant = false);
          return false;
        }
        return true;
      },
      onDismissed: (_) => setState(() {
        notes.remove(note);
        if (editing == note) clearInput();
      }),
      child: Material(
        color: note.isImportant
            ? Colors.amber.shade100
            : Theme.of(context).scaffoldBackgroundColor,
        child: InkWell(
          onTap: () => openNote(note),
          onDoubleTap: () => setState(() => note.isImportant = true),
          onLongPress: () => setState(() {
            editing = note;
            controller.text = note.text;
          }),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            title:
                Text(note.text, maxLines: 2, overflow: TextOverflow.ellipsis),
            trailing: note.isImportant ? const Icon(Icons.star) : null,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Заметки')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: controller,
              minLines: 1,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: editing == null ? 'Новая заметка' : 'Редактирование',
              ),
            ),
            Row(
              children: [
                TextButton(
                  onPressed: saveNote,
                  child: Text(editing == null ? 'Добавить' : 'Сохранить'),
                ),
                if (editing != null)
                  TextButton(
                    onPressed: () => setState(clearInput),
                    child: const Text('Отмена'),
                  ),
              ],
            ),
            const Divider(),
            Expanded(
              child: notes.isEmpty
                  ? const Center(child: Text('Пока нет заметок'))
                  : ListView.separated(
                      itemCount: notes.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) => noteRow(notes[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
