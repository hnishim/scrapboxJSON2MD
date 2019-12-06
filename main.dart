import 'dart:io';
import 'dart:async';
import 'dart:convert';

main() async {
  // Please set these parameters as you need.
  final File file = new File("/Users/xxx/Downloads/notes.json");  // the folder path and file name of the JSON file you downloded from Scrapbox.

  Stream fileRead = file.openRead();

  String jsonString = "";
  await fileRead.transform(utf8.decoder).transform(new LineSplitter()).forEach((data) {
    jsonString += (data + "\n");
  });

  var jsonData = json.decode(jsonString);

  // omit metadata (Scrapbox's space name etc.) from the entire JSON data
  var pages = jsonData['pages'];

  pages.asMap().forEach((index, page) async {
    String md = "";

    // dates
    final DateTime lastModifiedDateTime = DateTime.fromMillisecondsSinceEpoch(page['updated'] * 1000);

    // lines
    page['lines'].asMap().forEach((lineIndex, line) {
      String thisLine = line;

      // title
      if (lineIndex == 0) {
        md += ("# " + page['title']) + "\n";
      } else {
        // bullet points
        int charLocation = 0;
        String checkTargetChar;
        if (line.length > 0) {
          checkTargetChar = line.substring(charLocation,1);
        }

        if (checkTargetChar == " " || checkTargetChar == "　" || checkTargetChar == "\t") {
          while (checkTargetChar == " " || checkTargetChar == "　" || checkTargetChar == "\t") {
            if (charLocation == 0) {
              thisLine = "\t* ";
            } else {
              thisLine = "\t" + thisLine;
            }
            charLocation += 1;
            if (line.length == charLocation) {
              break;
            }
            checkTargetChar = line.substring(charLocation,charLocation + 1);
          }
          thisLine += line.substring(charLocation, line.length);
        }

        // put the line to the markdown String
        md += (thisLine + "\n");
      }
    });

    // file output
    final file = File("/Users/hnishim/Downloads/temp/page_"+index.toString()+".txt");
    await file.writeAsString(md);
    file.setLastModifiedSync(lastModifiedDateTime);
    print(file.lastModifiedSync());
  });
}