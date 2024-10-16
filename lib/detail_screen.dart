import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models.dart';
import 'globals.dart' as globals;

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

      var participation = Participation(int.parse(_adults!), _children == null || _children!.isEmpty ? 0 : int.parse(_children!), _takeaway!, Allergens(_meat!, _gluten!, _lactose!, _milk!, _nuts!, _freshFruit!, _onions!, _carrots!));

      Navigator.pop(context, participation);
    }
  }

  void _deleteParticipation() {
    var participation = Participation(0, 0, false, Allergens(false, false, false, false, false, false, false, false));
    Navigator.pop(context, participation);
  }

  @override
  Widget build(BuildContext context) {
    final dinnerEvent = ModalRoute.of(context)!.settings.arguments as DinnerEvent;

    _adults = _adults ?? dinnerEvent.participation?.adults.toString() ?? globals.prefillInformation?.adults.toString() ?? '';
    _children = _children ?? dinnerEvent.participation?.children.toString() ?? (globals.prefillInformation == null || globals.prefillInformation?.children == 0 ? '' : globals.prefillInformation?.children.toString()) ?? '';
    _takeaway = _takeaway ?? dinnerEvent.participation?.takeaway ?? false;
    _meat = _meat ?? dinnerEvent.participation?.allergens.meat ?? (dinnerEvent.chefCanAvoid.meat ? globals.prefillInformation?.allergens.meat : false) ?? false;
    _gluten = _gluten ?? dinnerEvent.participation?.allergens.gluten ?? (dinnerEvent.chefCanAvoid.gluten ? globals.prefillInformation?.allergens.gluten : false) ?? false;
    _lactose = _lactose ?? dinnerEvent.participation?.allergens.lactose ?? (dinnerEvent.chefCanAvoid.lactose ? globals.prefillInformation?.allergens.lactose : false) ?? false;
    _milk = _milk ?? dinnerEvent.participation?.allergens.milk ?? (dinnerEvent.chefCanAvoid.milk ? globals.prefillInformation?.allergens.milk : false) ?? false;
    _nuts = _nuts ?? dinnerEvent.participation?.allergens.nuts ?? (dinnerEvent.chefCanAvoid.nuts ? globals.prefillInformation?.allergens.nuts : false) ?? false;
    _freshFruit = _freshFruit ?? dinnerEvent.participation?.allergens.freshFruit ?? (dinnerEvent.chefCanAvoid.freshFruit ? globals.prefillInformation?.allergens.freshFruit : false) ?? false;
    _onions = _onions ?? dinnerEvent.participation?.allergens.onions ?? (dinnerEvent.chefCanAvoid.onions ? globals.prefillInformation?.allergens.onions : false) ?? false;
    _carrots = _carrots ?? dinnerEvent.participation?.allergens.carrots ?? (dinnerEvent.chefCanAvoid.carrots ? globals.prefillInformation?.allergens.carrots : false) ?? false;

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
                      enabledBorder: OutlineInputBorder(borderSide:  BorderSide(color: Theme.of(context).colorScheme.onPrimaryContainer)),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Tilføj et antal voksne';
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
                        enabledBorder: OutlineInputBorder(borderSide:  BorderSide(color: Theme.of(context).colorScheme.onPrimaryContainer))
                    ),
                    onSaved: (value) {
                      _children = value;
                    },
                  ),
                ),
                CheckboxListTile(
                  title: const Text('Takeaway'),
                  value: _takeaway,
                  shape: OutlineInputBorder(borderSide:  BorderSide(color: Theme.of(context).colorScheme.onPrimaryContainer)),
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
                    border: Border.all(color: Theme.of(context).colorScheme.onPrimaryContainer),
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
