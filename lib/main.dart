import 'package:flutter/material.dart';
import 'dart:math';

class Allergens {
  final bool meat;
  final bool gluten;
  final bool lactose;
  final bool milk;
  final bool nuts;
  final bool freshFruit;
  final bool carrots;

  const Allergens(this.meat, this.gluten, this.lactose, this.milk, this.nuts, this.freshFruit, this.carrots);
}

class Participation {
  final int adults;
  final int children;
  final bool takeaway;
  final Allergens allergens;

  const Participation(this.adults, this.children, this.takeaway, this.allergens);

  String participationText() {
    return '${takeaway ? "Takeaway" : "Deltager"} ($adults ${adults == 1 ? 'voksen' : 'voksne'}, $children ${children == 1 ? 'barn' : 'børn'})';
  }
}

class DinnerEvent {
  final String date;
  final String menu;
  final bool editable;
  final Allergens chefCanAvoid;
  final Participation? participation;

  const DinnerEvent(this.date, this.menu, this.editable, this.chefCanAvoid, this.participation);

  String participationText() {
    if (participation != null) {
      return participation!.participationText();
    } else if (editable) {
      return 'Tilmeld';
    } else {
      return 'Tilmelding lukket';
    }
  }

}

Future<List<DinnerEvent>> fetchDinnerEvents() async {
  await Future.delayed(const Duration(seconds: 4));
  int p = Random().nextInt(100);
  return [
    DinnerEvent('I dag', 'Bønne burritos med super grøn salat', false, Allergens(true, true, true, true, false, false, false), Participation(p, 1, false, Allergens(true, false, false, false, false, false, false))),
    DinnerEvent('Onsdag', 'Bønne burritos med super grøn salat', true, Allergens(true, true, true, true, false, false, false), Participation(1, 2, true, Allergens(true, false, false, false, false, false, false))),
    DinnerEvent('Torsdag', 'Ris taffel med kylling og en vegetar variant', false, Allergens(true, true, true, true, false, false, false), null),
    DinnerEvent('Tirsdag d. 4/10', 'Ris taffel med kylling og en vegetar variant', true, Allergens(true, true, true, true, false, false, false), null)
  ];
}

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<List<DinnerEvent>?> dinnerEvents;

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
        ),
        body: Center(
          child: FutureBuilder<List<DinnerEvent>?>(
            future: dinnerEvents,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return Card(child: ListTile(
                      title: Text('${snapshot.data![index].date}: ${snapshot.data![index].participationText()}'),
                      subtitle: Text(snapshot.data![index].menu),
                      enabled: snapshot.data![index].editable,
                      onTap: () {
                        _navigateAndDisplaySelection(context, snapshot.data![index]);
                      },
                    ),
                    );
                  },
                );
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

// Create a corresponding State class.
// This class holds data related to the form.
class DetailScreenState extends State<DetailScreen> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a GlobalKey<FormState>,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final dinnerEvent = ModalRoute.of(context)!.settings.arguments as DinnerEvent;

    return Scaffold(
      appBar: AppBar(
        title: Text(dinnerEvent.date),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(dinnerEvent.menu),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Navigator.pop(context, true);
                        }
                      },
                      child: const Text('Tilmeld'),
                    ),
                  ),
                ],
              ),
            )
          )
        ],
      )
    );
  }
}
