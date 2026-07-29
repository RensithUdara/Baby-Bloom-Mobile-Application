const fs = require("fs");
const path = require("path");

const projectId = "baby-bloom-app";
const configPath = path.join(
  process.env.USERPROFILE || process.env.HOME,
  ".config",
  "configstore",
  "firebase-tools.json"
);

const token = JSON.parse(fs.readFileSync(configPath, "utf8")).tokens
  .access_token;

const l = (en, si = en, ta = en) => ({ en, si, ta });

const vaccineSchedule = [
  ["bcg", l("BCG", "බී.සී.ජී.", "பி.சி.ஜி."), 1, 0, l("At birth", "උපතේදී", "பிறந்தபோது"), false, 0],
  ["penta1", l("Pentavalent 1", "පෙන්ටාවැලන්ට් 1", "பென்டாவாலென்ட் 1"), 1, 60, l("2 months", "මාස 2", "2 மாதங்கள்"), false, 10],
  ["opv1", l("OPV 1", "ඕ.පී.වී. 1", "ஓ.பி.வி. 1"), 1, 60, l("2 months", "මාස 2", "2 மாதங்கள்"), false, 11],
  ["fipv1", l("fIPV 1", "එෆ්-අයි.පී.වී. 1", "எஃப்-ஐ.பி.வி. 1"), 1, 60, l("2 months", "මාස 2", "2 மாதங்கள்"), false, 12],
  ["penta2", l("Pentavalent 2", "පෙන්ටාවැලන්ට් 2", "பென்டாவாலென்ட் 2"), 2, 120, l("4 months", "මාස 4", "4 மாதங்கள்"), false, 20],
  ["opv2", l("OPV 2", "ඕ.පී.වී. 2", "ஓ.பி.வி. 2"), 2, 120, l("4 months", "මාස 4", "4 மாதங்கள்"), false, 21],
  ["fipv2", l("fIPV 2", "එෆ්-අයි.පී.වී. 2", "எஃப்-ஐ.பி.வி. 2"), 2, 120, l("4 months", "මාස 4", "4 மாதங்கள்"), false, 22],
  ["penta3", l("Pentavalent 3", "පෙන්ටාවැලන්ට් 3", "பென்டாவாலென்ட் 3"), 3, 180, l("6 months", "මාස 6", "6 மாதங்கள்"), false, 30],
  ["opv3", l("OPV 3", "ඕ.පී.වී. 3", "ஓ.பி.வி. 3"), 3, 180, l("6 months", "මාස 6", "6 மாதங்கள்"), false, 31],
  ["mmr1", l("MMR 1", "එම්.එම්.ආර්. 1", "எம்.எம்.ஆர். 1"), 1, 270, l("9 months", "මාස 9", "9 மாதங்கள்"), false, 40],
  ["je", l("Live JE", "ජපන් එන්සෙෆලයිටිස්", "ஜப்பானிய மூளை அழற்சி"), 1, 365, l("12 months", "මාස 12", "12 மாதங்கள்"), false, 50],
  ["dpt_booster", l("DPT", "ඩී.පී.ටී.", "டி.பி.டி."), 1, 548, l("18 months", "මාස 18", "18 மாதங்கள்"), false, 60],
  ["opv4", l("OPV 4", "ඕ.පී.වී. 4", "ஓ.பி.வி. 4"), 4, 548, l("18 months", "මාස 18", "18 மாதங்கள்"), false, 61],
  ["mmr2", l("MMR 2", "එම්.එම්.ආර්. 2", "எம்.எம்.ஆர். 2"), 2, 1095, l("3 years", "අවුරුදු 3", "3 ஆண்டுகள்"), false, 70],
  ["dt", l("DT", "ඩී.ටී.", "டி.டி."), 1, 1825, l("5 years", "අවුරුදු 5", "5 ஆண்டுகள்"), false, 80],
  ["opv5", l("OPV 5", "ඕ.පී.වී. 5", "ஓ.பி.வி. 5"), 5, 1825, l("5 years", "අවුරුදු 5", "5 ஆண்டுகள்"), false, 81],
  ["hpv1", l("HPV 1", "එච්.පී.වී. 1", "எச்.பி.வி. 1"), 1, 3650, l("10 years", "අවුරුදු 10", "10 ஆண்டுகள்"), true, 90],
  ["hpv2", l("HPV 2", "එච්.පී.වී. 2", "எச்.பி.வி. 2"), 2, 3832, l("6 months after HPV 1", "HPV 1 න් මාස 6කට පසු", "HPV 1 க்கு 6 மாதங்கள் பின்"), true, 91],
  ["atd", l("aTd", "ඒ.ටී.ඩී.", "ஏ.டி.டி."), 1, 4015, l("11 years", "අවුරුදු 11", "11 ஆண்டுகள்"), false, 100],
].map(([id, name, doseNumber, ageInDays, ageLabel, femaleOnly, order]) => ({
  id,
  name,
  doseNumber,
  ageInDays,
  ageLabel,
  femaleOnly,
  description: l(""),
  order,
}));

