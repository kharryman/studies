const puppeteer = require('puppeteer');
//const fs = require('fs');
const fs = require('fs');
const path = require('path');
const axios = require('axios');

//const { Translate } = require('@google-cloud/translate');
const { Translate } = require('@google-cloud/translate').v2;

//var args = process.argv.slice(-1);

//console.log("PASSED START INDEX = " + args[0]);


// Set your Google Cloud API key
//const googleApiKey = 'YOUR_GOOGLE_API_KEY';
const googleApiKey = "";//SET WHEN GOING TO USE!!!
let sourceLanguage = "";
const targetLanguage = "en-US";

/*
function escapeString(str) {
  let result = '';
  for (const char of str) {
    if (char === '$') {
      // Escape dollar sign by adding a backslash before it
      result += `\\`;
      result += `$`;
    } else {
      // Keep other characters unchanged
      result += char;
    }
  }
  return result;
}
*/

function formatSubtopic(subtopic) {
  var retArr = [];
  const subtopicSplit = subtopic.name.split(" ");
  for (var word of subtopicSplit) {
    retArr.push(word.substring(0, 1).toUpperCase() + word.substring(1).toLowerCase());
  }
  return retArr.join(" ");
}

const subject = "psychology";
const subtopics = [
  { "name": "BASIC", "words": ["basic", "introduction", "introductory", "elementary"] },
  { "name": "EVOLUTIONARY PSYCHOLOGY", "words": ["evolution", "evolvement", "evolve", "transform", "transormation", "adapt", "adaptation", "darwin","darwinism", "darwinistic", "transmogrification"] },
  { "name": "BEHAVIORAL NEUROSCIENCE", "words": ["pretend", "obsessive", "compulsive", "etiquette", "manners", "habit", "habits", "behavior", "behaviors", "behaviour", "behaviours", "behavioural", "neurotransmission"] },
  { "name": "CLINICAL PSYCHOLOGY", "words": ["clinic", "clinics", "medical", "medicine", "disorder", "symptom", "symptoms", "doctor", "doctors", "hospital", "hospitals"] },
  { "name": "COGNITIVE PSYCHOLOGY", "words": ["cognition", "memory", "sense", "senses", "sensory", "sight", "vision", "eye", "eyes", "hearing", "hear", "ear", "ears", "touch", "taste"] },
  { "name": "COMMUNITY PSYCHOLOGY", "words": ["communities", "communal", "society", "city", "village", "cities"] },
  { "name": "COMPARITIVE PSYCHOLOGY", "words": ["similarity", "similarities",  "differences", "differential", "compare", "contrast"] },
  { "name": "CONSUMER PSYCHOLOGY", "words": ["corporate", "corporation", "corporations", "purchasing", "franchise", "franchises", "franchisee", "franchisees", "purchaser", "advertise", "market", "marketer", "marketers", "marketing", "advertising", "advertiser", "buyer", "buy", "sell", "money"] },
  { "name": "DEVELOPMENTAL PSYCHOLOGY", "words": ["development", "foster", "foster-parents", "parent", "parents", "orphan", "orphaned", "infant", "children", "adolescent", "child", "nanny", "nannies", "nurture", "nurtured", "mother", "father", "mothered", "fathered"] },
  { "name": "EDUCATIONAL PSYCHOLOGY", "words": ["education", "educate", "instruction", "knowledge", "classroom", "learn", "learning"] },
  { "name": "ENVIRONMENTAL PSYCHOLOGY", "words": ["environment", "surrounding", "surroundings", "habitate", "habitation", "natural", "nature"] },
  { "name": "FORENSIC PSYCHOLOGY", "words": ["forensic", "judicial", "judgement", "crime", "criminal", "legal", "prison", "jail"] },
  { "name": "HEALTH PSYCHOLOGY", "words": ["biological", "biology", "fitness", "well-being", "stamina", "vitality", "vigorousness"] },
  { "name": "INDUSTRIAL PSYCHOLOGY", "words": ["factory", "worker", "workers", "laborer", "laborers", "slave", "slaves", "sweatshop", "sweatshops", "workplace", "employer", "employers", "employee", "employees"] },
  { "name": "MILITARY PSYCHOLOGY", "words": ["soldier", "soldiers", "marine", "army", "navy", "airforce"] },
  { "name": "NEUROPSYCHOLOGY", "words": ["brain", "neuroscience", "neurology", "pathway", "neuron", "neurons"] },
  { "name": "PERSONALITY PSYCHOLOGY", "words": ["trait", "traits", "self-concept", "self-conception", "emotion", "extroversion",  "extrovert", "introversion", "introvert", "shy", "outgoing"] },
  { "name": "PSYCHOMETRIC PSYCHOLOGY", "words": ["measure", "measurement", "intelligence", "neuroticism", "depression", "gene", "genetic", "inheritance"] },
  { "name": "REHABILITATION PSYCHOLOGY", "words": ["rehab", "recovery", "disability", "disabilities"] },
  { "name": "RESEARCH PSYCHOLOGY", "words": [ "experiment", "analyze", "analysis", "analyzation", "groundwork", "study", "research", "investigate", "probing"] },
  { "name": "SCHOOL PSYCHOLOGY", "words": ["school", "student", "students", "pupils", "academy", "institution", "schooling", "elementary", "high-school", "junior-high-school", "school", "university", "college"] },
  { "name": "SOCIAL PSYCHOLOGY", "words": ["social", "societal", "interaction", "public", "civil", "civilian", "civilians"] },
  { "name": "SPORT PSYCHOLOGY", "words": ["athlete", "athletic", "olympic", "olympics", "basketball", "football", "soccer", "baseball", "tennis", "tournament"] }
];

