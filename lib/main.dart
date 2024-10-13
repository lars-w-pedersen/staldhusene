import 'package:flutter/material.dart';
import 'get_sheet_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

String? _houseNumber;

Future<DinnerInformation> fetchDinnerEvents() async {

  var response = await GoogleSheetsApiData().accessGoogleSheetData(_houseNumber);

  _houseNumber = response.houseNumber;

  return response;
}

Future<void> updateDinnerEventParticipation(int index, Participation participation) async {
  await GoogleSheetsApiData().updateDinnerEventParticipation(index, participation, _houseNumber!);
}

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<DinnerInformation> dinnerEvents;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    dinnerEvents = fetchDinnerEvents();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fællesspisning',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Fællesspisning'),
          centerTitle: true,
        ),
        body: Center(
          child: FutureBuilder<DinnerInformation>(
            future: dinnerEvents,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
                if(snapshot.data!.houseNumber == null) {
                  return DropdownMenu<String>(
                    label: const Text('Husnummer'),
                    onSelected: (String? value) {
                      _houseNumber = value!;
                      SharedPreferencesAsync().setString('houseNumber', value);
                      setState(() {
                        dinnerEvents = fetchDinnerEvents();
                      });
                    },
                    dropdownMenuEntries: [
                      DropdownMenuEntry<String>(value: 'P3', label: 'Pilotvej 3'),
                      DropdownMenuEntry<String>(value: 'P4', label: 'Pilotvej 4'),
                      DropdownMenuEntry<String>(value: 'P5', label: 'Pilotvej 5'),
                      DropdownMenuEntry<String>(value: 'P6', label: 'Pilotvej 6'),
                      DropdownMenuEntry<String>(value: 'P7', label: 'Pilotvej 7'),
                      DropdownMenuEntry<String>(value: 'P8', label: 'Pilotvej 8'),
                      DropdownMenuEntry<String>(value: 'P9', label: 'Pilotvej 9'),
                      DropdownMenuEntry<String>(value: 'P10', label: 'Pilotvej 10'),
                      DropdownMenuEntry<String>(value: 'P11', label: 'Pilotvej 11'),
                      DropdownMenuEntry<String>(value: 'P12', label: 'Pilotvej 12'),
                      DropdownMenuEntry<String>(value: 'P13', label: 'Pilotvej 13'),
                      DropdownMenuEntry<String>(value: 'P14', label: 'Pilotvej 14'),
                      DropdownMenuEntry<String>(value: 'P15', label: 'Pilotvej 15'),
                      DropdownMenuEntry<String>(value: 'P16', label: 'Pilotvej 16'),
                      DropdownMenuEntry<String>(value: 'P17', label: 'Pilotvej 17'),
                      DropdownMenuEntry<String>(value: 'P18', label: 'Pilotvej 18'),
                      DropdownMenuEntry<String>(value: 'P19', label: 'Pilotvej 19'),
                      DropdownMenuEntry<String>(value: 'P20', label: 'Pilotvej 20'),
                      DropdownMenuEntry<String>(value: 'P21', label: 'Pilotvej 21'),
                      DropdownMenuEntry<String>(value: 'P23', label: 'Pilotvej 23'),
                      DropdownMenuEntry<String>(value: 'P24', label: 'Pilotvej 24'),
                      DropdownMenuEntry<String>(value: 'P25', label: 'Pilotvej 25'),
                      DropdownMenuEntry<String>(value: 'P26', label: 'Pilotvej 26'),
                      DropdownMenuEntry<String>(value: 'P27', label: 'Pilotvej 27'),
                      DropdownMenuEntry<String>(value: 'P28', label: 'Pilotvej 28'),
                      DropdownMenuEntry<String>(value: 'P29', label: 'Pilotvej 29'),
                      DropdownMenuEntry<String>(value: 'P30', label: 'Pilotvej 30'),
                      DropdownMenuEntry<String>(value: 'P31', label: 'Pilotvej 31'),
                      DropdownMenuEntry<String>(value: 'P32', label: 'Pilotvej 32'),
                      DropdownMenuEntry<String>(value: 'P33', label: 'Pilotvej 33'),
                      DropdownMenuEntry<String>(value: 'P35', label: 'Pilotvej 35'),
                      DropdownMenuEntry<String>(value: 'P37', label: 'Pilotvej 37'),
                      DropdownMenuEntry<String>(value: 'P39', label: 'Pilotvej 39'),
                      DropdownMenuEntry<String>(value: 'P41', label: 'Pilotvej 41'),
                      DropdownMenuEntry<String>(value: 'P43', label: 'Pilotvej 43'),
                      DropdownMenuEntry<String>(value: 'P45', label: 'Pilotvej 45'),
                      DropdownMenuEntry<String>(value: 'P47', label: 'Pilotvej 47'),
                      DropdownMenuEntry<String>(value: 'P49', label: 'Pilotvej 49'),
                      DropdownMenuEntry<String>(value: 'P51', label: 'Pilotvej 51'),
                      DropdownMenuEntry<String>(value: 'P53', label: 'Pilotvej 53'),
                      DropdownMenuEntry<String>(value: 'P55', label: 'Pilotvej 55'),
                      DropdownMenuEntry<String>(value: 'P57', label: 'Pilotvej 57'),
                    ],
                    initialSelection: snapshot.data!.houseNumber,
                  );
                } else {
                  if(snapshot.data!.events.isEmpty) {
                    return Text('Der er ikke nogen fremtidige middage planlagt');
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.events.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            title: Text('${snapshot.data!.events[index].date}: ${snapshot.data!.events[index].participationText()}'),
                            subtitle: Text(snapshot.data!.events[index].menu),
                            enabled: snapshot.data!.events[index].editable,
                            onTap: () {
                              _navigateAndDisplaySelection(context, snapshot.data!.events[index]);
                            },
                          ),
                        );
                      },
                    );
                  }
                }
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }
              return const CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }

  Future<void> _navigateAndDisplaySelection(BuildContext context, DinnerEvent dinnerEvent) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DetailScreen(),
        settings: RouteSettings(
          arguments: dinnerEvent,
        ),
      ),
    );

    if (!context.mounted) return;

    if (result) {
      setState(() {
        dinnerEvents = fetchDinnerEvents();
      });
    }
  }
}

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key});

  @override
  DetailScreenState createState() {
    return DetailScreenState();
  }
}