const vaccineInfo = {
  bcg: {
    purpose: l("Protects against severe forms of tuberculosis.", "තද ක්ෂය රෝග ආකාරවලින් ආරක්ෂා කරයි.", "கடுமையான காசநோய் வடிவங்களிலிருந்து பாதுகாக்கிறது."),
    sideEffects: [l("Small swelling or scar at injection site", "ඉන්ජෙක්ෂන් තැන කුඩා ගැටිල්ලක් හෝ කැළලක්", "ஊசி இடத்தில் சிறிய வீக்கம் அல்லது தழும்பு"), l("Mild fever", "සැහැල්ලු උණ", "லேசான காய்ச்சல்")],
    advice: l("Keep the injection site clean and dry. Visit a clinic if swelling is severe.", "ඉන්ජෙක්ෂන් තැන පිරිසිදු සහ වියළිව තබන්න. වැඩි ඉදිමීමක් නම් සායනයට යන්න.", "ஊசி இடத்தை சுத்தமாகவும் உலர்வாகவும் வைத்திருங்கள். அதிக வீக்கம் இருந்தால் கிளினிக்கிற்கு செல்லுங்கள்."),
  },
  penta: {
    purpose: l("Protects against diphtheria, pertussis, tetanus, hepatitis B and Hib.", "ඩිප්තීරියා, කක්කල් කැස්ස, ටෙටනස්, හෙපටයිටිස් B සහ Hib වලින් ආරක්ෂා කරයි.", "டிப்தீரியா, பெர்டுசிஸ், டெட்டனஸ், ஹெபடைட்டிஸ் B மற்றும் Hib இல் இருந்து பாதுகாக்கிறது."),
    sideEffects: [l("Fever", "උණ", "காய்ச்சல்"), l("Soreness at injection site", "ඉන්ජෙක්ෂන් තැන වේදනාව", "ஊசி இடத்தில் வலி"), l("Irritability", "අසහනය", "எரிச்சல்")],
    advice: l("Mild fever for a day or two is common. Seek care if symptoms are severe.", "දවසක් දෙකක් සැහැල්ලු උණ සාමාන්‍යය. තද ලක්ෂණ ඇති නම් උපදෙස් ගන්න.", "ஒரு அல்லது இரண்டு நாட்கள் லேசான காய்ச்சல் சாதாரணம். கடுமையான அறிகுறிகள் இருந்தால் ஆலோசனை பெறுங்கள்."),
  },
  opv: {
    purpose: l("Protects against poliomyelitis.", "පෝලියෝ රෝගයෙන් ආරක්ෂා කරයි.", "போலியோமையலிடிஸிலிருந்து பாதுகாக்கிறது."),
    sideEffects: [l("Usually no side effects", "සාමාන්‍යයෙන් අතුරු ආබාධ නැත", "பொதுவாக பக்கவிளைவுகள் இல்லை")],
    advice: l("Given by mouth. Follow clinic instructions after the dose.", "මුඛයෙන් ලබා දෙයි. මාත්‍රාවෙන් පසු සායන උපදෙස් පිළිපදින්න.", "வாய் வழியாக வழங்கப்படுகிறது. மருந்தளவுக்குப் பிறகு கிளினிக் அறிவுறுத்தல்களைப் பின்பற்றவும்."),
  },
  fipv: {
    purpose: l("Injectable polio vaccine given with OPV.", "OPV සමඟ ලබාදෙන ඉන්ජෙක්ෂන් පෝලියෝ එන්නත.", "OPV உடன் வழங்கப்படும் ஊசி போலியோ தடுப்பூசி."),
    sideEffects: [l("Mild soreness at injection site", "ඉන්ජෙක්ෂන් තැන සුළු වේදනාව", "ஊசி இடத்தில் லேசான வலி")],
    advice: l("Monitor the injection site for redness or swelling.", "රතු වීම හෝ ඉදිමීම තිබේද බලන්න.", "சிவத்தல் அல்லது வீக்கம் உள்ளதா கண்காணிக்கவும்."),
  },
  mmr: {
    purpose: l("Protects against measles, mumps and rubella.", "සරම්ප, කම්මුල්ගාය සහ රුබෙල්ලා වලින් ආරක්ෂා කරයි.", "சின்னம்மை, மம்ப்ஸ் மற்றும் ரூபெல்லாவிலிருந்து பாதுகாக்கிறது."),
    sideEffects: [l("Mild fever", "සැහැල්ලු උණ", "லேசான காய்ச்சல்"), l("Mild rash", "සැහැල්ලු රෑෂ්", "லேசான சிரங்கு")],
    advice: l("Fever can appear several days after the vaccine. Seek care if it is high or prolonged.", "එන්නතෙන් දින කිහිපයකට පසු උණ ඇති විය හැක. වැඩි හෝ දිගු උණ නම් උපදෙස් ගන්න.", "தடுப்பூசிக்குப் பிறகு சில நாட்களில் காய்ச்சல் வரலாம். அதிகமாக அல்லது நீடித்தால் ஆலோசனை பெறுங்கள்."),
  },
  je: {
    purpose: l("Protects against Japanese encephalitis.", "ජපන් එන්සෙෆලයිටිස් රෝගයෙන් ආරක්ෂා කරයි.", "ஜப்பானிய மூளை அழற்சியிலிருந்து பாதுகாக்கிறது."),
    sideEffects: [l("Fever or redness at injection site", "උණ හෝ ඉන්ජෙක්ෂන් තැන රතු වීම", "காய்ச்சல் அல்லது ஊசி இடத்தில் சிவத்தல்")],
    advice: l("Contact your clinic if fever lasts more than two days.", "උණ දින දෙකකට වැඩි නම් සායනය අමතන්න.", "காய்ச்சல் இரண்டு நாட்களுக்கு மேல் நீடித்தால் கிளினிக்குடன் தொடர்புகொள்ளுங்கள்."),
  },
  dpt: {
    purpose: l("Booster protection against diphtheria, pertussis and tetanus.", "ඩිප්තීරියා, කක්කල් කැස්ස සහ ටෙටනස් සඳහා බූස්ටර් ආරක්ෂාව ලබා දෙයි.", "டிப்தீரியா, பெர்டுசிஸ் மற்றும் டெட்டனஸுக்கு பூஸ்டர் பாதுகாப்பு அளிக்கிறது."),
    sideEffects: [l("Fever", "උණ", "காய்ச்சல்"), l("Soreness at injection site", "ඉන්ජෙක්ෂන් තැන වේදනාව", "ஊசி இடத்தில் வலி")],
    advice: l("Mild fever and soreness are common. Contact the clinic if symptoms are severe.", "සැහැල්ලු උණ සහ වේදනාව සාමාන්‍යයි. තද ලක්ෂණ ඇති නම් සායනය අමතන්න.", "லேசான காய்ச்சலும் வலியும் சாதாரணம். கடுமையாக இருந்தால் கிளினிக்குடன் தொடர்புகொள்ளுங்கள்."),
  },
  dt: {
    purpose: l("Booster protection against diphtheria and tetanus.", "ඩිප්තීරියා සහ ටෙටනස් සඳහා බූස්ටර් ආරක්ෂාව ලබා දෙයි.", "டிப்தீரியா மற்றும் டெட்டனஸுக்கு பூஸ்டர் பாதுகாப்பு அளிக்கிறது."),
    sideEffects: [l("Pain or redness at injection site", "ඉන්ජෙක්ෂන් තැන වේදනාව හෝ රතු වීම", "ஊசி இடத்தில் வலி அல்லது சிவத்தல்")],
    advice: l("Keep the vaccination record updated after the dose.", "මාත්‍රාවෙන් පසු එන්නත් වාර්තාව යාවත්කාලීන කරගන්න.", "மருந்தளவுக்குப் பிறகு தடுப்பூசி பதிவை புதுப்பிக்கவும்."),
  },
  hpv: {
    purpose: l("Helps protect girls against HPV infections that can lead to cervical cancer.", "ගැබ්ගෙල පිළිකාවට හේතු විය හැකි HPV ආසාදන වලින් ගැහැණු ළමුන් ආරක්ෂා කිරීමට උදව් කරයි.", "கருப்பை வாய்ப் புற்றுநோய்க்கு வழிவகுக்கும் HPV தொற்றுகளிலிருந்து சிறுமிகளைப் பாதுகாக்க உதவுகிறது."),
    sideEffects: [l("Soreness at injection site", "ඉන්ජෙක්ෂන් තැන වේදනාව", "ஊசி இடத்தில் வலி"), l("Mild fever or headache", "සැහැල්ලු උණ හෝ හිසරදය", "லேசான காய்ச்சல் அல்லது தலைவலி")],
    advice: l("Complete both doses as advised by the clinic or school health programme.", "සායන හෝ පාසල් සෞඛ්‍ය වැඩසටහනෙන් උපදෙස් දෙන පරිදි මාත්‍රා දෙකම සම්පූර්ණ කරන්න.", "கிளினிக் அல்லது பள்ளி சுகாதாரத் திட்டம் அறிவுறுத்தும் படி இரு மருந்தளவுகளையும் முடிக்கவும்."),
  },
  atd: {
    purpose: l("Adolescent booster protection against tetanus and diphtheria.", "යෞවන වයස සඳහා ටෙටනස් සහ ඩිප්තීරියා බූස්ටර් ආරක්ෂාව.", "இளம்வயதிற்கான டெட்டனஸ் மற்றும் டிப்தீரியா பூஸ்டர் பாதுகாப்பு."),
    sideEffects: [l("Mild pain or swelling at injection site", "ඉන්ජෙක්ෂන් තැන සුළු වේදනාව හෝ ඉදිමීම", "ஊசி இடத்தில் லேசான வலி அல்லது வீக்கம்")],
    advice: l("Record the dose and follow clinic guidance for any symptoms.", "මාත්‍රාව වාර්තා කර ලක්ෂණ තිබේ නම් සායන උපදෙස් පිළිපදින්න.", "மருந்தளவை பதிவு செய்து அறிகுறிகள் இருந்தால் கிளினிக் வழிகாட்டுதலைப் பின்பற்றவும்."),
  },
};

