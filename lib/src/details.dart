import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

class EarthquakeDetails extends StatefulWidget {
  EarthquakeDetails(this.earthquake) : super();

  final String title = "Earthquakes";
  final List<String> earthquake;

  @override
  EarthquakeDetailsState createState() => EarthquakeDetailsState();
}

class EarthquakeDetailsState extends State<EarthquakeDetails> {
  String _title = '';
  List<String> _earthquake = [];

  static const String loadingText = "Loading...";

  updateTitle(title) {
    setState(() {
      _title = title;
    });
  }

  updateEarthquake(quake) {
    setState(() {
      _earthquake = quake;
    });
  }

  @override
  void initState() {
    super.initState();
    updateTitle(widget.title);
    updateEarthquake(widget.earthquake);
  }

  header() {
    return AppBar(
      title: Text(
        "Earthquakes",
        style: TextStyle(
          color: const Color(0xff0e172c),
          fontSize: 32,
          fontFamily: GoogleFonts.oswald().fontFamily,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: BackButton(color: const Color(0xff0e172c)),
      bottom: PreferredSize(
          child: Container(
            color: Color(0xff0e172c),
            height: 2,
          ),
          preferredSize: Size.fromHeight(2)),
    );
  }

  drawer() {
    return FloatingActionButton(
      onPressed: showMenu,
      child: const Icon(
        Icons.arrow_upward,
        color: Colors.white,
      ),
      backgroundColor: const Color(0xff0e172c),
    );
  }

  body() {
    List<String> coords = _earthquake[2].split(':').toString().split(',');
    LatLng latlng = LatLng(double.tryParse(coords[1].trim()) ?? 0.0,
        double.tryParse(coords[2].replaceAll(']', '')) ?? 0.0);
    String magnitude = _earthquake[4].split(':')[1].toString();

    return Container(
      child: map(latlng, magnitude),
    );
  }

  showMenu() {
    String quakeDate = _earthquake[0].trim();
    String location = _earthquake[1].trim();
    String coords = _earthquake[2].trim();
    String depth = _earthquake[3].trim();
    String magnitude = _earthquake[4].trim();

    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
              color: Color(0xff232f34),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Container(
                  height: 20,
                ),
                SizedBox(
                    height: (50 * 6).toDouble(),
                    child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16.0),
                            topRight: Radius.circular(16.0),
                          ),
                          color: Color(0xff344955),
                        ),
                        child: Stack(
                          alignment: Alignment(0, 0),
                          children: <Widget>[
                            Positioned(
                              child: ListView(
                                physics: NeverScrollableScrollPhysics(),
                                children: <Widget>[
                                  ListTile(
                                    title: Text(location,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontFamily:
                                              GoogleFonts.oswald().fontFamily,
                                          fontWeight: FontWeight.w500,
                                        )),
                                  ),
                                  ListTile(
                                    title: Text(quakeDate,
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w300,
                                            fontFamily:
                                                GoogleFonts.oswald().fontFamily,
                                            color: Colors.white)),
                                  ),
                                  ListTile(
                                    title: Text(coords,
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w300,
                                            fontFamily:
                                                GoogleFonts.oswald().fontFamily,
                                            color: Colors.white)),
                                  ),
                                  ListTile(
                                    title: Text(magnitude,
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w300,
                                            fontFamily:
                                                GoogleFonts.oswald().fontFamily,
                                            color: Colors.white)),
                                  ),
                                  ListTile(
                                    title: Text(depth,
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w300,
                                            fontFamily:
                                                GoogleFonts.oswald().fontFamily,
                                            color: Colors.white)),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ))),
                Container(
                  height: 20,
                  color: Color(0xff4a6572),
                )
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: header(),
        floatingActionButton: drawer(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        backgroundColor: const Color(0xfff9f8fc),
        body: body(),
      ),
    );
  }

  title(title) {
    return Text(
      title,
      style: TextStyle(
        color: Color(0xff0e172c),
        fontSize: 24,
        fontFamily: GoogleFonts.oswald().fontFamily,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  map(coords, magni) {
    return Container(
      child: FlutterMap(
        options: MapOptions(
          center: coords,
          zoom: 7.0,
        ),
        layers: [
          TileLayerOptions(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
            attributionBuilder: (_) {
              return Text("");
            },
          ),
          MarkerLayerOptions(markers: [
            Marker(
                width: 80,
                height: 80,
                point: coords,
                builder: (ctx) => Container(
                      child: Icon(
                        Icons.warning,
                        color: getMagniColour(double.tryParse(magni) ?? 0),
                      ),
                    ))
          ]),
        ],
      ),
    );
  }

  getMagniColour(magnitude) {
    if (magnitude <= 1) {
      return Color(0xffd3e4cd);
    } else if (magnitude > 1 && magnitude <= 2) {
      return Color(0xffadc2a9);
    } else if (magnitude > 2 && magnitude <= 3) {
      return Color(0xff99a799);
    } else if (magnitude > 3 && magnitude <= 4) {
      return Color(0xffffbc80);
    } else if (magnitude > 4 && magnitude <= 5) {
      return Color(0xffff9f45);
    } else if (magnitude > 5 && magnitude <= 6) {
      return Color(0xfff76e11);
    } else if (magnitude > 6 && magnitude <= 7) {
      return Color(0xfffc4f4f);
    } else if (magnitude > 7 && magnitude <= 8) {
      return Color(0xff9c0f48);
    } else {
      return Color(0xff470d21);
    }
  }
}