class DetailScreenState extends State<DetailScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _adults;
  String? _children;
  bool? _takeaway;
  bool? _meat;
  bool? _gluten;
  bool? _lactose;
  bool? _milk;
  bool? _nuts;
  bool? _freshFruit;
  bool? _onions;
  bool? _carrots;


  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Save the form data

      final dinnerEvent = ModalRoute.of(context)!.settings.arguments as DinnerEvent;
      var participation = Participation(int.parse(_adults!), int.parse(_children!), _takeaway!, Allergens(_meat!, _gluten!, _lactose!, _milk!, _nuts!, _freshFruit!, _onions!, _carrots!));

      updateDinnerEventParticipation(dinnerEvent.index, participation);

      Navigator.pop(context, true);
    }
  }

  void _deleteParticipation() {
    final dinnerEvent = ModalRoute.of(context)!.settings.arguments as DinnerEvent;
    var participation = Participation(0, 0, false, Allergens(false, false, false, false, false, false, false, false));

    updateDinnerEventParticipation(dinnerEvent.index, participation);

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final dinnerEvent = ModalRoute.of(context)!.settings.arguments as DinnerEvent;

    _adults = _adults ?? dinnerEvent.participation?.adults.toString() ?? '';
    _children = _children ?? dinnerEvent.participation?.children.toString() ?? '';
    _takeaway = _takeaway ?? dinnerEvent.participation?.takeaway ?? false;
    _meat = _meat ?? dinnerEvent.participation?.allergens.meat ?? false;
    _gluten = _gluten ?? dinnerEvent.participation?.allergens.gluten ?? false;
    _lactose = _lactose ?? dinnerEvent.participation?.allergens.lactose ?? false;
    _milk = _milk ?? dinnerEvent.participation?.allergens.milk ?? false;
    _nuts = _nuts ?? dinnerEvent.participation?.allergens.nuts ?? false;
    _freshFruit = _freshFruit ?? dinnerEvent.participation?.allergens.freshFruit ?? false;
    _onions = _onions ?? dinnerEvent.participation?.allergens.onions ?? false;
    _carrots = _carrots ?? dinnerEvent.participation?.allergens.carrots ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(dinnerEvent.date),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.zero,
          child: Text(dinnerEvent.menu),
        )
      ),
      body: Form(
        key: _formKey,
        child: Center(
          child: ListView(
            padding: const EdgeInsets.all(8),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  initialValue: _adults,
                  decoration: InputDecoration(
                    labelText: 'Voksne',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _adults = value!;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  initialValue: _children,
                  decoration: InputDecoration(
                    labelText: 'Børn',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _children = value!;
                  },
                ),
              ),
              CheckboxListTile(
                title: const Text('Takeaway'),
                value: _takeaway,
                shape: OutlineInputBorder(borderSide: const BorderSide(color: Colors.black54)),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (bool? newValue) {
                  setState(() {
                    _takeaway = newValue!;
                  });
                },
              ),
              Container(
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black54),
                  borderRadius: BorderRadius.all(
                      Radius.circular(4.0)
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CheckboxListTile(
                      title: const Text('Kød'),
                      value: _meat,
                      enabled: dinnerEvent.chefCanAvoid.meat,
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (bool? newValue) {
                        setState(() {
                          _meat = newValue!;
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Gluten'),
                      value: _gluten,
                      enabled: dinnerEvent.chefCanAvoid.gluten,
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (bool? newValue) {
                        setState(() {
                          _gluten = newValue!;
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Laktose'),
                      value: _lactose,
                      enabled: dinnerEvent.chefCanAvoid.lactose,
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (bool? newValue) {
                        setState(() {
                          _lactose = newValue!;
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Mælkeprodukter'),
                      value: _milk,
                      enabled: dinnerEvent.chefCanAvoid.milk,
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (bool? newValue) {
                        setState(() {
                          _milk = newValue!;
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Hasselnødder, Valnødder og Pekannød'),
                      value: _nuts,
                      enabled: dinnerEvent.chefCanAvoid.nuts,
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (bool? newValue) {
                        setState(() {
                          _nuts = newValue!;
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Friske æbler / Stenfrugt / Rosiner'),
                      value: _freshFruit,
                      enabled: dinnerEvent.chefCanAvoid.freshFruit,
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (bool? newValue) {
                        setState(() {
                          _freshFruit = newValue!;
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Løg, Hvidløg, Forårsløg, Porre.'),
                      value: _onions,
                      enabled: dinnerEvent.chefCanAvoid.onions,
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (bool? newValue) {
                        setState(() {
                          _onions = newValue!;
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Gulerødder'),
                      value: _carrots,
                      enabled: dinnerEvent.chefCanAvoid.carrots,
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (bool? newValue) {
                        setState(() {
                          _carrots = newValue!;
                        });
                      },
                    ),
                  ]
                ),
              ),
              updateButtens(dinnerEvent),
            ],
          ),
        ),
      )
    );
  }

  Widget updateButtens(DinnerEvent dinnerEvent) {
    var addButton = Padding(
      padding: const EdgeInsets.all(8),
      child: ElevatedButton(
        onPressed: _submitForm,
        child: Text(dinnerEvent.participation == null ? 'Tilmeld' : 'Opdater tilmelding'),
      ),
    );
    var deleteButton = Padding(
      padding: const EdgeInsets.all(8),
      child: ElevatedButton(
        onPressed: _deleteParticipation,
        child: Text('Slet tilmelding'),
      ),
    );

    if(dinnerEvent.participation == null) {
      return addButton;
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          addButton,
          deleteButton,
        ],
      );
    }
  }
}