const parentingTips = [
  {
    id: "pregnancy_care",
    title: l("Pregnancy Care", "ගර්භණී සත්කාර", "கர்ப்பகால பராமரிப்பு"),
    icon: 0xe4e3,
    order: 0,
    tips: [
      l("Register with your PHM/MOH clinic early in pregnancy.", "ගර්භණී කාලයේ මුල් අවධියේම PHM/MOH සායනයේ ලියාපදිංචි වන්න.", "கர்ப்பகாலத்தின் ஆரம்பத்திலேயே PHM/MOH கிளினிக்கில் பதிவு செய்யுங்கள்."),
      l("Attend antenatal clinic visits on the advised dates.", "උපදෙස් දී ඇති දිනයන්හි ගර්භණී සායනවලට සහභාගී වන්න.", "அறிவுறுத்தப்பட்ட தேதிகளில் கர்ப்பகால கிளினிக்கிற்கு செல்லுங்கள்."),
      l("Seek urgent care for bleeding, severe headache, blurred vision, fits, reduced baby movements, fever or severe abdominal pain.", "රුධිර වහනය, දැඩි හිසරදය, පෙනීම බොඳ වීම, fit, දරුවාගේ චලන අඩුවීම, උණ හෝ දැඩි උදර වේදනාව සඳහා වහාම ප්‍රතිකාර ගන්න.", "இரத்தப்போக்கு, கடுமையான தலைவலி, மங்கலான பார்வை, fits, குழந்தை அசைவுகள் குறைதல், காய்ச்சல் அல்லது கடுமையான வயிற்றுவலி இருந்தால் அவசர சிகிச்சை பெறுங்கள்."),
    ],
  },
  {
    id: "breastfeeding",
    title: l("Breastfeeding", "මව්කිරි දීම", "தாய்ப்பால்"),
    icon: 0xe1d0,
    order: 1,
    tips: [
      l("Start breastfeeding within the first hour after birth if possible.", "හැකි නම් උපතෙන් පළමු පැය තුළ මව්කිරි දීම ආරම්භ කරන්න.", "முடிந்தால் பிறந்த முதல் மணிநேரத்திலேயே தாய்ப்பால் தொடங்குங்கள்."),
      l("Exclusive breastfeeding is recommended for the first 6 months.", "පළමු මාස 6 සඳහා මව්කිරි පමණක් නිර්දේශ කරයි.", "முதல் 6 மாதங்களுக்கு முழுமையான தாய்ப்பால் பரிந்துரைக்கப்படுகிறது."),
    ],
  },
  {
    id: "nutrition",
    title: l("Nutrition", "පෝෂණය", "ஊட்டச்சத்து"),
    icon: 0xe56c,
    order: 2,
    tips: [
      l("Introduce complementary foods around 6 months while continuing breastfeeding.", "මාස 6 පමණ වන විට මව්කිරි දිගටම දෙමින් අමතර ආහාර හඳුන්වා දෙන්න.", "6 மாதங்கள் அருகில் தாய்ப்பால் தொடர்ந்தபடி கூடுதல் உணவுகளை அறிமுகப்படுத்துங்கள்."),
      l("Avoid added salt, sugar and honey for babies under 1 year.", "අවුරුදු 1 ට අඩු දරුවන්ට අමතර ලුණු, සීනි සහ මී පැණි නොදෙන්න.", "1 வயதிற்குக் குறைவான குழந்தைகளுக்கு கூடுதல் உப்பு, சர்க்கரை மற்றும் தேன் தவிர்க்கவும்."),
    ],
  },
  {
    id: "warning_signs",
    title: l("Warning Signs", "අවදානම් ලක්ෂණ", "எச்சரிக்கை அறிகுறிகள்"),
    icon: 0xe6cb,
    order: 3,
    tips: [
      l("Seek medical help for high fever, poor feeding, difficulty breathing, persistent vomiting or unusual drowsiness.", "වැඩි උණ, කිරි නොබීම, හුස්ම ගැනීමේ අපහසුතා, දිගටම වමනය හෝ අසාමාන්‍ය නිදිමත සඳහා වෛද්‍ය උපකාර ගන්න.", "அதிக காய்ச்சல், உணவு மறுப்பு, சுவாச சிரமம், தொடர்ந்து வாந்தி அல்லது அசாதாரண தூக்கம் இருந்தால் மருத்துவ உதவி பெறுங்கள்."),
    ],
  },
];

