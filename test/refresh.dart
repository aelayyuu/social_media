// import 'package:path/path.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:dio/dio.dart';
// import 'dart:convert';

// void main() => runApp(MyApp());

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: HomePage(),
//     );
//   }
// }

// class HomePage extends StatefulWidget {
//   const HomePage({Key key}) : super(key: key);

//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   var isLoading = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Api to sqlite'),
//         centerTitle: true,
//         actions: <Widget>[
//           Container(
//             padding: EdgeInsets.only(right: 10.0),
//             child: IconButton(
//               icon: Icon(Icons.settings_input_antenna),
//               onPressed: () async {
//                 await _loadFromApi();
//               },
//             ),
//           ),
//           Container(
//             padding: EdgeInsets.only(right: 10.0),
//             child: IconButton(
//               icon: Icon(Icons.delete),
//               onPressed: () async {
//                 await _deleteData();
//               },
//             ),
//           ),
//         ],
//       ),
//       body: isLoading
//           ? Center(
//               child: CircularProgressIndicator(),
//             )
//           : _buildHouseListView(),
//     );
//   }

//   _loadFromApi() async {
//     setState(() {
//       isLoading = true;
//     });

//     var apiProvider = HouseApiProvider();
//     await apiProvider.getAllHouses();

//     // wait for 2 seconds to simulate loading of data
//     await Future.delayed(const Duration(seconds: 2));

//     setState(() {
//       isLoading = false;
//     });
//   }

//   _deleteData() async {
//     setState(() {
//       isLoading = true;
//     });

//     await DBProvider.db.deleteAllHouses();

//     // wait for 1 second to simulate loading of data
//     await Future.delayed(const Duration(seconds: 1));

//     setState(() {
//       isLoading = false;
//     });

//     print('All Houses deleted');
//   }

//   _buildHouseListView() {
//     return FutureBuilder(
//       future: DBProvider.db.getAllHouses(),
//       builder: (BuildContext context, AsyncSnapshot snapshot) {
//         if (!snapshot.hasData) {
//           return Center(
//             child: CircularProgressIndicator(),
//           );
//         } else {
//           return ListView.separated(
//             separatorBuilder: (context, index) => Divider(
//               color: Colors.black12,
//             ),
//             itemCount: snapshot.data.length,
//             itemBuilder: (BuildContext context, int index) {
//               List<Pet> pets = snapshot.data[index].pets;

//               return ListTile(
//                 leading: Text(
//                   "${index + 1}",
//                   style: TextStyle(fontSize: 20.0),
//                 ),
//                 title: Text(
//                     "Name: ${snapshot.data[index].id} ${snapshot.data[index].name} "),
//                 subtitle: Text('pets: ${pets[0].name}  ${pets[1].name}'),
//               );
//             },
//           );
//         }
//       },
//     );
//   }
// }

// class DBProvider {
//   static Database _database;
//   static final DBProvider db = DBProvider._();

//   DBProvider._();

//   Future<Database> get database async {
//     // If database exists, return database
//     if (_database != null) return _database;

//     // If database don't exists, create one
//     _database = await initDB();

//     return _database;
//   }

//   // Create the database and the House table
//   initDB() async {
//     Directory documentsDirectory = await getApplicationDocumentsDirectory();
//     final path = join(documentsDirectory.path, 'House2.db');

//     return await openDatabase(path, version: 1, onOpen: (db) {},
//         onCreate: (Database db, int version) async {
//       await db.execute('CREATE TABLE House('
//           'id INTEGER PRIMARY KEY,'
//           'name TEXT,'
//           'color TEXT,'
//           'pets TEXT'
//           ')');
//     });
//   }

//   // Insert House on database
//   createHouse(House newHouse) async {
//     await deleteAllHouses();
//     final db = await database;
//     //final res = await db.insert('House', newHouse.toJson());

//     String petsString = petToJson(newHouse.pets);
//     var raw = await db.rawInsert(
//         "INSERT Into House (id,name,color,pets)"
//         " VALUES (?,?,?,?)",
//         [newHouse.id, newHouse.name, newHouse.color, petsString]);

//     print('createHouse ${raw}');
//     return raw;
//   }

//   // Delete all Houses
//   Future<int> deleteAllHouses() async {
//     final db = await database;
//     final res = await db.rawDelete('DELETE FROM House');

//     return res;
//   }

//   Future<List<House>> getAllHouses() async {
//     final db = await database;
//     final res = await db.rawQuery("SELECT * FROM House");
//     print('getAllHouses $res');
//     List<House> list = [];

//     if (res != null) {
//       res.forEach((row) {
//         print(row["name"]);
//         print(row["pets"]);
//         var petsString = row["pets"];
//         var pets = petFromJson(petsString);
//         var house = House(
//             id: row["id"],
//             name: row["name"],
//             color: row["color"],
//             pets: pets);
//         list.add(house);
//       });
//     }
//     print('list  ${list.toString()} ');
//     return list;
//   }
// }

// class HouseApiProvider {
//   Future<List<House>> getAllHouses() async {
//     /* var url = "http://demo8161595.mockable.io/House";
//     Response response = await Dio().get(url);

//     return (response.data as List).map((House) {
//       print('Inserting $House');
//       DBProvider.db.createHouse(House.fromJson(House));
//     }).toList();*/

//     String response = '''
//    [{"id": 1, "name": "Smith", "color": "Green", "pets": 
// [{"id": 1, "breed": "Rottweiler", "name": "Mackie", "age": 8}, {"id": 2, "breed": "Mastiff", "name": "Tanner", "age": 8}]}]
//    ''';

//     List<House> houseList = houseFromJson(response);
//     houseList.forEach((house) {
//       DBProvider.db.createHouse(house);
//     });

//     print('houseList ${houseList.toString()}');
//     return houseList;
//   }
// }

// List<House> houseFromJson(String str) =>
//     List<House>.from(json.decode(str).map((x) => House.fromJson(x)));

// String houseToJson(List<House> data) =>
//     json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

// List<Pet> petFromJson(String str) =>
//     List<Pet>.from(json.decode(str).map((x) => Pet.fromJson(x)));

// String petToJson(List<Pet> data) =>
//     json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

// class House {
//   int id;
//   String name;
//   String color;
//   List<Pet> pets;

//   House({
//     this.id,
//     this.name,
//     this.color,
//     this.pets,
//   });

//   factory House.fromJson(Map<String, dynamic> json) => House(
//         id: json["id"],
//         name: json["name"],
//         color: json["color"],
//         pets: List<Pet>.from(json["pets"].map((x) => Pet.fromJson(x))),
//       );

//   Map<String, dynamic> toJson() => {
//         "id": id,
//         "name": name,
//         "color": color,
//         "pets": List<dynamic>.from(pets.map((x) => x.toJson())),
//       };
// }

// class Pet {
//   int id;
//   String breed;
//   String name;
//   int age;

//   Pet({
//     this.id,
//     this.breed,
//     this.name,
//     this.age,
//   });

//   factory Pet.fromJson(Map<String, dynamic> json) => Pet(
//         id: json["id"],
//         breed: json["breed"],
//         name: json["name"],
//         age: json["age"],
//       );

//   Map<String, dynamic> toJson() => {
//         "id": id,
//         "breed": breed,
//         "name": name,
//         "age": age,
//       };
// }