var cheatlistData = {};



(async () => {
  // Launch a headless browser
  const browser = await puppeteer.launch({ headless: false, timeout: (60 * 60 * 1000) });

  // Create a new page
  const page = await browser.newPage();

  page.setDefaultTimeout(60 * 60 * 1000);

  await page.setRequestInterception(true);

  page.on('dialog', async (dialog) => {
    console.log(`Dialog message: ${dialog.message()}`);

    // Dismiss the dialog (you can use dialog.accept() to accept it)
    await dialog.dismiss();
  });


  page.on('request', (request) => {
    const url = request.url();
    if (url.includes('https://googleads')) {
      request.abort();  // Block the request
    } else {
      request.continue();  // Allow the request
    }
  });




  for (var subtopic of subtopics) {
    cheatlistData[subtopic.name.replace(/ /g, "_")] = {
      //"varName": subtopic.toLowerCase().replace(/ /g, "_"),
      "itemName": formatSubtopic(subtopic),
      "imageFolder": subtopic.name.replace(/ /g, "_").toUpperCase(),
      "entries": []
    };
  }

  // Get the screen width and height


  const { width, height } = await page.evaluate(() => ({
    width: parseInt(window.screen.width * window.devicePixelRatio),
    height: parseInt(window.screen.height * window.devicePixelRatio),
  }));

  await page.setViewport(
    {
      "width": width,
      "height": height,
      "isMobile": false
    }
  );
  var url = "";
  await page.goto(url, { waitUntil: 'networkidle2' });
  await page.waitForTimeout(1000);

  // Perform scraping operations
  const title = await page.title();
  console.log('Page title:', title);


  const matchingDivs = await page.$$eval('div', (divs) => {
    const divIds = divs.map((div) => { return div.id; });
    const regex = /cheat_sheet_\d+/;
    const divIdsMatch = divIds
      .filter(id => { return id && id.match(regex) != null });
    return divIdsMatch;
  });

  if (matchingDivs.length > 0) {
    console.log('Divs matching the regular expression:' + matchingDivs.length);
    //console.log(matchingDivs);
  } else {
    console.log('No divs found matching the regular expression.');
  }

  var xPath = "";
  var selector = '';
  var selectorHref = "";
  var sheetHref = "";
  var sheetHrefHandle;
  var cheatSheetNumber = "0";
  var foundSubtopic = "";
  var isAdClosed = false;
  var matchingDiv = "";

  //var numIters = 2;
  //var startIndex = parseInt(args[0]);
  //var endIndex = parseInt(args[0]);
  var startIndex = 74;
  var endIndex = 74;
  var numIters = matchingDivs.length;
  var sheetTitleSplit = [];
  var sheetTitleTransArr = [];
  var sheetTitleTransWord = "";
  for (var idIndex = startIndex; idIndex <= endIndex; idIndex++) {

    matchingDiv = matchingDivs[idIndex];
    xPath = '//*[@id="' + matchingDiv + '"]/div[2]/div/strong/a/span';
    cheatSheetNumber = matchingDiv.split("cheat_sheet_")[1];
    console.log("GETTING ID = " + xPath + '...');
    selector = '#' + matchingDiv + ' > div.triptychdblr > div > strong > a > span';
    selectorHref = '#' + matchingDiv + ' > div.triptychdblr > div > strong > a';
    await page.$eval(selector, element => {
      if (element) {
        element.scrollIntoView();
      }
    });

    await page.waitForTimeout(1000);
    const elementHandle = await page.waitForSelector(selector);

    let cheatSheetTitle = await page.evaluate(element => element.textContent, elementHandle);
    console.log('Cheatsheet Title:' + cheatSheetTitle);
    sheetTitleSplit = cheatSheetTitle.split(" ");
    sourceLanguage = "en";
    for (var t = 0; t < sheetTitleSplit.length; t++) {
      if (sheetTitleSplit[t] && sheetTitleSplit[t].length > 2) {
        sourceLanguage = await detectLanguage(sheetTitleSplit[t]);
        if (sourceLanguage.split("-")[0].toLowerCase() !== "en") {
          break;
        }
      }
    }
    console.log("GOT SOURCE LANGUAGE(" + cheatSheetTitle + ") = " + sourceLanguage);
    if (sourceLanguage.split("-")[0].toLowerCase() !== "en") {
      sheetTitleTransArr = [];
      for (var t = 0; t < sheetTitleSplit.length; t++) {
        sheetTitleTransWord = await translateText(sheetTitleSplit[t], targetLanguage);
        sheetTitleTransArr.push(sheetTitleTransWord);
      }
      cheatSheetTitle = sheetTitleTransArr.join(" ");
      console.log("cheatSheetTitle TRANSLATED = " + cheatSheetTitle);
    }
    foundSubtopic = null;
    sheetTitleSplit = cheatSheetTitle.split(" ");
    for (var subtopic of subtopics) {
      for (var subtopicWord of subtopic.name.split(" ")) {
        for (var sheetTitleWord of sheetTitleSplit) {
          if (subtopicWord.toLowerCase() !== "psychology" && sheetTitleWord.toLowerCase() === subtopicWord.toLowerCase()) {
            console.log("foundSubtopic FROM TITLE = " + subtopic.name.replace(/ /g, "_") + ", FOUND subtopicWord = " + subtopicWord.toLowerCase());
            foundSubtopic = subtopic.name.replace(/ /g, "_");
            break;
          }
        }
        if (foundSubtopic != null) { break; }
      }
      if (foundSubtopic == null) {
        for (var subtopicWord of subtopic.words) {
          for (var sheetTitleWord of sheetTitleSplit) {
            if (sheetTitleWord !== "psychology" && sheetTitleWord.toLowerCase() === subtopicWord.toLowerCase()) {
              console.log("foundSubtopic FROM WORDS = " + subtopic.name.replace(/ /g, "_") + ", FOUND subtopicWord = " + subtopicWord.toLowerCase());
              foundSubtopic = subtopic.name.replace(/ /g, "_");
              break;
            }
          }
          if (foundSubtopic != null) { break; }
        }
      }
      if (foundSubtopic != null) { break; }
    }
    //#cheat_sheet_30762 > div.triptychdblr > div > strong > a
    if (elementHandle) {
      sheetHrefHandle = await page.$(selectorHref);
      if (sheetHrefHandle) {
        sheetHref = null;
        try {
          sheetHref = await page.evaluate(link => link.href, sheetHrefHandle);
          console.log("GOT sheetHref = " + sheetHref);
        } catch (e) {
          console.log("COULD NOT GET sheetHref");
        }
      }
      if (sheetHref) {
        await page.goto(sheetHref, { waitUntil: 'networkidle2' });
        await page.waitForTimeout(4000);
        await closeAds(page);
        await page.waitForTimeout(4000);
        console.log("CALLING getSections...");
        await getSections(browser, page, cheatSheetNumber, foundSubtopic);
        await page.waitForTimeout(500);
      }
    } else {
      console.error('Could not click. Element not found.');
    }
    if (idIndex < endIndex) {
      await page.goBack({ waitUntil: 'networkidle2' });
    }
    await page.waitForTimeout(1000);
  }//END SHEET LOOP
  await createFiles(page);
  await browser.close();
})();