const clinicAreas = [
  "Colombo", "Gampaha", "Kalutara", "Kandy", "Matale", "Nuwara Eliya", "Galle", "Matara", "Hambantota", "Jaffna", "Kilinochchi", "Mannar", "Vavuniya", "Mullaitivu", "Batticaloa", "Ampara", "Trincomalee", "Kurunegala", "Puttalam", "Anuradhapura", "Polonnaruwa", "Badulla", "Monaragala", "Ratnapura", "Kegalle",
];

const phonePrefixes = {
  Colombo: "011", Gampaha: "033", Kalutara: "034", Kandy: "081", Matale: "066", "Nuwara Eliya": "052", Galle: "091", Matara: "041", Hambantota: "047", Jaffna: "021", Kilinochchi: "021", Mannar: "023", Vavuniya: "024", Mullaitivu: "021", Batticaloa: "065", Ampara: "063", Trincomalee: "026", Kurunegala: "037", Puttalam: "032", Anuradhapura: "025", Polonnaruwa: "027", Badulla: "055", Monaragala: "055", Ratnapura: "045", Kegalle: "035",
};

const toValue = (v) => {
  if (v === null || v === undefined) return { nullValue: null };
  if (typeof v === "string") return { stringValue: v };
  if (typeof v === "boolean") return { booleanValue: v };
  if (typeof v === "number" && Number.isInteger(v)) return { integerValue: String(v) };
  if (typeof v === "number") return { doubleValue: v };
  if (v instanceof Date) return { timestampValue: v.toISOString() };
  if (Array.isArray(v)) return { arrayValue: { values: v.map(toValue) } };
  return { mapValue: { fields: Object.fromEntries(Object.entries(v).map(([k, val]) => [k, toValue(val)])) } };
};

