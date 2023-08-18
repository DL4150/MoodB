//mongodb+srv://ArunKumarKailashG:atlass_bruh2@cluster0.lmapay3.mongodb.net:27017/moodb?retryWrites=true&w=majority
import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
        ),
        colorScheme: ColorScheme.dark().copyWith(
          primary: Colors.green[700],
          onPrimary: Colors.black,
          secondary: Colors.green[600],
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> _songs = [];
  bool _isLoading = false;
  String _selectedGenre = '';
  String _selectedEmotion = '';

  List<int> _genreValues = List.generate(11, (index) => index);
  List<String> _emotionValues = ['calm', 'sad', 'nost', 'insp', 'lov', 'joy'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Song List'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Select Genre:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 16),
              DropdownButton<int>(
                value: _selectedGenre.isNotEmpty
                    ? int.parse(_selectedGenre)
                    : null,
                onChanged: (int? newValue) {
                  setState(() {
                    _selectedGenre = newValue.toString();
                    _fetchSongs(_selectedGenre, _selectedEmotion);
                  });
                },
                items: _genreValues.map((int genre) {
                  return DropdownMenuItem<int>(
                    value: genre,
                    child: Text(genre.toString()),
                  );
                }).toList(),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Select Emotion:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 16),
              DropdownButton<String>(
                value: _selectedEmotion.isNotEmpty ? _selectedEmotion : null,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedEmotion = newValue ?? '';
                    _fetchSongs(_selectedGenre, _selectedEmotion);
                  });
                },
                items: _emotionValues.map((String emotion) {
                  return DropdownMenuItem<String>(
                    value: emotion,
                    child: Text(emotion),
                  );
                }).toList(),
              ),
            ],
          ),
          SizedBox(height: 16),
          if (_selectedGenre.isNotEmpty)
            Text(
              'Selected Genre: $_selectedGenre',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          if (_selectedEmotion.isNotEmpty)
            Text(
              'Selected Emotion: $_selectedEmotion',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          SizedBox(height: 32),
          Text(
            'Table:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : _songs.isEmpty
                    ? Center(
                        child: Text('No songs found'),
                      )
                    : TableWidget(songs: _songs),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchSongs(String selectedGenre, String selectedEmotion) async {
    setState(() {
      _isLoading = true;
    });

    try {
      var db = await mongo.Db.create(
          "mongodb+srv://ArunKumarKailashG:atlass_bruh2@cluster0.lmapay3.mongodb.net:27017/moodb?retryWrites=true&w=majority");
      await db.open();

      final collection = db.collection('songs');

      final query = mongo.where
          .eq('genre', int.parse(selectedGenre))
          .eq(selectedEmotion, 1);

      final songs = await collection.find(query).toList();

      setState(() {
        _songs = songs.map((song) => song as Map<String, dynamic>).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error connecting to MongoDB: $e');
      _isLoading = false;
    }
  }
}

class TableWidget extends StatelessWidget {
  final List<Map<String, dynamic>> songs;

  const TableWidget({Key? key, required this.songs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal, // Allow horizontal scrolling
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(
            headingTextStyle:
                TextStyle(color: Colors.green[600]), // Set header text color
            dataRowColor: MaterialStateColor.resolveWith(
              (states) =>
                  Colors.green[600]?.withOpacity(0.5) ?? Colors.transparent,
            ), // Set row background color
            columns: [
              DataColumn(label: Text('Songs')),
              DataColumn(label: Text('Release Year')),
            ],
            rows: songs
                .map(
                  (song) => DataRow(
                    cells: [
                      DataCell(Text(song['name']?.toString() ?? '')),
                      DataCell(Text(song['rel_year']?.toString() ?? '')),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