async function closeAds(page) {
  console.log("closeAds called");
  await page.waitForSelector('iframe', { timeout: 8000 });
  let iframeHandles = await page.$$('iframe');
  //while (iframeHandles.length > 0) {
  for (const iframeHandle of iframeHandles) {
    await page.evaluate(frame => {
      frame.remove();
    }, iframeHandle);
  }
  await page.waitForTimeout(1000);
  iframeHandles = await page.$$('iframe');
  //}
}

async function getSections(browser, page, cheatSheetNumber, myFoundSubtopic) {
  console.log("getSections called, myFoundSubtopic = " + myFoundSubtopic);

  await page.waitForTimeout(3000);
  let matchingSectionIds = [];
  try {
    matchingSectionIds = await page.$$eval('section', (sections) => {
      const sectionIds = sections.map((section) => { return section.id; });
      const regex = /block_\d+/;
      const sectionIdsMatch = sectionIds
        .filter(id => { return id && id.match(regex) != null });
      return sectionIdsMatch;
    });
  } catch (e) {
    console.log("COULD NOT FIND SECTIONS...!");
  }

  //await page.waitForTimeout(1000);
  if (matchingSectionIds.length > 0) {
    console.log('Sections matching the regular expression:' + matchingSectionIds.length);
    console.log(matchingSectionIds);
  } else {
    console.log('No sections found matching the regular expression.');
  }
  var myEntry = {};
  var sectionElementHandle;
  var sectionSelector = "";
  var sectionNumber = "0";
  var titleSelector = "";//#title_30762_118922
  var titleElementHandle;
  var sectionTitle = "";
  var sectionTitleSplit = [];
  var formattedSectionTitle = "";
  var sectionId = "";
  sectionId = matchingSectionIds[0];
  var writeSubtopic = "";
  var sectionElements = [];

  var entryType = "NORMAL";
  var tableHandle;
  var tableClass = "cheat_sheet_output_text";//DEFAULT IT TO 'NORMAL'  
  var trHandle;
  var trElements = [];
  var tdElements = [];
  var trSelector = "";
  const tableSelector = "#cheat_sheet_output_table";
  var gotNotesElements = [];
  var notesElements = [];
  var imageSelector = "";
  var imageHandle;
  var myData = [];
  var dataEntry = {};
  var myImage = "";
  var imageName = "";
  var imageHref = "";
  var imageBuffer;
  var imagePath = "";
  const downloadDir = "C:/Users/keith/Downloads";
  var youtubeSelector = "";
  var youtubeHandle;
  var youtubeVideoID = "";
  var normalCellSelector = "#cheat_sheet_output_table > tbody > tr > td > div";
  var imageCellSelector = "#cheat_sheet_output_table > tbody > tr > td";
  var cellHandle;
  var cellText = "";
  var cellTextSplit = [];
  var countColumns = 0;
  var regExpDataBrk = /\s*<br>\s*<br>\s*/g;
  var noteClassSelector = "#block_4437_15505 > div";
  var noteClassHandle;
  var noteSelector = "#block_4437_15505 > div > div";
  var noteHandle;
  var noteClass = "cheat_sheet_note";
  var regExpNoteBrk1 = /\s\n\s/g;
  var regExpNoteBrk2 = /\s\n\n\s/g;
  var getNoteClass = "";
  var regExpYoutubeAndLink = /youtube:\S+/g;

  var noteText = "";

  for (var sectionId of matchingSectionIds) {
    console.log("Doing section " + sectionId);
    myData = [];
    sectionNumber = sectionId.split("_")[1];
    sectionSelector = "#block_" + sectionNumber;
    sectionElementHandle = await page.waitForSelector(sectionSelector);
    sectionElements = [];
    //GET TITLE: ======================================>
    //#title_30762_118922    
    titleSelector = "#title_" + cheatSheetNumber + "_" + sectionNumber;
    //console.log("titleSelector = " + titleSelector);
    await page.$eval(sectionSelector, element => {
      if (element) {
        element.scrollIntoView();
      }
    });
    titleElementHandle = await sectionElementHandle.waitForSelector(titleSelector);
    if (titleElementHandle) {
      sectionTitle = (await page.evaluate(element => element.textContent, titleElementHandle)).toString();
      //REMOVE WORD BREAK HYPHENS:
      sectionTitle = sectionTitle.replace(/\u00AD/g, '');
      if (sourceLanguage.split("-")[0].toLowerCase() !== "en") {
        sectionTitle = await translateText(sectionTitle, targetLanguage);
      }
      //formattedSectionTitle = formattedSectionTitle.replace(/&shy;/g, '');
      console.log('Section Title:' + sectionTitle);

    }
    //GET SUBTOPIC: FOR FILE TO WRITE TO:==============>
    writeSubtopic = null;
    sectionTitleSplit = sectionTitle.toLowerCase().split(" ");
    if (myFoundSubtopic == null) {
      for (var subtopic of subtopics) {
        for (var subtopicWord of subtopic.name.toLowerCase().split(" ")) {
          for (var sectionTitleWord of sectionTitleSplit) {
            if (subtopicWord.trim() !== "psychology" && sectionTitleWord === subtopicWord.trim()) {
              writeSubtopic = subtopic.name.replace(/ /g, "_");
              break;
            }
          }
        }
        if (writeSubtopic == null) {
          for (var subtopicWord of subtopic.words) {
            for (var sectionTitleWord of sectionTitleSplit) {
              if (subtopicWord.trim() !== "psychology" && sectionTitleWord === subtopicWord.toLowerCase()) {
                writeSubtopic = subtopic.name.replace(/ /g, "_");
                break;
              }
            }
          }
        }
      }
      if (writeSubtopic == null) {
        writeSubtopic = "BASIC";
      }
    } else {
      writeSubtopic = myFoundSubtopic.replace(/ /g, "_");
    }
    console.log("writeSubtopic = " + writeSubtopic);

    noteClassSelector = "#block_" + cheatSheetNumber + "_" + sectionNumber + " > div";
    //GET ALL ELEMENTS OF SECTION:
    notesElements = [];
    gotNotesElements = await sectionElementHandle.$$(noteClassSelector);
    for (var n = 0; n < gotNotesElements.length; n++) {
      getNoteClass = await gotNotesElements[n].evaluate(element => {
        return element.className;
      });
      if (getNoteClass === noteClass) {
        notesElements.push(gotNotesElements[n]);
        sectionElements.push({
          "type": "NOTE",
          "element": gotNotesElements[n],
          "index": 0
        });
      }
    }


    //GET TYPE: ======================================>
    entryType = "NORMAL";
    //---check if has note selector: ------->


    tableHandle = await sectionElementHandle.$(tableSelector);
    if (tableHandle) {
      sectionElements.push({
        "type": "TABLE",
        "element": tableHandle,
        "index": 0
      });

      trElements = await tableHandle.$$('tr');

      countColumns = 0;
      for (var tr = 0; tr < trElements.length; tr++) {
        tdElements = await trElements[tr].$$('td');
        if (tdElements.length > countColumns) {
          countColumns = tdElements.length;
        }
      }
      tableClass = await tableHandle.evaluate(element => {
        return element.className;
      });
      //console.log("SECTION trElements.length = " + trElements.length + ", tableClass = " + tableClass);
      console.log("countColumns = " + countColumns);
      if (tableClass === 'cheat_sheet_output_text' || countColumns === 1) {//NORMAL:
        //#cheat_sheet_output_table > tbody > tr > td > div
        entryType = "NORMAL";
      } else {
        //entryType = "TABLE_LIST";
        entryType = "TABLE";
      }
    }

    try {
      sectionElements = await getSortedElements(sectionElements);
    } catch (e) {
      console.log("ERROR SORTING sectionElements = " + e);
    }


    //}
    //GET IMAGE: ======================================>
    myImage = null;
    var isDoImage = true;
    if (isDoImage === true) {
      imageSelector = "#cheat_sheet_output_table > tbody > tr > td > a";
      //#cheat_sheet_output_table > tbody > tr > td > a
      imageHandle = await sectionElementHandle.$(imageSelector);
      if (imageHandle) {
        try {
          imageHref = await page.evaluate(link => link.href, imageHandle);
          if (imageHref && imageHref.toString().trim() !== '') {
            //await page.goto(imageHref, { waitUntil: 'networkidle2' });
            imageName = sectionTitle.toUpperCase().replace(/-/g, "_").replace(/ /g, "_");
            //const imagePage = await browser.newPage();
            //await imagePage.goto(imageHref);
            //await imagePage.waitForTimeout(2000);

            if (!fs.existsSync(downloadDir + "/" + writeSubtopic)) {
              fs.mkdirSync(downloadDir + "/" + writeSubtopic);
              console.log('Image Directory created:', downloadDir + "/" + writeSubtopic);
            }
            imagePath = downloadDir + "/" + writeSubtopic + '/' + imageName + '.jpg';
            //await imagePage.screenshot({ path: imagePath });
            //await imagePage.close();
            //await page.bringToFront();
            await downloadImage(imageHref, imagePath);
            await page.waitForTimeout(1000);
            console.log(`Image downloaded from ${imageHref}`);

            myImage = imageName;
          }
        } catch (e) {
          console.log(`ERROR DOWNLOADING IMAGE ${imageHref} ERROR: ${e}`);
          myImage = null;
        }
      }
    }//END isDoImage.
    //GET YOUTUBE: ======================================>
    try {
      youtubeSelector = "#block_" + cheatSheetNumber + "_" + sectionNumber + " > div > div";
      youtubeHandle = await sectionElementHandle.$(youtubeSelector);
      youtubeVideoID = null;
      if (youtubeHandle) {
        youtubeVideoID = await page.evaluate(element => element.textContent, youtubeHandle)
        if (youtubeVideoID != null && youtubeVideoID.toString().trim() !== '') {
          //REMOVE WORD BREAK HYPHENS:
          youtubeVideoID = youtubeVideoID.toString().replace(/\u00AD/g, '');
          if (youtubeVideoID != null) {
            youtubeVideoID = youtubeVideoID.toString().split("youtube:")[1];
          }
          if (youtubeVideoID != null) {
            youtubeVideoID = youtubeVideoID.toString().split("\n\n")[0];
          }
          if (youtubeVideoID != null) {
            youtubeVideoID = youtubeVideoID.toString().split("&")[0];
          }
          if (youtubeVideoID != null) {
            youtubeVideoID = youtubeVideoID.toString().substring(0, 11);
          }
          console.log('Youtube Video ID:' + youtubeVideoID);
        }
      }
    } catch (e) {
      console.log("ERROR GETTING YOUTUBE ELEMENT: " + e);
    }

    for (var se = 0; se < sectionElements.length; se++) {

      //GET DATA: ======================================>      
      if (sectionElements[se].type === "TABLE") {
        if (entryType === "NORMAL") {
          for (var i = 0; i < trElements.length; i++) {
            try {
              //#cheat_sheet_output_table > tbody > tr > td > div        
              normalCellSelector = "#cheat_sheet_output_table > tbody > tr > td > div";
              cellHandle = await trElements[i].$(normalCellSelector);
              if (cellHandle) {
                cellText = await page.evaluate(element => element.textContent, cellHandle);
                console.log("NORMAL: GOT cellText = " + cellText);
                if (cellText) {
                  cellText = cellText.toString().replace(/\u00AD/g, '');
                  for (var text of cellText.split(regExpDataBrk)) {
                    for (var text2 of text.split(regExpNoteBrk2)) {
                      for (var text3 of text2.split(regExpNoteBrk1)) {
                        //text = text.replace(/\n/g, "");
                        if (sourceLanguage.split("-")[0].toLowerCase() !== "en") {
                          text3 = await translateText(text3, targetLanguage);
                        }
                        //text = escapeString(text);
                        if (myData.map((val) => { return val.value; }).indexOf("• " + text3) < 0) {
                          myData.push({
                            "value": "• " + text3
                          });
                        }
                      }
                    }
                  }
                }
              }
            } catch (e) {
              console.log("ERROR GETTING NORMAL CELL TEXT: " + e);
            }
          }
        } else if (entryType === "TABLE") {
          for (var i = 0; i < trElements.length; i++) {
            try {
              tdElements = await trElements[i].$$('td');
              dataEntry = {
                "columns": []
              };
              for (var tdElement of tdElements) {
                //#cheat_sheet_output_table > tbody > tr > td
                cellHandle = await tdElement.$(normalCellSelector);
                if (!cellHandle) {
                  console.log("cellHandle NOT FOUND!");
                } else {
                  cellText = await page.evaluate(element => element.textContent, cellHandle);
                  if (cellText) {
                    cellText = cellText.toString().replace(/\u00AD/g, '');
                    //cellText = cellText.replace(/\n/g, "");
                    if (sourceLanguage.split("-")[0].toLowerCase() !== "en") {
                      cellText = await translateText(cellText, targetLanguage);
                    }
                    //cellText = escapeString(cellText);
                    if (dataEntry.columns.map((col) => { return col.value; }).indexOf(cellText) < 0) {
                      dataEntry.columns.push({
                        "value": cellText
                      });
                    }
                  }
                }
                //#cheat_sheet_output_table > tbody > tr > td > div
              }
              if (dataEntry.columns.length > 0) {
                myData.push(dataEntry);
              }
            } catch (e) {
              console.log("ERROR GETTING TABLE CELL TEXT: " + e);
            }
          }
        }
      } else if (sectionElements[se].type === "NOTE") {
        noteSelector = "#block_" + cheatSheetNumber + "_" + sectionNumber + " > div > div";
        //noteHandle = await sectionElementHandle.$(noteSelector);
        noteHandle = sectionElements[se].element;
        noteText = await page.evaluate(element => element.textContent, noteHandle);
        console.log("NORMAL: GOT noteText = " + noteText);
        if (noteText) {
          noteText = noteText.toString().replace(/\u00AD/g, '');
          noteText = noteText.replace(regExpYoutubeAndLink, '');
          if (entryType === "NORMAL") {
            for (var text of noteText.split(regExpNoteBrk2)) {
              for (var text2 of text.split(regExpNoteBrk1)) {
                //text = text.replace(/\n/g, "");
                if (sourceLanguage.split("-")[0].toLowerCase() !== "en") {
                  text2 = await translateText(text2, targetLanguage);
                }
                //text = escapeString(text);

                if (myData.map((val) => { return val.value; }).indexOf("• " + text2) < 0) {
                  myData.push({
                    "value": "• " + text2
                  });
                }
              }
            }
          } else if (entryType === "TABLE") {
            if (sourceLanguage.split("-")[0].toLowerCase() !== "en") {
              noteText = await translateText(noteText, targetLanguage);
            }
            myData.push({
              columns: [
                { "value": noteText }
              ]
            });
          }
        }
      }
    }
    //==================================================>
    myEntry = {
      "title": sectionTitle,
      "type": entryType,
      "data": myData
    };
    if (myImage != null) {
      myEntry["image"] = myImage;
    }
    if (youtubeVideoID != null) {
      myEntry["youtube"] = youtubeVideoID;
    }
    console.log("SAVING TO SUBTOPIC " + writeSubtopic + ", myData.length=" + myData.length);
    cheatlistData[writeSubtopic].entries.push(myEntry);
  }

}