const docName = (collection, id) =>
  `projects/${projectId}/databases/(default)/documents/${collection}/${encodeURIComponent(id)}`;

const writes = [];
for (const item of vaccineSchedule) {
  const { id, ...data } = item;
  writes.push({ update: { name: docName("vaccine_schedule", id), fields: toValue(data).mapValue.fields } });
}
for (const [id, data] of Object.entries(vaccineInfo)) {
  writes.push({ update: { name: docName("vaccine_info", id), fields: toValue(data).mapValue.fields } });
}
for (const item of parentingTips) {
  const { id, ...data } = item;
  writes.push({ update: { name: docName("parenting_tip_categories", id), fields: toValue(data).mapValue.fields } });
}
clinicAreas.forEach((area, index) => {
  writes.push({
    update: {
      name: docName("moh_clinics", area.toLowerCase()),
      fields: toValue({
        mohArea: area,
        name: `${area} MOH Office`,
        distanceKm: 1 + (index % 10) / 10,
        nextClinicDate: new Date("2026-08-01T00:00:00.000Z"),
        phone: `${phonePrefixes[area] || "011"} 222 3333`,
        workingHours: "8.00 AM - 4.00 PM",
        address: `MOH Office, ${area}`,
        photoUrl: "",
      }).mapValue.fields,
    },
  });
});

async function commitChunk(chunk) {
  const res = await fetch(
    `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents:commit`,
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${token}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ writes: chunk }),
    }
  );
  if (!res.ok) {
    throw new Error(`${res.status} ${res.statusText}: ${await res.text()}`);
  }
  return res.json();
}

(async () => {
  for (let i = 0; i < writes.length; i += 400) {
    await commitChunk(writes.slice(i, i + 400));
  }
  console.log(
    `Seeded ${vaccineSchedule.length} vaccine schedule docs, ${Object.keys(vaccineInfo).length} vaccine info docs, ${parentingTips.length} tip categories, ${clinicAreas.length} MOH clinics.`
  );
})();
