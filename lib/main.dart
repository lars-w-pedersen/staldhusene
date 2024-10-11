import 'package:flutter/material.dart';
import 'get_sheet_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

Future<List<DinnerEvent>> fetchDinnerEvents() async {

  String privateKey = """-----BEGIN PRIVATE KEY-----
MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDOIeZUXNCwGhLF
ixtvPTBFIBf4epMT18BdFwqGmLYG8zli95nxyofpIvkCZ9uEi/t5xOF0O4j6LRCg
414vMr4/jsIAEjDvD054GHR489XY4NBso8gc1/HO4Ht2q3usoeFqPUBWwkU9riBB
ZoG00xR2YTds3DJsARz+PoixIC2qUy+ei9S3aZs07AZ5PBQO5yRjUkQ7VsWtLit3
5jOt8rmoenNGS8fp065uXrtpq99bW973NEnlPRFYYxrfaIHvtIjxBYlvuwIjdctY
ITco5ZoO0CSheUSgtLA2gHRHrai2Az1adHo2HjPwSjmnBnaI95nfaWGvR2RigxeG
h3/857B9AgMBAAECggEAFNs7Odf2SYsp0REFIpk3VBcuNbb5QK24yfJ13y5+ZG+h
o9DXo65RWBZwyXyGqn+bXzO7eA46Cs4ae5zlv7LLqxSfrnAowVd0IhSfXEmXno0I
qaVcrwZucfcmptgs+EeczioKY3zekqIWo2diwlAFJwEpIXuaInFuZI8hN4LA/BWl
+EP+4LnKTTT9PucmK5Mpq3TNh94v2hcHLKvq+EsJcRhUIEmlIrQ+7qV6QHmZWqS7
UdznxwumpqJGSIBRD7+JFbrEOLw03xPvHAz92WTawztZUGY5Dv7w0JJ4HLgf5jVC
ggHQBSyZnK0PVOsC1n68ySLHJy2B9b+WSglaQV8cQQKBgQD6XjXP42mlkQNGnapm
i9StDhfBC9Uv9d/1CWFPd+MNGhDoFtZ0KQ2A1MEBJmf1vdqmotiviIkApIviDSH+
MJpiUDt1jea8WBXjGhbJBJQ0HqjRYOucy2fFhWrVKiVq5KRVopcn2a/gFLQDGRQk
QXEKGAH66AAjuXg8BXo0CsNSUQKBgQDSxPNphlYW9TQNp29ajqQoZbIADUXo8Ok/
DXVsj7SSpW4+wl1ztKzxiE34a87TVHU2/nMW8oTSktXCE4k0fBjEeuIrh1Gkrae1
SER/k791m+jqe9UPXhVeh7nTzldNmFe8PKifa5RTHRN9tQqxCfbvOBz+2fA6ZWvV
67JxtrZkbQKBgF3o1HpjrI7js7zbCr1oGZ/Ht3U7gP16VkTM/ekW6N1TN6A2YL41
X9FA/Bv4UepFCiySzIAa0HijP6zMjEGR7XaO7Z6MWU2wJJWIhZ9kzko2bdALcJTh
Xs0h3A6UvnA3zsQoNlZGOsfsPBElaP6oZUQJ+UQpnVPJD6ZDz7CRkO3hAoGBAJt0
7Nw+Wy0fuj7/6h/u6aFqMLndEF1Zo5AAC0YBUHyBTCk6DteSwaR8lpXOXoR83N+t
GZIpWlI+Py+gXSi7B0GUKVFVw6Ak/Xe2T9+RSDwkvMyGfYWSLUzF6wgQP1BaNwv9
6Zl8LbCH16J2b+ZYpSuYRbqrYIaR29GywLEixLCZAoGAD08kW0k+s71y2YSNDPzX
jZXXjtdpvxGwdtJsTCXVtekbScGxkmc6WmyhDYCsls2VZh25MkiYsWwgVZAKORk4
M9IQHxtcPvUaT5IIzsXqjhFWGoIcVEnavcEkcY9PfKSIEBLhWxJFFn9D42heFwBK
kHEIoS0UqyZqdcMCZpaOo8o=
-----END PRIVATE KEY-----""";


  var response = await GoogleSheetsApiData(
      clientEmail: 'staldhusene-app-service-acc@staldhusene-app.iam.gserviceaccount.com',
      clientId: '104866680526764500509',
      privateKey: privateKey,
      url: 'https://docs.google.com/spreadsheets/d/16ASTBB0dUuX_EIiz_MhSeDRf_HaYixi5wk3EDa15Xa4'
  ).accessGoogleSheetData();

  return response;
}

Future<String> fetchHouseNumber() async {
  String houseNumber = await SharedPreferencesAsync().getString('houseNumber') ?? '';
  return houseNumber;
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
  late Future<List<DinnerEvent>?> dinnerEvents;
  late Future<String?> houseNumber;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    dinnerEvents = fetchDinnerEvents();
    houseNumber = fetchHouseNumber();
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 100.0,
                  width: MediaQuery.of(context).size.width,
                  child: Center(
                      child: FutureBuilder<String?>(
                        future: houseNumber,
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
                            return DropdownMenu<String>(
                              label: const Text('Husnummer'),
                              onSelected: (String? value) {
                                SharedPreferencesAsync().setString('houseNumber', value!);
                                setState(() {
                                  dinnerEvents = fetchDinnerEvents();
                                  houseNumber = fetchHouseNumber();
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
                              initialSelection: snapshot.data,
                            );
                          } else if (snapshot.hasError) {
                            return Text('${snapshot.error}');
                          }

                          return const CircularProgressIndicator();
                        },
                      )

                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height - 180,
                  width: MediaQuery.of(context).size.width,
                  child: Center(
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
              ],
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
  String _adults = '';
  String _children = '';
  bool _takeaway = false;
  bool _meat = false;
  bool _gluten = false;
  bool _lactose = false;
  bool _milk = false;
  bool _nuts = false;
  bool _freshFruit = false;
  bool _onions = false;
  bool _carrots = false;


  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Save the form data
      Navigator.pop(context, true);
    }
  }

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
                padding: const EdgeInsets.all(8),
                child: Text(dinnerEvent.menu),
              ),
              Padding(
                padding: const EdgeInsets.all(4),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4),
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                        padding: const EdgeInsets.all(4),
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                      Padding(
                        padding: const EdgeInsets.all(4),
                        child: CheckboxListTile(
                          title: const Text('Takeaway'),
                          value: _takeaway,
                          shape: OutlineInputBorder(),
                          controlAffinity: ListTileControlAffinity.leading,
                          onChanged: (bool? newValue) {
                            setState(() {
                              _takeaway = newValue!;
                            });
                          },

                        ),
                      ),

                      Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.all(
                              Radius.circular(5.0)
                          ),
                        ),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              CheckboxListTile(
                                title: const Text('Kød'),
                                value: _meat,
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




                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          child: const Text('Tilmeld'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ]
        )
    );
  }
}