async function createFiles(page) {
  console.log("createFiles called");
  var fileNamePrefix = "";
  var fileName = "";
  var fileContent = "";
  var fileContentJson = {};
  var subtopic = subtopics[0];
  var filePath = "";
  var topicVar = "";
  var topicName = "";
  const downloadDir = "C:/Users/keith/Downloads";
  var isCreateFile = false;
  var subtopicWordSplit = [];
  for (var subtopic of subtopics) {
    console.log("createFiles subtopic = " + subtopic.name.toLowerCase().replace(/ /g, "_"));
    fileNamePrefix = subtopic.name.toLowerCase().replace(/ /g, "_");
    topicVar = "";
    subtopicWordSplit = subtopic.name.toLowerCase().split(" ");
    for (var s = 0; s < subtopicWordSplit.length; s++) {
      if (s === 0) {
        topicVar += subtopicWordSplit[0];
      } else {
        topicVar += subtopicWordSplit[s].substring(0, 1).toUpperCase() + subtopicWordSplit[s].substring(1).toLowerCase();
      }
    }
    fileName = fileNamePrefix + ".dart";
    filePath = downloadDir + "/" + fileName;
    topicName = subtopic.name.toUpperCase().replace(/ /g, "_");
    isCreateFile = false;
    if (fs.existsSync(filePath)) {
      if (cheatlistData[topicName].entries.length > 0) {
        console.log()
        fileContent = fs.readFileSync(filePath, 'utf-8');
        fileContentJson = JSON.parse((fileContent.split("final dynamic " + topicVar + " = ")[1]).trim().slice(0, -1));
        fileContentJson.entries = fileContentJson.entries.concat(cheatlistData[topicName].entries);
        fileContent = "final dynamic " + topicVar + " = \n" + JSON.stringify(fileContentJson, null, 2) + ";";
        isCreateFile = true;
      }
    } else {
      // *DEBUG*==>
      //console.log("createFiles subtopic = " + subtopic.name.toLowerCase().replace(/ /g, "_") + ", entries length = " + cheatlistData[topicName].entries.length);
      if (cheatlistData[topicName].entries.length > 0) {
        fileContent = "final dynamic " + topicVar + " = \n" + JSON.stringify(cheatlistData[topicName], null, 2) + ";";
        isCreateFile = true;
      }
    }
    if (isCreateFile === true) {
      await createFile(page, filePath, fileContent);
      await page.waitForTimeout(2000);
    }
  }
}

