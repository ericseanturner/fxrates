require('dotenv').config()

const admin = require('firebase-admin');
const functions = require('firebase-functions');
const rp = require('request-promise');

if(!admin.apps.length){
    admin.initializeApp();
}
const db = admin.firestore();

const datesAreOnSameDay = (first, second) =>
    first.getFullYear() === second.getFullYear() &&
    first.getMonth() === second.getMonth() &&
    first.getDate() === second.getDate();

function dateStringFromDate(date){
    const ye = new Intl.DateTimeFormat('en', { year: 'numeric' }).format(date);
    const mo = new Intl.DateTimeFormat('en', { month: '2-digit' }).format(date);
    const da = new Intl.DateTimeFormat('en', { day: '2-digit' }).format(date);
    return `${ye}-${mo}-${da}`;
}

const PRICE_HISTORY_DOCUMENT_ID_TEMPLATE = "@currencySymbol_@dateString";

function makePriceHistoryDocumentID(currency){
    var documentID = PRICE_HISTORY_DOCUMENT_ID_TEMPLATE;
    var dateString = dateStringFromDate(currency.lastQuoteAt.toDate());
    documentID = documentID.replace("@currencySymbol", currency.symbol);
    documentID = documentID.replace("@dateString", dateString);
    return documentID;
}

// Called hourly from: https://us-central1-cryptometheus-1.cloudfunctions.net/checkPrices
exports.checkPrices = functions.https.onRequest(async (req, res) => {

    //1. Update latest quotes.
    var localCurrenciesMap = await fetchLocalCurrenciesMap().then((localCurrenciesMap) => {
        return localCurrenciesMap;
    });

    await fetchRemoteCurrenciesAndSync(localCurrenciesMap);

    res.status(200).send({ message: "success" });
});

async function fetchLocalCurrencies() {
    const ref = db.collection('currencies');
    const snapshot = await ref.get();
    return snapshot.docs.map(doc=>{
        var object = doc.data();
        object.documentID = doc.id;
        return object;
    });
}

async function fetchLocalCurrenciesMap() {
    var currencies = await fetchLocalCurrencies();
    var map = [];
    for(var i = 0; i < currencies.length; i++){
        var currency = currencies[i];
        map[currency.symbol] = currency;
    }
    return map;
}

async function addCurrency(remoteObject){
    const res = await db.collection('currencies').add({
        symbol: remoteObject.symbol,
        lastQuoteEUR: remoteObject.lastQuoteEUR,
        lastQuoteAt: remoteObject.lastQuoteAt,
    }).catch(err=>{
        console.log("addCurrency() error: ");
        console.log(err);
    });
}

async function syncCurrency(remoteObject, localObject){

    const localObjectDate = localObject.lastQuoteAt.toDate();
    const remoteObjectDate = remoteObject.lastQuoteAt.toDate();

    //if(datesAreOnSameDay(localObjectDate, remoteObjectDate) == false){
    addPriceHistory(localObject);
    //} 

    const ref = db.collection('currencies').doc(localObject.documentID);
    const res = await ref.update({
        lastQuoteEUR: remoteObject.lastQuoteEUR,
        lastQuoteAt: remoteObject.lastQuoteAt,
    }, { merge: true }).catch(err=>{
        console.log("syncCurrency() error: ");
        console.log(err);
    });
}

async function addPriceHistory(currency){
    var priceHistoryID = makePriceHistoryDocumentID(currency);
    const res = await db.collection('price_histories').doc(priceHistoryID).set({
        symbol: currency.symbol,
        quote: currency.lastQuoteEUR,
        date: dateStringFromDate(currency.lastQuoteAt.toDate()), 
        createdAt: currency.lastQuoteAt,
    }).catch(err=>{
        console.log("addPriceHistory() error: ");
        console.log(err);
    });
}

async function fetchRemoteCurrenciesAndSync(localObjects){
    const requestOptions = {
        method: 'GET',
        uri: 'http://data.fixer.io/api/latest',
        qs: {
            'access_key': process.env.FIXER_API_KEY,
            'base': 'EUR',
            'symbols': 'USD,EUR,JPY,GBP,AUD,CAD,CHF,CNY,SEK,NZD'
        },
        json: true,
        gzip: true
    };
    await rp(requestOptions).then(response => {
        if('rates' in response){
            var keys = Object.keys(response.rates); 
            for(var i = 0; i < keys.length; i++){
                var remoteKey = keys[i]; // eg. USD
                var quote = response.rates[remoteKey];
                var remoteObject = {
                    symbol : remoteKey,
                    lastQuoteEUR: quote,
                    lastQuoteAt: new admin.firestore.Timestamp(response.timestamp, 0)
                };
                var currencyExistsLocally = false;
                var localObject;
                for(key in localObjects){
                    localObject = localObjects[key];
                    if (localObject.symbol == remoteObject.symbol){
                        currencyExistsLocally = true;
                        break;
                    }
                }
                if (currencyExistsLocally) {
                    syncCurrency(remoteObject, localObject); // store the latest price
                } else {
                    addCurrency(remoteObject);
                }
            }
        }
    }).catch((err) => {
        console.log('fetchRemoteCurrenciesAndSync -> API call error:', err.message);
    });
}