async function createFile(page, filePath, content) {
  console.log("createFile called, filePath = " + filePath);
  fs.writeFileSync(filePath, content, 'utf-8');
  /*
  try {
    await page.evaluate((content, fileName) => {
      const blob = new Blob([content], { type: 'text/plain' });
      const link = document.createElement('a');
      link.download = fileName;
      link.href = window.URL.createObjectURL(blob);
      document.body.appendChild(link);
      link.click();
      console.log("createFile downloaded file: " + fileName);
      document.body.removeChild(link);
    }, content, fileName);
  } catch (e) {
    console.log("ERROR CREATING FILE: " + fileName + ", error: " + e);
  }
  */
}


async function downloadImage(imageUrl, imagePath) {
  try {
    const response = await axios.get(imageUrl, { responseType: 'arraybuffer' });
    fs.writeFileSync(imagePath, response.data);
    console.log(`Image saved to: ${imagePath}`);
    return true;
  } catch (error) {
    console.error(`Error fetching or saving image:${imagePath}`, error.message);
  }
  return false;
}

async function detectLanguage(text) {

  const translate = new Translate({ key: googleApiKey });
  const [result] = await translate.detect(text);
  return result.language;
}

async function translateText(text, targetLanguage) {
  const translate = new Translate({ key: googleApiKey });
  const [translation] = await translate.translate(text, targetLanguage);
  console.log("TRANSLATED text, " + text + ", : " + translation);
  return translation;
}

async function getSortedElements(eleList) {
  const sortedElements = await Promise.all(
    eleList.map(async (element) => {
      const box = await element.element.boundingBox();
      return {
        element: element.element,
        type: element.type,
        top: box.y,
        left: box.x,
      };
    })
  );
  sortedElements.sort((a, b) => a.top - b.top || a.left - b.left);

  return sortedElements;
}